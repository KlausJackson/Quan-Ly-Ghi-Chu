import 'package:flutter/material.dart';
import 'package:noteapp/features/auth/auth_repository.dart';
import 'package:noteapp/features/auth/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;

  AuthProvider(this._repo) {
    loadSavedUsers();
    setCurrentUser();
  }

  bool isLoading = false;
  List<UserModel> savedUsers = [];
  String currentUser = 'Default';

  Future<void> setCurrentUser() async {
    currentUser = await _repo.getCurrentUser() ?? 'Default';
    notifyListeners();
  }

  Future<void> loadSavedUsers() async {
    savedUsers = await _repo.getSavedUsers();
    notifyListeners();
  }

  // Returns String? error. If null, success.
  Future<String?> login(String username, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repo.login(username: username, password: password);
      await loadSavedUsers();
      return null; // Success
    } catch (e) {
      return e.toString(); // Return error message
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> register(String username, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repo.register(username: username, password: password);
      await loadSavedUsers();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    notifyListeners();
  }

  Future<void> deleteLocalUser(String username) async {
    await _repo.deleteLocalUser(username);
    await loadSavedUsers();
  }

  Future<String?> deleteAccount(String password) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repo.deleteAccount(password);
      await loadSavedUsers();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
