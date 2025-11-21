import 'package:flutter/material.dart';
import 'package:noteapp/features/notes/note_model.dart';
import 'package:noteapp/features/notes/note_repository.dart';

enum NoteStatus { initial, loading, success, failure }

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repo;

  NoteProvider(this._repo);

  // --- STATE ---
  NoteStatus _status = NoteStatus.initial;
  List<NoteModel> _notes = [];
  List<NoteModel> _trashedNotes = [];
  int _totalNotes = 0;
  String? _message;

  // --- GETTERS ---
  NoteStatus get status => _status;
  List<NoteModel> get notes => _notes;
  List<NoteModel> get trashedNotes => _trashedNotes;
  int get totalNotes => _totalNotes;

  // Returns the message once, then clears it
  String? get popMessage {
    final msg = _message;
    _message = null;
    return msg;
  }

    // Count notes associated with a specific tag
  int countNotesByTag(String tagId) {
    return _notes.where((note) => note.tagIds.contains(tagId)).length;
  }

  // --- ACTIONS ---

  Future<void> getNotes(
    String? query,
    String sortBy,
    int sortOrder,
    int page,
    int pageSize,
  ) async {
    if (page == 1) _status = NoteStatus.loading;
    notifyListeners();

    try {
      final result = await _repo.getNotes(
        query,
        sortBy,
        sortOrder,
        page,
        pageSize,
      );
      _notes = result['notes'] as List<NoteModel>;
      _totalNotes = result['total'] as int;
      _status = NoteStatus.success;
    } catch (e) {
      _status = NoteStatus.failure;
      _message = "Error: $e";
    }
    notifyListeners();
  }

  Future<void> createNote(NoteModel note) async {
    try {
      await _repo.createNote(note);
      _message = "Note created successfully";
    } catch (e) {
      _message = "Error creating note: $e";
    }
    notifyListeners();
  }

  Future<void> updateNote(NoteModel note) async {
    try {
      await _repo.updateNote(note);
      _message = "Changes saved";
    } catch (e) {
      _message = "Error updating note: $e";
    }
    notifyListeners();
  }

  Future<void> deleteNote(NoteModel note) async {
    try {
      await _repo.deleteNote(note);
      _notes.removeWhere((n) => n.id == note.id); // Remove from UI immediately
      _message = "Moved to trash";
    } catch (e) {
      _message = "Error deleting note: $e";
    }
    notifyListeners();
  }

  // --- TRASH & RESTORE ---

  Future<void> getTrashedNotes() async {
    _status = NoteStatus.loading;
    notifyListeners();
    try {
      _trashedNotes = await _repo.getTrashedNotes();
      _status = NoteStatus.success;
    } catch (e) {
      _status = NoteStatus.failure;
      _message = "Error loading trashed notes: $e";
    }
    notifyListeners();
  }

  Future<void> restoreNote(NoteModel note) async {
    try {
      await _repo.restoreNote(note);
      _trashedNotes.removeWhere((n) => n.id == note.id);
      _message = "Note restored";
    } catch (e) {
      _message = "Error restoring note: $e";
    }
    notifyListeners();
  }

  Future<void> permanentlyDeleteNote(NoteModel note) async {
    try {
      final success = await _repo.permanentlyDeleteNote(note);
      if (success) {
        _trashedNotes.removeWhere((n) => n.id == note.id);
        _message = "Permanently deleted";
      } else {
        _message = "Cannot delete (Possibly offline)";
      }
    } catch (e) {
      _message = "Error: $e";
    }
    notifyListeners();
  }

  Future<void> performSync() async {
    try {
      final success = await _repo.syncNotes();
      if (success) {
        _message = "Sync successful";
        // await getNotes(null, 'updatedAt', -1, 1, 20); // Refresh notes
      }
    } catch (e) {
      _message = "Error syncing notes: $e";
    }
    notifyListeners();
  }
}
