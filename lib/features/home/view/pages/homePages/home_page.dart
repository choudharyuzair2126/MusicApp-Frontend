import 'package:client/core/theme/app_pallet.dart';
import 'package:client/features/home/view/pages/homePages/library_page.dart';
import 'package:client/features/home/view/pages/homePages/upload_sond.dart';
import 'package:client/features/home/view/pages/playlists/show_all_playlists.dart';
import 'package:client/features/home/view/pages/homePages/songs_page.dart';
import 'package:client/features/home/view/widgets/music_slab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int selectedIndex = 0;
  final pages = [
    const SongsPage(),
    const LibraryPage(),
    const ShowAllPlaylists(),
    const UploadSongPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          pages[selectedIndex],
          const Positioned(bottom: 0, child: MusicSlab())
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        showUnselectedLabels: true,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        selectedItemColor: Pallete.whiteColor,
        unselectedItemColor: Pallete.inactiveBottomBarItemColor,
        items: [
          BottomNavigationBarItem(
              icon: Icon(selectedIndex == 0 ? Icons.home : Icons.home_outlined),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(selectedIndex == 1
                  ? Icons.favorite
                  : Icons.favorite_border_outlined),
              label: 'Favorite Songs'),
          BottomNavigationBarItem(
              icon: Icon(selectedIndex == 2
                  ? Icons.library_add
                  : Icons.library_add_outlined),
              label: 'Playlists'),
          BottomNavigationBarItem(
              icon: Icon(selectedIndex == 3
                  ? Icons.upload_file_rounded
                  : Icons.upload_file_outlined),
              label: 'Upload Song'),
        ],
      ),
    );
  }
}
