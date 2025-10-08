import 'package:notes/core/network/api_client.dart';

class NoteRemoteDataSource {
	final ApiClient apiClient;

	NoteRemoteDataSource(this.apiClient);

	Future<List<dynamic>> fetchTrashNotes(String token) {
		return apiClient.fetchTrashNotes(token);
	}

	Future<void> deleteNote(String id, String token) async {
		await apiClient.deleteNote(id, token);
	}

	Future<void> restoreNote(String id, String token) async {
		await apiClient.restoreNote(id, token);
	}

	Future<void> deleteTrashNote(String id, String token) async {
		await apiClient.deleteTrashNote(id, token);
	}
}
