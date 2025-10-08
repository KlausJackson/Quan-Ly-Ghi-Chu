import 'package:notes/features/notes/domain/repositories/note_repositories.dart';

class DeleteTrashNote {
  final NoteRepository repository;

  DeleteTrashNote(this.repository);

  Future<void> call(String id, String token) {
    return repository.deleteTrashNote(id, token);
  }
}


