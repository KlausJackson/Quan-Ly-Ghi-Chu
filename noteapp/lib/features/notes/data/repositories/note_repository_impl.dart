import 'package:noteapp/core/network/network_info.dart';
import 'package:noteapp/features/auth/data/datasources/auth_local.dart';
import 'package:noteapp/features/notes/data/datasources/note_local.dart';
import 'package:noteapp/features/notes/data/datasources/note_remote.dart';
import 'package:noteapp/features/notes/data/models/block_model.dart';
import 'package:noteapp/features/notes/data/models/note_model.dart';
import 'package:noteapp/features/notes/domain/entities/note.dart';
import 'package:noteapp/features/notes/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemote noteRemote;
  final NoteLocal noteLocal;
  final AuthLocal authLocal;
  final NetworkInfo networkInfo;

  NoteRepositoryImpl({
    required this.noteRemote,
    required this.noteLocal,
    required this.authLocal,
    required this.networkInfo
  });

  Future<String> _getCurrentUser() async {
    final user = await authLocal.getCurrentUser();
    return user ?? 'default';
  }

 // Future<


  @override
  Future<Note> createNote(Note note) async {
    final user = await _getCurrentUser();

    final noteModel = NoteModel(
      uuid: note.uuid,
      title: note.title,
      body: note.body
          .map(
            (b) => BlockModel(type: b.type, text: b.text, checked: b.checked),
          )
          .toList(),
      isPinned: note.isPinned,
      tagUUIDs: note.tagUUIDs,
      isDeleted: note.isDeleted,
      updatedAt: DateTime.now()
    );

    // send to server first
    // declare noteToSave = noteModel
    // if block: if succeeds, noteToSave = server response
    // save noteToSave to local

    NoteModel noteToSave = noteModel;
    if (await networkInfo.isConnected) {
        try {
            noteToSave = await noteRemote.createNote(noteModel);
        } catch (e) {
           // print("API createNote failed, relying on local save: $e");
        }
    }
   // await noteLocal.cacheNote(user, noteToSave);
    return noteToSave;
  }

  @override
  Future<Note> updateNote(Note note) async {
    final user = await _getCurrentUser();

    final noteModel = NoteModel(
      uuid: note.uuid,
      title: note.title,
      body: note.body.map(
        (b) => BlockModel(type: b.type, text: b.text, checked: b.checked),
      ).toList(),
      isPinned: note.isPinned,
      tagUUIDs: note.tagUUIDs,
      isDeleted: note.isDeleted,
      updatedAt: DateTime.now(),
    );

    // Save locally first
   // await noteLocal.cacheNote(user, noteModel);

    try {
    //  final updatedNoteFromServer = await noteRemote.updateNote(noteModel);
     // await noteLocal.cacheNote(user, updatedNoteFromServer);
     // return updatedNoteFromServer;
    } catch (e) {
      print("API updateNote failed, relying on local save: $e");
      return noteModel;
    }
  }

  @override
  Future<List<Note>> getNotes() async {
    // implement search, filter, sort, pagination for remote and local
    // add parameters to this function : query, filter (tags), sort, page, pageSize
    // copy getNotes in controller backend
    final user = await _getCurrentUser();
    // TODO: If online, fetch from remote and update local cache.
    return await noteLocal.getNotes(user);
  }


    // DELETE, PERMANENT DELETE, RESTORE, GET TRASHED
  @override
  Future<void> deleteNote(String uuid) async {}

  @override
  Future<void> permanentlyDeleteNote(String uuid) async {}

    @override
    Future<List<Note>> getTrashedNotes() async {
        return [];
    }
    @override
    Future<void> restoreNote(String uuid) async {}

}
