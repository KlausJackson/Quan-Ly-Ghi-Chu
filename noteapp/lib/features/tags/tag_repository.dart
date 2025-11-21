import 'package:uuid/uuid.dart';
import 'package:noteapp/core/network_info.dart';
import 'package:noteapp/features/auth/auth_local.dart';
import 'package:noteapp/features/tags/tag_local.dart';
import 'package:noteapp/features/tags/tag_model.dart';
import 'package:noteapp/features/tags/tag_remote.dart';

class TagRepository {
  final TagRemote remote;
  final TagLocal local;
  final AuthLocal authLocal;
  final Uuid _uuidGenerator = const Uuid();

  TagRepository({
    required this.remote,
    required this.local,
    required this.authLocal,
  });

  Future<String> _getCurrentUser() async {
    return await authLocal.getCurrentUser() ?? 'default';
  }

  // --- GET TAGS ---
  Future<List<TagModel>> getTags() async {
    String currentUser = await _getCurrentUser();
    List<TagModel> localTags = await local.getTags(currentUser);

    // If Default User or Offline -> Return Local
    if (currentUser == 'default' ||
        !(await NetworkInfo.isConnected)) {
      return localTags;
    }

    // If Logged In & Online -> SYNC
    try {
      final remoteTags = await remote.getTags();

      // 1. Server has it, Local doesn't OR Name mismatch -> Update Local (Server is always right)
      for (var rTag in remoteTags) {
        final lTag = localTags.firstWhere(
          (l) => l.id == rTag.id, // match by ID
          orElse: () => TagModel(
            id: 'missing',
            name: '',
          ), // Create a new tag with the same ID but empty name
        ); // If not found, return a dummy tag

        // If missing locally OR name is different
        if (lTag.id == 'missing' || lTag.name != rTag.name) {
          await local.saveTag(currentUser, rTag);
        }
      }

      // 2. Local has it, Server doesn't -> Add to Server
      for (var lTag in localTags) {
        final existsOnRemote = remoteTags.any(
          (r) => r.id == lTag.id,
        ); // Check if tag exists on server
        if (!existsOnRemote) {
          try {
            await remote.createTag(lTag.id, lTag.name);
          } catch (e) {
            // Ignore failure
          }
        }
      }

      // 3. Reload local to get the final merged list
      return local.getTags(currentUser);
    } catch (e) {
      return localTags;
    } // return local if remote fetch fails
  }

  // --- CREATE ---
  Future<void> createTag(String name) async {
    final currentUser = await _getCurrentUser();
    final uuid = _uuidGenerator.v4();
    final newTag = TagModel(id: uuid, name: name);

    if (currentUser == 'default' ||
        !(await NetworkInfo.isConnected)) {
      await local.saveTag(currentUser, newTag);
      return;
    }

    try {
      final serverTag = await remote.createTag(uuid, name);
      await local.saveTag(currentUser, serverTag); // Save server response
    } catch (e) {
      rethrow; // If server fails, don't save locally
    }
  }

  // --- UPDATE ---
  Future<void> updateTag(String uuid, String newName) async {
    final currentUser = await _getCurrentUser();
    final tag = TagModel(id: uuid, name: newName);

    if (currentUser == 'default' ||
        !(await NetworkInfo.isConnected)) {
      await local.saveTag(currentUser, tag);
      return;
    }

    try {
      final serverTag = await remote.updateTag(uuid, newName);
      await local.saveTag(currentUser, serverTag);
    } catch (e) {
      rethrow;
    }
  }

  // --- DELETE ---
  Future<void> deleteTag(String uuid) async {
    final currentUser = await _getCurrentUser();

    if (currentUser == 'default' ||
        !(await NetworkInfo.isConnected)) {
      await local.deleteTag(currentUser, uuid);
      return;
    }

    try {
      await remote.deleteTag(uuid);
      await local.deleteTag(currentUser, uuid);
    } catch (e) {
      rethrow;
    }
  }
}
