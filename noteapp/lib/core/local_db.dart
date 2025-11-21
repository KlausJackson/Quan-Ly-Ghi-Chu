import 'package:hive_flutter/hive_flutter.dart';
import 'package:noteapp/features/auth/user_model.dart';
import 'package:noteapp/features/notes/block_model.dart';
import 'package:noteapp/features/notes/note_model.dart';
import 'package:noteapp/features/tags/tag_model.dart';

class LocalDb {
  static const String authBoxName = 'authBox'; // store list of accounts saved on device

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(TagModelAdapter());
    Hive.registerAdapter(BlockModelAdapter());
    Hive.registerAdapter(NoteModelAdapter());

    // Only open the Auth Box globally (to see list of users)
    await Hive.openBox<UserModel>(authBoxName);
  }
}
