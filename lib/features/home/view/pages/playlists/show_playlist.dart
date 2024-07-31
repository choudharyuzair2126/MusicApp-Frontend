import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallet.dart';
import 'package:client/features/home/view/pages/playlists/add_song_to_playlist.dart';
import 'package:client/features/home/view/widgets/music_slab.dart';
import 'package:client/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowPlaylist extends ConsumerStatefulWidget {
  final int inde;
  const ShowPlaylist({super.key, required this.inde});

  @override
  ConsumerState<ShowPlaylist> createState() => _ShowPlaylistState();
}

class _ShowPlaylistState extends ConsumerState<ShowPlaylist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
            CurrentSongNotifier().playList[widget.inde].elementAt(0).song_name),
      ),
      body: CurrentSongNotifier().playList[widget.inde].length > 1
          ? ListView.builder(
              itemCount: CurrentSongNotifier().playList[widget.inde].length + 1,
              itemBuilder: (context, index) {
                if (index > 0 &&
                    index <
                        CurrentSongNotifier().playList[widget.inde].length) {
                  var data = CurrentSongNotifier().playList[widget.inde];
                  return Card(
                    child: ListTile(
                      onTap: () {
                        ref
                            .read(currentSongNotifierProvider.notifier)
                            .updateSong(data[index]);
                      },
                      title: Text(
                        data[index].song_name,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        data[index].artist,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(data[index].thumbnail_url),
                        radius: 35,
                        backgroundColor: Pallete.backgroundColor,
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          playlists[widget.inde]
                              .removeWhere((song) => song == data[index]);
                          setState(() {});
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                  );
                } else if (index ==
                    CurrentSongNotifier().playList[widget.inde].length) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddSongToPlaylist(index1: widget.inde),
                        ),
                      );
                    },
                    child: const Text("Add songs to playlist"),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              })
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Playlist is empty"),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddSongToPlaylist(index1: widget.inde)));
                      },
                      child: const Text("Add songs to playlist"))
                ],
              ),
            ),
      bottomNavigationBar: const MusicSlab(),
    );
  }
}
