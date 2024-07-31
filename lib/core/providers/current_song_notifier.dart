// ignore_for_file: avoid_public_notifier_properties

import 'dart:convert';
import 'package:client/features/home/model/song_model.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:client/features/home/viewmodel/home_view_model.dart';
import 'package:client/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'current_song_notifier.g.dart';

@riverpod
class CurrentSongNotifier extends _$CurrentSongNotifier {
  late HomeLocalRepository _homeLocalRepository;

  late HomeViewModel _viewModelRepository;
  static AudioPlayer? audioPlayer;
  bool isPlaying = false;
  bool isLoop = false;
  var playList = playlists;

  SongModel? currentSong;
  Future<void> savePlaylists(List<List<SongModel>> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> playlistsJson = playlists
        .map((playlist) =>
            jsonEncode(playlist.map((song) => song.toJson()).toList()))
        .toList();
    await prefs.setStringList('playlists', playlistsJson);
  }

  Future<List<List<SongModel>>> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? playlistsJson = prefs.getStringList('playlists');
    if (playlistsJson == null) {
      return [];
    }
    return playlistsJson.map((playlistJson) {
      List<dynamic> playlistMap = jsonDecode(playlistJson);
      return playlistMap
          .map((songJson) => SongModel.fromJson(songJson))
          .toList();
    }).toList();
  }

  @override
  SongModel? build() {
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    _viewModelRepository = ref.read(homeViewModelProvider.notifier);
    loadPlaylists().then((loadedPlaylists) {
      playlists = loadedPlaylists;
    });

    return null;
  }

  void updateSong(SongModel song) async {
    await audioPlayer?.stop();
    audioPlayer = AudioPlayer();

    final audioSorce = AudioSource.uri(Uri.parse(song.song_url),
        tag: MediaItem(
            id: song.id,
            title: song.song_name,
            artist: song.artist,
            artUri: Uri.parse(song.thumbnail_url)));
    await audioPlayer!.setAudioSource(audioSorce);
    audioPlayer?.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        audioPlayer!.seek(Duration.zero);
        audioPlayer!.pause();
        isPlaying = false;
        this.state = this.state?.copyWith(hex_code: this.state?.hex_code);
      }
    });
    _homeLocalRepository.uploadLocalSong(song);
    audioPlayer!.play();
    isPlaying = true;
    state = song;
  }

  void loop() {
    if (isLoop) {
      audioPlayer?.setLoopMode(LoopMode.off);
      isLoop = false;
    } else {
      audioPlayer?.setLoopMode(LoopMode.one);
      isLoop = true;
    }
    state = state?.copyWith(hex_code: state?.hex_code);
  }

  void playPause() {
    if (isPlaying) {
      audioPlayer?.pause();
      isPlaying = false;
    } else {
      audioPlayer?.play();
      isPlaying = true;
    }
    state = state?.copyWith(hex_code: state?.hex_code);
  }

  void seek(double val) {
    audioPlayer?.seek(Duration(
        milliseconds: (val * audioPlayer!.duration!.inMilliseconds).toInt()));
    state = state?.copyWith(hex_code: state?.hex_code);
  }

  void shuffle() async {
    isLoop = false;
    await audioPlayer?.stop();
    List<SongModel> allSongs = await _viewModelRepository.getAllSongs();
    allSongs.shuffle();

    int currentIndex = 0;
    int nextIndex = currentIndex;

    await audioPlayer?.stop();
    audioPlayer = AudioPlayer();

    final audioSource = AudioSource.uri(Uri.parse(allSongs[nextIndex].song_url),
        tag: MediaItem(
            id: allSongs[nextIndex].id,
            title: allSongs[nextIndex].song_name,
            artist: allSongs[nextIndex].artist,
            artUri: Uri.parse(allSongs[nextIndex].thumbnail_url)));
    await audioPlayer!.setAudioSource(audioSource);
    audioPlayer?.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        audioPlayer!.seek(Duration.zero);
        audioPlayer!.pause();
        isPlaying = false;
        this.state = this.state?.copyWith(hex_code: this.state?.hex_code);
        nextSong(); // Call the playNextSong function to play the next shuffled song
      }
    });

    _homeLocalRepository.uploadLocalSong(allSongs[nextIndex]);
    audioPlayer!.play();
    isPlaying = true;
    state = allSongs[nextIndex];
  }

  void nextSong() async {
    isLoop = false;
    await audioPlayer?.stop();
    List<SongModel> allSongs = await _viewModelRepository.getAllSongs();
    int currentIndex = allSongs.indexOf(state!);
    int nextIndex = (currentIndex + 1) % allSongs.length;

    await audioPlayer?.stop();
    audioPlayer = AudioPlayer();

    final audioSource = AudioSource.uri(Uri.parse(allSongs[nextIndex].song_url),
        tag: MediaItem(
            id: allSongs[nextIndex].id,
            title: allSongs[nextIndex].song_name,
            artist: allSongs[nextIndex].artist,
            artUri: Uri.parse(allSongs[nextIndex].thumbnail_url)));

    await audioPlayer!.setAudioSource(audioSource);
    audioPlayer?.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        audioPlayer!.seek(Duration.zero);
        audioPlayer!.pause();
        isPlaying = false;
        this.state = this.state?.copyWith(hex_code: this.state?.hex_code);
      }
    });

    _homeLocalRepository.uploadLocalSong(allSongs[nextIndex]);
    audioPlayer!.play();
    isPlaying = true;
    state = allSongs[nextIndex];
  }

  void previousSong() async {
    isLoop = false;
    await audioPlayer?.stop();
    List<SongModel> allSongs = await _viewModelRepository.getAllSongs();
    int currentIndex = allSongs.indexOf(state!);
    int previousIndex = (currentIndex - 1 + allSongs.length) % allSongs.length;

    await audioPlayer?.stop();
    audioPlayer = AudioPlayer();

    final audioSource = AudioSource.uri(
        Uri.parse(allSongs[previousIndex].song_url),
        tag: MediaItem(
            id: allSongs[previousIndex].id,
            title: allSongs[previousIndex].song_name,
            artist: allSongs[previousIndex].artist,
            artUri: Uri.parse(allSongs[previousIndex].thumbnail_url)));

    await audioPlayer!.setAudioSource(audioSource);
    audioPlayer?.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        audioPlayer!.seek(Duration.zero);
        audioPlayer!.pause();
        isPlaying = false;
        this.state = this.state?.copyWith(hex_code: this.state?.hex_code);
      }
    });

    _homeLocalRepository.uploadLocalSong(allSongs[previousIndex]);
    audioPlayer!.play();
    isPlaying = true;
    state = allSongs[previousIndex];
  }

  Future<void> playPlaylist(List<SongModel> playlist) async {
    audioPlayer ??= AudioPlayer();
    await audioPlayer?.stop();
    try {
      for (int i = 1; i < playlist.length; i++) {
        debugPrint(playlist[i].song_name);
        await audioPlayer?.stop();

        final audioSource = AudioSource.uri(Uri.parse(playlist[i].song_url),
            tag: MediaItem(
                id: playlist[i].id,
                title: playlist[i].song_name,
                artist: playlist[i].artist,
                artUri: Uri.parse(playlist[i].thumbnail_url)));
        await audioPlayer!.setAudioSource(audioSource);
        audioPlayer?.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            audioPlayer!.seek(Duration.zero);
            audioPlayer!.pause();
            isPlaying = false;
            this.state = this.state?.copyWith(hex_code: this.state?.hex_code);
          }
        });
        _homeLocalRepository.uploadLocalSong(playlist[i]);
        audioPlayer!.play();
        isPlaying = true;
        // Update the state property with the currently playing song
        state = playlist[i];

        // Wait for the current song to complete before playing the next song
        await audioPlayer!.playerStateStream.firstWhere(
          (state) => state.processingState == ProcessingState.completed,
        );
      }
    } on PlatformException catch (e) {
      debugPrint('PlatformException: ${e.code}, ${e.message}');
      // Handle the exception as needed
    }
  }

  Future<int> createPlaylist(String playlistName) async {
    List<SongModel> newPlaylist = [
      SongModel(
          id: 'playlist_name',
          song_name: playlistName,
          artist: '',
          thumbnail_url: '',
          song_url: '',
          hex_code: '')
    ]; // Create a new playlist with the given name
    playlists.add(newPlaylist); // Add the new playlist to the playlists list
    await savePlaylists(playlists); // Save the updated playlists
    var index =
        playlists.length - 1; // Get the index of the newly created playlist
    return index;
  }

  Future<void> addSongToPlaylist(
      SongModel song, int playlistIndex, context) async {
    if (playlistIndex < playlists.length) {
      // Check if the song is already present in the playlist
      bool isSongAlreadyPresent = playlists[playlistIndex]
          .any((existingSong) => existingSong.id == song.id);

      if (!isSongAlreadyPresent) {
        // If the song is not already present, add it to the playlist
        playlists[playlistIndex].add(song);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Song is added to the playlist")));
        await savePlaylists(playlists);
      } else {
        // If the song is already present, display a message or handle the case as needed
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("This Song is Already present in this Playlist")));
        debugPrint('Song is already present in the playlist');
      }
    } else {
      debugPrint("Adding song");
    }
  }

  Future<void> deletePlaylist(int playlistIndex) async {
    if (playlistIndex < playlists.length) {
      playlists.removeAt(playlistIndex);
      await savePlaylists(playlists);
    } else {
      debugPrint('Playlist index out of range');
    }
  }

  Future<void> stopSong() async {
    await audioPlayer?.stop();
    isPlaying = false;
    state = null;
  }
}
