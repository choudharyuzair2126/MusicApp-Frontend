import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/features/home/view/pages/playlists/add_song_to_playlist.dart';
import 'package:flutter/material.dart';

class CreatePlaylist extends StatelessWidget {
  const CreatePlaylist({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController name = TextEditingController();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: name,
              decoration: const InputDecoration(
                labelText: 'Playlist Name',
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          ElevatedButton(
            child: const Text('Create'),
            onPressed: () async {
              if (name.text.trim().isEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                        title: const Text('Error'),
                        content: const Text('Playlist name cannot be empty.'));
                  },
                );
                return;
              }
              int index = await CurrentSongNotifier().createPlaylist(name.text);
              debugPrint('Playlist created successfully!');
              Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddSongToPlaylist(index1: index)));
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            child: const Text('Cancel'),
            onPressed: () {
              // Handle cancel action
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
