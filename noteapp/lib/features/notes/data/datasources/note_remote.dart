import 'package:noteapp/core/network/api_client.dart';
import 'package:noteapp/features/notes/data/models/note_model.dart';

class NoteRemote {
  final ApiClient apiClient;
  NoteRemote({required this.apiClient});

  Future<List<NoteModel>> getNotes() async {
    final response = await apiClient.get('/notes');
    return (response['data'] as List)
        .map((json) => NoteModel.fromJson(json))
        .toList();
  }

  Future<NoteModel> createNote(NoteModel note) async {
    final response = await apiClient.post('/notes', note.toJson());
    return NoteModel.fromJson(response['data']);
  }

  // TODO: Implement updateNote, deleteNote, getTrashedNotes, etc.
}
