import 'package:noteapp/core/api_client.dart';
import 'package:noteapp/features/notes/note_model.dart';

class NoteRemote {
  final ApiClient apiClient;
  NoteRemote({required this.apiClient});

  Future<Map<String, dynamic>> getNotes(
    Map<String, dynamic> queryParams,
  ) async {
    return await apiClient.get('/notes', queryParameters: queryParams);
  }

  Future<NoteModel> createNote(NoteModel note) async {
    final response = await apiClient.post('/notes', note.toJson());
    return NoteModel.fromJson(response['data']);
  }

  Future<NoteModel> updateNote(NoteModel note) async {
    final response = await apiClient.put('/notes/${note.id}', note.toJson());
    return NoteModel.fromJson(response['data']);
  }

  Future<void> deleteNote(String uuid) async {
    await apiClient.delete('/notes/$uuid');
  }

  Future<List<NoteModel>> getTrashedNotes() async {
    final response = await apiClient.get('/notes/trash');
    return (response['data'] as List).map((note) => NoteModel.fromJson(note)).toList();
  }

  Future<void> restoreNote(String uuid) async {
    await apiClient.put('/notes/$uuid/restore', {});
  }

  Future<void> permanentlyDeleteNote(String uuid) async {
    await apiClient.delete('/notes/trash/$uuid');
  }

  Future<Map<String, dynamic>> syncNotes(Map<String, dynamic> syncData) async {
    return await apiClient.post('/sync', syncData);
  }
}
