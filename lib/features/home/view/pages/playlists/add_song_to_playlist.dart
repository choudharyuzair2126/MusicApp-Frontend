import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallet.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/view/pages/homePages/home_page.dart';
import 'package:client/features/home/view/pages/playlists/show_all_playlists.dart';
import 'package:client/features/home/viewmodel/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddSongToPlaylist extends ConsumerWidget {
  final int index1;
  const AddSongToPlaylist({
    super.key,
    required this.index1,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getAllSongsProvider).when(
        data: (data) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ShowAllPlaylists()));
                  },
                ),
              ],
              title: const Text("Add Songs to Playlist"),
            ),
            body: ListView.builder(
              itemCount: data.length + 1,
              itemBuilder: (context, index) {
                if (index == data.length) {
                  return TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()));
                      },
                      child: const Text("OK"));
                }
                final song = data[index];
                return ListTile(
                  onTap: () {
                    ref
                        .read(currentSongNotifierProvider.notifier)
                        .updateSong(song);
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
                    backgroundImage: NetworkImage(song.thumbnail_url),
                    radius: 35,
                    backgroundColor: Pallete.backgroundColor,
                  ),
                  trailing: TextButton.icon(
                    onPressed: () {
                      CurrentSongNotifier()
                          .addSongToPlaylist(data[index], index1, context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add to Playlist'),
                  ),
                );
              },
            ),
          );
        },
        error: (error, st) {
          return Center(
            child: Text(error.toString()),
          );
        },
        loading: () => const Loader());
  }
}
