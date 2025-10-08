import 'package:notes/features/notes/domain/entities/note.dart';
import 'package:notes/features/notes/domain/repositories/note_repositories.dart';

class FetchTrashNotes {
  final NoteRepository repository;

  FetchTrashNotes(this.repository);

  Future<List<Note>> call(String token) {
    return repository.fetchTrashNotes(token);
  }
}


