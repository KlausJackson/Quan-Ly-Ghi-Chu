import 'package:flutter/material.dart';
import 'package:noteapp/features/notes/presentation/widgets/edit_body.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:noteapp/features/notes/domain/entities/note.dart';
import 'package:noteapp/features/notes/domain/entities/block.dart';
import 'package:noteapp/features/notes/presentation/provider/note_provider.dart';
import 'package:noteapp/presentation/widgets/show_dialogs.dart';

class NoteEditPage extends StatefulWidget {
  // If a note is passed in -> edit mode.
  // If it's null -> create mode.
  final Note? note;
  const NoteEditPage({super.key, this.note});
  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late TextEditingController _titleController;
  // Each block in the body has its own controller.
  late List<TextEditingController> _bodyControllers;
  late List<Block> _bodyBlocks;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      // --- EDIT MODE ---
      _titleController = TextEditingController(text: widget.note!.title);
      _bodyBlocks = List<Block>.from(
        widget.note!.body,
      ); // Create a mutable copy
    } else {
      // --- CREATE MODE ---
      _titleController = TextEditingController();
      // Start with one empty text block.
      _bodyBlocks = [Block(type: 'text', text: '', checked: false)];
    }

    // Create a TextEditingController for each block.
    _bodyControllers = _bodyBlocks
        .map((block) => TextEditingController(text: block.text))
        .toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _bodyControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Chua cap nhat';
    final formatted =
        '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    return formatted;
  }

  void _saveNote() {
    for (int i = 0; i < _bodyBlocks.length; i++) {
      _bodyBlocks[i] = Block(
        type: _bodyBlocks[i].type,
        text: _bodyControllers[i].text,
        checked: _bodyBlocks[i].checked,
      );
    } // Update _bodyBlocks with text from controllers.

    final noteToSave = Note(
      // Use existing UUID if editing, generate new one if creating.
      uuid: widget.note?.uuid ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      body: _bodyBlocks,
      isPinned: false,
      isDeleted: false,
      tagUUIDs: [],
      updatedAt: DateTime.now(),
    );

    final provider = context.read<NoteProvider>();
    if (widget.note != null) {
      provider.updateNote(noteToSave);
    } else {
      provider.createNote(noteToSave);
    }
  }

  void _deleteNote() {
    if (widget.note != null) {
      ShowDialogs.showConfirmationDialog(
        context: context,
        title: 'Xoa ghi chu?',
        message: 'Ban co chac chan muon xoa khong?',
        confirmText: 'Xoa',
        onConfirm: () {
          context.read<NoteProvider>().deleteNote(widget.note!.uuid);
          Navigator.of(context).pop(true);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 32.0,
          children: [
            Text(widget.note != null ? 'Chinh sua ghi chu' : 'Tao ghi chu', style: const TextStyle(fontSize: 16)),
            if (widget.note != null) // Show last updated time in edit mode
              Text(
                _formatDateTime(widget.note?.updatedAt),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        actions: [
          // --- DELETE BUTTON (only shown in edit mode) ---
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Xoa',
              onPressed: _deleteNote,
            ),
          // --- SAVE BUTTON ---
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Luu',
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0),
        child: Column(
          children: [
            // --- TITLE FIELD ---
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Tieu de...',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),
            const Divider(height: 1),
            const SizedBox(height: 5),
            // --- DYNAMIC BODY BLOCKS ---
            Expanded(
              child: NoteBodyEditor(
                initialBlocks: _bodyBlocks,
                bodyControllers: _bodyControllers,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
