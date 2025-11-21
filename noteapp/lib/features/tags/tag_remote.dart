import 'package:noteapp/core/api_client.dart';
import 'package:noteapp/features/tags/tag_model.dart';

class TagRemote {
  final ApiClient apiClient;

  TagRemote({required this.apiClient});

  // GET /tags
  Future<List<TagModel>> getTags() async {
    final response = await apiClient.get('/tags');
    final List<dynamic> list = response['data'] ?? [];
    return list.map((e) => TagModel.fromJson(e)).toList();
  }

  // POST /tags
  Future<TagModel> createTag(String uuid, String name) async {
    final response = await apiClient.post('/tags', {
      'uuid': uuid,
      'name': name,
    });
    return TagModel.fromJson(response['data']);
  }

  // PUT /tags/:id (UUID)
  Future<TagModel> updateTag(String uuid, String name) async {
    final response = await apiClient.put('/tags/$uuid', {'name': name});
    return TagModel.fromJson(response['data']);
  }

  // DELETE /tags/:id
  Future<void> deleteTag(String uuid) async {
    await apiClient.delete('/tags/$uuid');
  }
}
