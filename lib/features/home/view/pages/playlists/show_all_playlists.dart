import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/features/home/view/pages/playlists/create_playlist.dart';
import 'package:client/features/home/view/pages/playlists/show_playlist.dart';
import 'package:client/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowAllPlaylists extends ConsumerStatefulWidget {
  const ShowAllPlaylists({super.key});

  @override
  ConsumerState<ShowAllPlaylists> createState() => _ShowAllPlaylistsState();
}

class _ShowAllPlaylistsState extends ConsumerState<ShowAllPlaylists> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User\'s  Playlists'),
        automaticallyImplyLeading: false,
      ),
      body: CurrentSongNotifier().playList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                      "No Playlist was Created yet Create a new Plalists"),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreatePlaylist(),
                          ),
                        );
                      },
                      child: const Text('Create a new Playlist')),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: CurrentSongNotifier().playList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == CurrentSongNotifier().playList.length) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CreatePlaylist(),
                                    ),
                                  );
                                },
                                child: const Text('Create a new Playlist')),
                          );
                        } else {
                          return ListTile(
                            title: Text(playlists[index]
                                .elementAt(0)
                                .song_name
                                .toString()),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ShowPlaylist(inde: index),
                                ),
                              );
                            },
                            trailing: SizedBox(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        CurrentSongNotifier()
                                            .deletePlaylist(index);
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.delete_outline)),
                                  IconButton(
                                    onPressed: () {
                                      ref
                                          .watch(currentSongNotifierProvider
                                              .notifier)
                                          .playPlaylist(playlists[index]);
                                    },
                                    icon: const Icon(
                                        Icons.playlist_play_outlined),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }),
                )
              ],
            ),
    );
  }
}
