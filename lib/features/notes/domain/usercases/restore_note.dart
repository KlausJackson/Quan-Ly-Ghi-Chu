import 'package:notes/features/notes/domain/repositories/note_repositories.dart';

class RestoreNote {
  final NoteRepository repository;

  RestoreNote(this.repository);

  Future<void> call(String id, String token) {
    return repository.restoreNote(id, token);
  }
}


