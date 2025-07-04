import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallet.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/view/widgets/music_player.dart';
import 'package:client/features/home/viewmodel/home_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicSlab extends ConsumerWidget {
  const MusicSlab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongNotifierProvider);
    final songNotifier = ref.watch(currentSongNotifierProvider.notifier);
    final userFavorites = ref
        .watch(currentUserNotifierProvider.select((data) => data?.favorites));

    if (currentSong == null) {
      return const SizedBox();
    } else {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  MusicPlayer(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final tween =
                    Tween(begin: const Offset(0, 1), end: Offset.zero).chain(
                  CurveTween(curve: Curves.easeIn),
                );
                final offSetAnimation = animation.drive(tween);
                return SlideTransition(
                  position: offSetAnimation,
                  child: child,
                );
              },
            ),
          );
        },
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                color: hexToColor(currentSong.hex_code),
                borderRadius: BorderRadius.circular(6),
              ),
              height: 66,
              width: MediaQuery.of(context).size.width - 10,
              padding: const EdgeInsets.all(9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'music-player',
                        child: Container(
                          width: 48,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              image: DecorationImage(
                                  image: NetworkImage(
                                    currentSong.thumbnail_url,
                                  ),
                                  fit: BoxFit.fill)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Text(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                currentSong.song_name,
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(
                                currentSong.artist,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Pallete.subtitleText,
                                ),
                              ),
                            ),
                          ])
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        color: Pallete.whiteColor,
                        onPressed: () async {
                          await ref
                              .read(homeViewModelProvider.notifier)
                              .favSong(songId: currentSong.id);
                        },
                        icon: Icon(userFavorites!
                                .where((fav) => fav.song_id == currentSong.id)
                                .toList()
                                .isNotEmpty
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart),
                      ),
                      IconButton(
                        color: Pallete.whiteColor,
                        onPressed: () {
                          songNotifier.stopSong();
                        },
                        icon: const Icon(CupertinoIcons.stop_fill),
                      ),
                      IconButton(
                        color: Pallete.whiteColor,
                        onPressed: () {
                          songNotifier.playPause();
                        },
                        icon: songNotifier.isPlaying == true
                            ? const Icon(CupertinoIcons.pause_fill)
                            : const Icon(CupertinoIcons.play_fill),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 8,
              child: Container(
                height: 2,
                width: MediaQuery.of(context).size.width -
                    26, // Adjust for left offset and padding
                decoration: BoxDecoration(
                  color: Pallete.inactiveSeekColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            StreamBuilder<Duration>(
              stream: CurrentSongNotifier.audioPlayer?.positionStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return const SizedBox();
                }
                final position = snapshot.data!;
                final duration = CurrentSongNotifier.audioPlayer!.duration;
                double sliderValue = 0.0;
                if (duration == null) {
                  return const SizedBox();
                }
                sliderValue = position.inMilliseconds /
                    duration.inMilliseconds.toDouble();

                return Positioned(
                  bottom: 0,
                  left: 8,
                  child: Container(
                    height: 2,
                    width:
                        (sliderValue * (MediaQuery.of(context).size.width - 26))
                            .clamp(4.0, double.infinity),
                    decoration: BoxDecoration(
                      color: Pallete.whiteColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }
  }
}
