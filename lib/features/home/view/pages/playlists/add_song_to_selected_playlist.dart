import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/features/home/view/widgets/music_slab.dart';
import 'package:client/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddSongToSelectedPlaylist extends ConsumerWidget {
  // ignore: prefer_typing_uninitialized_variables
  final currentSong;
  const AddSongToSelectedPlaylist(this.currentSong, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Select Playlist to add song"),
      ),
      body: CurrentSongNotifier().playList.isEmpty
          ? const Center(
              child: Text("No Playlist was Created Yet"),
            )
          : ListView.builder(
              itemCount: CurrentSongNotifier().playList.length + 1,
              itemBuilder: (context, index) {
                if (index == CurrentSongNotifier().playList.length) {
                  return ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cencel"));
                } else {
                  return ListTile(
                      title: Text(
                          playlists[index].elementAt(0).song_name.toString()),
                      onTap: () {
                        CurrentSongNotifier()
                            .addSongToPlaylist(currentSong, index, context);
                      });
                }
              },
            ),
      bottomNavigationBar: const MusicSlab(),
    );
  }
}
