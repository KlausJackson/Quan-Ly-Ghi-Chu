import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:noteapp/features/notes/note_model.dart';
import 'package:noteapp/features/notes/block_model.dart';
import 'package:noteapp/features/notes/note_provider.dart';
import 'package:noteapp/features/tags/tag_provider.dart';
import 'package:noteapp/features/tags/tag_model.dart';
import 'package:noteapp/presentations/shared_widgets/show_dialogs.dart';
import 'package:noteapp/presentations/screens/notes/widgets/edit_body.dart';

class NoteEditPage extends StatefulWidget {
  // If a note is passed in -> edit mode.
  // If it's null -> create mode.
  final NoteModel? note;
  const NoteEditPage({super.key, this.note});
  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late TextEditingController _titleController;
  // Each block in the body has its own controller.
  late List<TextEditingController> _bodyControllers;
  late List<BlockModel> _bodyBlocks;

  late NoteModel _originalNote; // snapshot
  bool _isChanged = false; // Tracks if there are unsaved changes
  List<String> _selectedTagIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TagProvider>().loadTags();
    });

    if (widget.note != null) {
      // --- EDIT MODE ---
      _originalNote = widget.note!;
      _titleController = TextEditingController(text: _originalNote.title);
      _bodyBlocks = List<BlockModel>.from(
        _originalNote.body.map((b) => b.copyWith()),
      ); // Create a mutable copy
      _selectedTagIds = List.from(_originalNote.tagIds);
    } else {
      // --- CREATE MODE ---
      _originalNote = NoteModel(
        id: const Uuid().v4(),
        isPinned: false,
        title: '',
        body: [BlockModel(type: 'text', text: '', checked: false)],
        isDeleted: false,
        tagIds: [],
        updatedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
      _titleController = TextEditingController();
      // Start with one empty text block.
      _bodyBlocks = [BlockModel(type: 'text', text: '', checked: false)];
      _selectedTagIds = [];
      _isChanged = true; // New note, always "changed"
    }

    // Create a TextEditingController for each block.
    _bodyControllers = _bodyBlocks
        .map((block) => TextEditingController(text: block.text))
        .toList();

    _titleController.addListener(_checkForChanges);
    for (var controller in _bodyControllers) {
      controller.addListener(_checkForChanges);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _bodyControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _checkForChanges() {
    bool hasChanges = false;

    // Compare title and body with the original note.
    if (_titleController.text != _originalNote.title) hasChanges = true;
    for (int i = 0; i < _bodyControllers.length; i++) {
      // INDEX OUT OF RANGE CHECKS
      if (_bodyControllers.length != _originalNote.body.length) {
        hasChanges = true;
        break;
      } // number of blocks changed
      if (i >= _originalNote.body.length) {
        hasChanges = true;
        break;
      } // extra blocks added

      // COMPARE CONTENT
      if (_bodyControllers[i].text != _originalNote.body[i].text) {
        hasChanges = true;
      } // text changed
      if (_bodyBlocks[i].checked != _originalNote.body[i].checked) {
        hasChanges = true;
      } // checkbox state changed
    }

    if (!_areListsEqual(_selectedTagIds, _originalNote.tagIds)) {
      hasChanges = true;
    }

    // If has changedes state differs, update it.
    if (hasChanges != _isChanged) {
      setState(() {
        _isChanged = hasChanges;
      });
    }
  } // called on every keystroke

  bool _areListsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    return Set.from(a).containsAll(b);
  }

  Future<void> _saveNote() async {
    for (int i = 0; i < _bodyBlocks.length; i++) {
      _bodyBlocks[i] = BlockModel(
        type: _bodyBlocks[i].type,
        text: _bodyControllers[i].text,
        checked: _bodyBlocks[i].checked,
      );
    } // Update _bodyBlocks with text from controllers.

    final noteToSave = NoteModel(
      id: _originalNote.id,
      title: _titleController.text.trim(),
      body: _bodyBlocks,
      isPinned: _originalNote.isPinned,
      isDeleted: false,
      tagIds: _selectedTagIds,
      updatedAt: DateTime.now(),
      createdAt: _originalNote.createdAt,
    );

    final provider = context.read<NoteProvider>();
    if (widget.note != null) {
      await provider.updateNote(noteToSave);
    } else {
      await provider.createNote(noteToSave);
    }
    // if (mounted) {
    //   Navigator.of(context).pop(true); // exit edit page
    // }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not synced yet';
    final formatted =
        '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    return formatted;
  }

  void _deleteNote() {
    if (widget.note != null) {
      ShowDialogs.showConfirmationDialog(
        context: context,
        title: 'Delete Note?',
        message: 'Are you sure you want to delete this note?',
        confirmText: 'Delete',
        onConfirm: () async {
          await context.read<NoteProvider>().deleteNote(widget.note!);
          if (mounted) {
            Navigator.of(
              context,
            ).pop(true); // Indicate that a deletion occurred
          }
        },
      );
    }
  }

  
  // --- TAG SELECTION DIALOG ---
  void _showTagSelectionDialog() {
    final allTags = context.read<TagProvider>().tags;

    // Create a temporary set to track changes inside the dialog
    final List<String> tempSelectedTags = List.from(_selectedTagIds);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          // Needed to update state inside dialog
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Gán thẻ'),
              content: SizedBox(
                width: double.maxFinite,
                child: allTags.isEmpty
                    ? const Text('Chưa có thẻ nào. Hãy tạo thẻ ở trang Thẻ.')
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: allTags.length,
                        itemBuilder: (context, index) {
                          final tag = allTags[index];
                          final isSelected = tempSelectedTags.contains(tag.id);

                          return CheckboxListTile(
                            title: Text(tag.name),
                            value: isSelected,
                            onChanged: (bool? checked) {
                              setStateDialog(() {
                                if (checked == true) {
                                  tempSelectedTags.add(tag.id);
                                } else {
                                  tempSelectedTags.remove(tag.id);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTagIds = tempSelectedTags;
                    });
                    _checkForChanges(); // Re-check save button state
                    Navigator.pop(ctx);
                  },
                  child: const Text('Xong'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper to look up tag names for chips
  TagModel? _getTagById(String id) {
    final tags = context.read<TagProvider>().tags;
    try {
      return tags.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 16.0,
          children: [
            Text(
              widget.note != null ? 'Edit Note' : 'Create Note',
              style: const TextStyle(fontSize: 16),
            ),
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
              onPressed: _deleteNote,
            ),
          // --- SAVE BUTTON ---
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isChanged ? _saveNote : null,
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
                hintText: 'Title...',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            if (_selectedTagIds.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _selectedTagIds.map((id) {
                  final tag = _getTagById(id);
                  if (tag == null) return const SizedBox();
                  return InputChip(
                    label: Text(tag.name),
                    onDeleted: () {
                      setState(() {
                        _selectedTagIds.remove(id);
                      });
                      _checkForChanges();
                    },
                  );
                }).toList(),
              ),

            const SizedBox(height: 5),
            const Divider(height: 1),
            const SizedBox(height: 5),
            // --- DYNAMIC BODY BLOCKS ---
            Expanded(
              child: NoteBodyEditor(
                initialBlocks: _bodyBlocks,
                bodyControllers: _bodyControllers,
                onChanged: _checkForChanges,
                onManageTags: _showTagSelectionDialog
              ),
            ),
          ],
        ),
      ),
    );
  }
}
