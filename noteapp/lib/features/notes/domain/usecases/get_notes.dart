import 'package:noteapp/features/notes/domain/entities/note.dart';
import 'package:noteapp/features/notes/domain/repositories/note_repository.dart';

class GetNotes {
  final NoteRepository noteRepository;
  GetNotes({required this.noteRepository});

  Future<List<Note>> call() async {
    return await noteRepository.getNotes();
  }
}
