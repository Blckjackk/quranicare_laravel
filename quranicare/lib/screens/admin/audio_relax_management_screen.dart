import 'package:flutter/material.dart';

class AudioRelaxManagementScreen extends StatefulWidget {
  const AudioRelaxManagementScreen({super.key});

  @override
  State<AudioRelaxManagementScreen> createState() => _AudioRelaxManagementScreenState();
}

class _AudioRelaxManagementScreenState extends State<AudioRelaxManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        title: const Text('Manajemen Audio Relax'),
        elevation: 2,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              size: 64,
              color: Colors.purple,
            ),
            SizedBox(height: 16),
            Text(
              'Manajemen Audio Relax',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Halaman ini sedang dalam pengembangan',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new audio relax
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}