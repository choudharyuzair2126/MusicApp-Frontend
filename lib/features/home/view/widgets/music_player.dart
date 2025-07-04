import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallet.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/view/pages/playlists/add_song_to_selected_playlist.dart';
import 'package:client/features/home/viewmodel/home_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

// ignore: must_be_immutable
class MusicPlayer extends ConsumerWidget {
  MusicPlayer({super.key});

  final ValueNotifier<double> sliderValueNotifier = ValueNotifier(0);
  bool isSliding = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongNotifierProvider);
    final songNotifier = ref.read(currentSongNotifierProvider.notifier);
    final userFavorites = ref
        .watch(currentUserNotifierProvider.select((data) => data!.favorites));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [hexToColor(currentSong!.hex_code), const Color(0xff121212)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Pallete.transparentColor,
        appBar: AppBar(
          backgroundColor: Pallete.transparentColor,
          leading: Transform.translate(
            offset: const Offset(-15, 0),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              highlightColor: Pallete.transparentColor,
              focusColor: Pallete.transparentColor,
              splashColor: Pallete.transparentColor,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.keyboard_arrow_down_outlined,
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Hero(
                  tag: 'music-player',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(currentSong.thumbnail_url),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.76,
                            child: Text(
                              currentSong.song_name,
                              style: const TextStyle(
                                color: Pallete.whiteColor,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w700,
                                fontSize: 23,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.76,
                            child: Text(
                              currentSong.artist,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Pallete.subtitleText,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Expanded(child: SizedBox()),
                      IconButton(
                        onPressed: () async {
                          await ref
                              .read(homeViewModelProvider.notifier)
                              .favSong(songId: currentSong.id);
                        },
                        icon: Icon(userFavorites
                                .where((fav) => fav.song_id == currentSong.id)
                                .toList()
                                .isNotEmpty
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart),
                        color: Pallete.whiteColor,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  StreamBuilder<Duration>(
                    stream: CurrentSongNotifier.audioPlayer!.positionStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final position = snapshot.data ?? Duration.zero;
                      final duration =
                          CurrentSongNotifier.audioPlayer!.duration ??
                              Duration.zero;

                      if (!isSliding) {
                        sliderValueNotifier.value =
                            position.inMilliseconds / duration.inMilliseconds;
                      }

                      return Column(
                        children: [
                          ValueListenableBuilder<double>(
                            valueListenable: sliderValueNotifier,
                            builder: (context, sliderValue, child) {
                              return SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  thumbColor: Pallete.whiteColor,
                                  trackHeight: 4,
                                  trackShape:
                                      const RectangularSliderTrackShape(),
                                  activeTrackColor: Pallete.whiteColor,
                                  inactiveTrackColor:
                                      Pallete.whiteColor.withOpacity(0.117),
                                  overlayShape: SliderComponentShape.noOverlay,
                                ),
                                child: Slider(
                                  min: 0,
                                  max: 1,
                                  value: sliderValue.isNaN
                                      ? 0
                                      : sliderValue > 1
                                          ? 1
                                          : sliderValue < 0
                                              ? 0
                                              : sliderValue,
                                  onChanged: (val) {
                                    isSliding = true;
                                    sliderValueNotifier.value = val;
                                  },
                                  onChangeEnd: (val) {
                                    songNotifier.seek(val);
                                    isSliding = false;
                                  },
                                ),
                              );
                            },
                          ),
                          Row(
                            children: [
                              Text(
                                '${position.inMinutes}:${position.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: Pallete.subtitleText,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 13,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              Text(
                                '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: Pallete.subtitleText,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: IconButton(
                          onPressed: songNotifier.shuffle,
                          icon: const Icon(
                            CupertinoIcons.shuffle,
                            color: Pallete.whiteColor,
                            size: 25,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => songNotifier.previousSong(),
                        icon: const Icon(
                          Icons.skip_previous_rounded,
                          color: Pallete.whiteColor,
                          size: 50,
                        ),
                      ),
                      IconButton(
                        onPressed: songNotifier.playPause,
                        icon: Icon(
                          songNotifier.isPlaying
                              ? CupertinoIcons.pause_circle_fill
                              : CupertinoIcons.play_circle_fill,
                        ),
                        iconSize: 70,
                        color: Pallete.whiteColor,
                      ),
                      IconButton(
                        onPressed: () => songNotifier.nextSong(),
                        icon: const Icon(
                          Icons.skip_next_rounded,
                          color: Pallete.whiteColor,
                          size: 50,
                        ),
                      ),
                      IconButton(
                        onPressed: songNotifier.loop,
                        icon: Icon(
                          songNotifier.isLoop
                              ? CupertinoIcons.repeat_1
                              : CupertinoIcons.repeat,
                          color: Pallete.whiteColor,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: IconButton(
                            onPressed: () {
                              Share.share(currentSong.song_url);
                            },
                            icon: const Icon(Icons.offline_share)),
                      ),
                      const Expanded(
                        child: SizedBox(),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AddSongToSelectedPlaylist(currentSong)),
                              );
                            },
                            icon: const Icon(Icons.playlist_add),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
