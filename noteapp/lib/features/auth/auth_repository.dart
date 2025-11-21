import 'package:noteapp/features/auth/auth_local.dart';
import 'package:noteapp/features/auth/auth_remote.dart';
import 'package:noteapp/features/auth/user_model.dart';
import 'package:noteapp/features/notes/note_local.dart';
import 'package:noteapp/features/tags/tag_local.dart';

class AuthRepository {
  final AuthRemote remote;
  final AuthLocal local;
  final NoteLocal noteLocal;
  final TagLocal tagLocal;

  AuthRepository({
    required this.remote,
    required this.local,
    required this.noteLocal,
    required this.tagLocal,
  });

  // --- AUTHENTICATION LOGIC ---
  //   Future<void> authenticate({
  //     required Future<Map<String, dynamic>> Function({
  //       required String username,
  //       required String password,
  //     })
  //     action,
  //     required String username,
  //     required String password,
  //   }) async {
  //     final response = await action(
  //       username: username,
  //       password: password,
  //     );
  //     final token = response['data'];
  //     await _saveSession(username, token);
  //   }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    // await authenticate(
    //   action: remote.login,
    //   username: username,
    //   password: password,
    // );
    final response = await remote.login(username: username, password: password);
    final token = response['data'];
    await _saveSession(username, token);
  }

  Future<void> register({
    required String username,
    required String password,
  }) async {
    final response = await remote.register(
      username: username,
      password: password,
    );
    final token = response['data'];
    await _saveSession(username, token);
  }

  Future<void> _saveSession(String username, String token) async {
    await local.saveToken(token);
    final user = UserModel(username: username, lastSynced: null);
    await local.saveUser(user);
    await local.saveCurrentUser(username);
  }

  Future<void> logout() async {
    await local.deleteToken();
    await local.deleteCurrentUser();
  }

  // --- ACCOUNT MANAGEMENT ---

  Future<void> deleteAccount(String password) async {
    await remote.deleteAccount(password: password); // Delete from server
    final currentUser = await local.getCurrentUser();
    if (currentUser != null) {
      await deleteLocalUserData(currentUser);
      await logout(); // Remove token and current user
    } // Clean up local session
  }

  // Removes a user from the local "Switch Account" list
  Future<void> deleteLocalUser(String username) async {
    await deleteLocalUserData(username);
    // If we deleted the user we are currently logged in as, force logout
    final currentUser = await local.getCurrentUser();
    if (currentUser == username) {
      await logout(); // Remove token and current user
    }
  }

   Future<void> deleteLocalUserData(String username) async {
    // Delete user data from local storage (notes and tags boxes)
    await noteLocal.deleteUserBox(username);
    await tagLocal.deleteUserBox(username);
    await local.deleteSavedUser(username);
  }

  // --- DATA RETRIEVAL ---

  Future<List<UserModel>> getSavedUsers() async {
    return local.getUsers();
  }

  Future<String?> getCurrentUser() async {
    return local.getCurrentUser();
  }

}
