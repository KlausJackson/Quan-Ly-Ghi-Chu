import 'package:flutter/material.dart';
import 'package:notes/features/notes/domain/entities/note.dart';

class NoteDetailPage extends StatelessWidget {
  final Note note;

  const NoteDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem ghi chú'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Tạo: ' + note.createdAt.toString(), style: const TextStyle(color: Colors.white54)),
                const SizedBox(height: 6),
                Text('Cập nhật: ' + note.updatedAt.toString(), style: const TextStyle(color: Colors.white54)),
                const SizedBox(height: 18),
                Text(note.content, style: const TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
