import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:noteapp/data/models/user.dart';

// define table names
// const String notesTable = 'notes';
// const String tagsTable = 'tags';
const String profilesTable = 'profiles';

class Local {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static Future<void> init() async {
    await Hive.initFlutter();

    // Hive.registerAdapter(NoteAdapter());
    // Hive.registerAdapter(TagAdapter());
    Hive.registerAdapter(UserAdapter());
    await Hive.openBox<User>(profilesTable);
  }

  // -------- TOKEN --------
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'authToken', value: token);
  }

  Future<String?> getToken() async {
    final token = await _secureStorage.read(key: 'authToken');
    return token;
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'authToken');
  }

  // -------- LAST SYNCED --------
  Future<void> updateLastSynced(String username) async {
    final profiles = Hive.box<User>(profilesTable);
    final user = profiles.get(username);
    if (user != null) {
      await profiles.put(
        username,
        User(username: user.username, lastSynced: DateTime.now().toString()),
      );
    }
  }

  // ----- USERS LIST -----
  Future<String> getCurrentUser() async {
    final token = await getToken();
    if (token == null) {
      return 'default';
    }

    try {
      final payload = token.split('.')[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final username = jsonDecode(decoded)['username'];
      return username;
    } catch (e) {
        print('Error decoding token: $e');
      return 'default';
    }
  }

  Future<void> saveUser({required String username}) async {
    final profiles = Hive.box<User>(profilesTable);
    final existingUser = profiles.get(username);

    await profiles.put(
      username,
      User(username: username, lastSynced: existingUser?.lastSynced),
    ); // key: username, value: User object
  }

  Future<void> deleteUser(String username, bool deleteToken) async {
    final profiles = Hive.box<User>(profilesTable);
    await profiles.delete(username);

    if (deleteToken) {
      await _secureStorage.delete(key: 'authToken');
    }

    // clear user data (notes, tags)

    // have separate boxes for each user's notes.
    // Hive.openBox('notes_$username');
    // -> delete the whole box: await Hive.deleteBox('notes_$username');
  }

  List<User> getUsers() {
    final profiles = Hive.box<User>(profilesTable);
    return profiles.values.toList();
  }

  // ---- NOTES ----

  // ---- TAGS ----
}
