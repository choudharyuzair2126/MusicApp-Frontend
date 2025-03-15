import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallet.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/viewmodel/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Favorite Songs"),
        automaticallyImplyLeading: false,
      ),
      body: ref.watch(getFavSongsProvider).when(
          data: (data) {
            return data.isEmpty
                ? const Center(
                    child: Text("No Favorite Songs Yet"),
                  )
                : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
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
                      );
                    });
            return null;
          },
          error: (error, st) {
            return Center(
              child: Text(error.toString()),
            );
          },
          loading: () => const Center(child: Loader())),
    );
  }
}
