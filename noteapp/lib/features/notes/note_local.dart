import 'package:hive/hive.dart';
import 'package:noteapp/features/notes/note_model.dart';

class NoteLocal {
  Future<Box<NoteModel>> _getBox(String user) async {
    return await Hive.openBox<NoteModel>('notes_$user');
  }
  
  Future<List<NoteModel>> getNotes(String user) async {
    final box = await _getBox(user);
    return box.values.toList();
  }

  Future<void> saveNote(String user, NoteModel note) async {
    final box = await _getBox(user);
    await box.put(note.id, note);
  }

  Future<void> saveNotes(String user, List<NoteModel> notes) async {
    final box = await _getBox(user);
    final Map<String, NoteModel> entries = {for (var n in notes) n.id: n};
    await box.putAll(entries);
  }

  Future<void> deleteNote(String user, String uuid) async {
    final box = await _getBox(user);
    await box.delete(uuid);
  }

    Future<void> deleteUserBox(String user) async {
    // Check if box is open, if so, close and delete
    if (Hive.isBoxOpen('notes_$user')) {
      await Hive.box<NoteModel>('notes_$user').deleteFromDisk();
    } else {
      await Hive.deleteBoxFromDisk('notes_$user');
    }
  }
}
