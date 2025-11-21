import 'package:hive/hive.dart';
import 'package:noteapp/features/tags/tag_model.dart';

class TagLocal {
  Future<Box<TagModel>> _getBox(String user) async {
    return await Hive.openBox<TagModel>('tags_$user');
  }

  Future<List<TagModel>> getTags(String user) async {
    final box = await _getBox(user);
    return box.values.toList();
  }

  Future<void> saveTag(String user, TagModel tag) async {
    final box = await _getBox(user);
    await box.put(tag.id, tag);
  }

  Future<void> saveTags(String user, List<TagModel> tags) async {
    final box = await _getBox(user);
    final Map<String, TagModel> entries = {for (var t in tags) t.id: t};
    await box.putAll(entries);
  }

  Future<void> deleteTag(String user, String uuid) async {
    final box = await _getBox(user);
    await box.delete(uuid);
  }

  Future<void> deleteUserBox(String user) async {
    if (Hive.isBoxOpen('tags_$user')) {
      await Hive.box<TagModel>('tags_$user').deleteFromDisk();
    } else {
      await Hive.deleteBoxFromDisk('tags_$user');
    }
  }
}
