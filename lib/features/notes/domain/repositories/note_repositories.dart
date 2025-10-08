import 'package:notes/features/notes/domain/entities/note.dart';

abstract class NoteRepository {
  Future<List<Note>> fetchTrashNotes(String token);
  Future<void> deleteNote(String id, String token);
  Future<void> restoreNote(String id, String token);
  Future<void> deleteTrashNote(String id, String token);
}