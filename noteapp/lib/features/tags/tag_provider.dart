import 'package:flutter/material.dart';
import 'package:noteapp/features/tags/tag_model.dart';
import 'package:noteapp/features/tags/tag_repository.dart';

class TagProvider extends ChangeNotifier {
  final TagRepository _repo;

  TagProvider(this._repo);

  List<TagModel> _tags = [];
  bool _isLoading = false;

  List<TagModel> get tags => _tags;
  bool get isLoading => _isLoading;

  Future<void> loadTags() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tags = await _repo.getTags();
    } catch (e) {
      print("Error loading tags: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createTag(String name) async {
    try {
      await _repo.createTag(name);
      await loadTags(); // Refresh list
      return null; // Success
    } catch (e) {
      return "Error creating tag: $e";
    }
  }

  Future<String?> updateTag(String uuid, String newName) async {
    try {
      await _repo.updateTag(uuid, newName);
      await loadTags();
      return null;
    } catch (e) {
      return "Error updating tag: $e";
    }
  }

  Future<String?> deleteTag(String uuid) async {
    try {
      await _repo.deleteTag(uuid);
      await loadTags();
      return null;
    } catch (e) {
      return "Error deleting tag: $e";
    }
  }
}
