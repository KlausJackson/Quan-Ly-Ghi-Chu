import 'package:noteapp/features/notes/domain/entities/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotes();
  Future<List<Note>> getTrashedNotes();
  Future<Note> createNote(Note note);
  Future<Note> updateNote(Note note);
  // send note to server, server sends back the note 
  // (with changes like updatedAt timestamp or trimmed fields)
  // save that note from server to local db
  // because server is source of truth
  Future<void> deleteNote(String uuid);
  Future<void> restoreNote(String uuid);
  Future<void> permanentlyDeleteNote(String uuid);
}
