import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;

class ApiClient {
    static String get baseUrl {
        final String host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
        return 'http://'+host+':3000/api/v1';
    }

	// Đăng nhập
	Future<http.Response> login(String username, String password) async {
		final response = await http.post(
			Uri.parse('$baseUrl/auth/login'),
			headers: {'Content-Type': 'application/json'},
			body: jsonEncode({'username': username, 'password': password}),
		);
		return response;
	}

	// Lấy notes trong thùng rác
	Future<List<dynamic>> fetchTrashNotes(String token) async {
		try {
			final response = await http.get(
				Uri.parse('$baseUrl/notes/trash'),
				headers: {'Authorization': 'Bearer $token'},
			);
			
			if (response.statusCode == 200) {
				final dynamic decoded = jsonDecode(response.body);
				print('API Response: $decoded');
				
				if (decoded is Map<String, dynamic>) {
					final dynamic data = decoded['data'];
					if (data is List) {
						return data;
					}
				} else if (decoded is List) {
					return decoded;
				}
				
				print('Unexpected response format: $decoded');
				return [];
			} else {
				print('HTTP Error: ${response.statusCode} - ${response.body}');
				throw Exception('Failed to load trash notes: ${response.statusCode}');
			}
		} catch (e) {
			print('Network error: $e');
			throw Exception('Network error: $e');
		}
	}

	// Xóa note (DELETE /api/v1/notes/id)
	Future<http.Response> deleteNote(String id, String token) async {
		final response = await http.delete(
			Uri.parse('$baseUrl/notes/$id'),
			headers: {'Authorization': 'Bearer $token'},
		);
		return response;
	}

	// Khôi phục note (PUT /api/v1/notes/id/restore)
	Future<http.Response> restoreNote(String id, String token) async {
		final response = await http.put(
			Uri.parse('$baseUrl/notes/$id/restore'),
			headers: {'Authorization': 'Bearer $token'},
		);
		return response;
	}

	// Xóa note trong trash (DELETE /api/v1/notes/trash/id)
	Future<http.Response> deleteTrashNote(String id, String token) async {
		final response = await http.delete(
			Uri.parse('$baseUrl/notes/trash/$id'),
			headers: {'Authorization': 'Bearer $token'},
		);
		return response;
	}
}
