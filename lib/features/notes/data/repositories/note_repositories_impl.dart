import 'package:notes/features/notes/data/datasources/notes_remote_datasources.dart';
import 'package:notes/features/notes/domain/entities/note.dart';
import 'package:notes/features/notes/domain/repositories/note_repositories.dart';
import 'package:notes/features/notes/data/models/note_models.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDataSource remoteDataSource;

  NoteRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Note>> fetchTrashNotes(String token) async {
    try {
      final List<dynamic> jsonList = await remoteDataSource.fetchTrashNotes(token);
      final List<Note> notes = [];
      
      for (final json in jsonList) {
        if (json is Map<String, dynamic>) {
          final note = NoteModel.fromJson(json);
          notes.add(note);
        }
      }
      
      return notes;
    } catch (e) {
      print('Error in fetchTrashNotes: $e');
      return [];
    }
  }

  @override
  Future<void> deleteNote(String id, String token) {
    return remoteDataSource.deleteNote(id, token);
  }

  @override
  Future<void> restoreNote(String id, String token) {
    return remoteDataSource.restoreNote(id, token);
  }

  @override
  Future<void> deleteTrashNote(String id, String token) {
    return remoteDataSource.deleteTrashNote(id, token);
  }
}


