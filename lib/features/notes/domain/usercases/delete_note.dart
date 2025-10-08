import 'package:notes/features/notes/domain/repositories/note_repositories.dart';

class DeleteNote {
  final NoteRepository repository;

  DeleteNote(this.repository);

  Future<void> call(String id, String token) {
    return repository.deleteNote(id, token);
  }
}