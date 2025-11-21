import 'package:noteapp/core/network_info.dart';
import 'package:noteapp/features/auth/auth_local.dart';
import 'package:noteapp/features/notes/note_local.dart';
import 'package:noteapp/features/notes/note_remote.dart';
import 'package:noteapp/features/notes/block_model.dart';
import 'package:noteapp/features/notes/note_model.dart';
import 'package:noteapp/features/tags/tag_local.dart';
import 'package:noteapp/features/tags/tag_model.dart';

class NoteRepository {
  final NoteRemote remote;
  final NoteLocal local;
  final AuthLocal authLocal;
  final TagLocal tagLocal; // to save extracted tags

  NoteRepository({
    required this.remote,
    required this.local,
    required this.authLocal,
    required this.tagLocal,
  });

  Future<String> _getCurrentUser() async {
    return await authLocal.getCurrentUser() ?? 'default';
  }

  List<NoteModel> _filterAndSortLocalNotes(
    List<NoteModel> notes, {
    String? query,
    String sortBy = 'updatedAt',
    int sortOrder = 1,
    int page = 1,
    int pageSize = 20,
    bool isDeleted = false,
  }) {
    List<NoteModel> filteredNotes = notes
        .where((note) => note.isDeleted == isDeleted)
        .toList();

    if (filteredNotes.isEmpty) return [];

    // 1. FILTERING
    if (query != null && query.isNotEmpty) {
      final lowerCaseQuery = query.toLowerCase();
      filteredNotes = filteredNotes.where((note) {
        final titleMatch = note.title.toLowerCase().contains(lowerCaseQuery);
        final bodyMatch = note.body.any(
          (block) => block.text.toLowerCase().contains(lowerCaseQuery),
        );
        return titleMatch || bodyMatch;
      }).toList();
    }

    // 2. SORTING
    filteredNotes.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case 'title':
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case 'updatedAt':
        default:
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
      }
      return sortOrder == 1 ? -comparison : comparison;
    });

    // 3. PAGINATION
    final startIndex = (page - 1) * pageSize;
    if (startIndex >= filteredNotes.length) return [];
    final endIndex = (startIndex + pageSize > filteredNotes.length)
        ? filteredNotes.length
        : startIndex + pageSize;
    return filteredNotes.sublist(startIndex, endIndex);
  }

  Future<NoteModel> _action(
    NoteModel note,
    Future<NoteModel> Function(NoteModel) apiCall,
  ) async {
    final user = await _getCurrentUser();

    final noteModel = NoteModel(
      id: note.id,
      title: note.title,
      body: note.body
          .map(
            (b) => BlockModel(type: b.type, text: b.text, checked: b.checked),
          )
          .toList(),
      isPinned: note.isPinned,
      tagIds: note.tagIds,
      isDeleted: note.isDeleted,
      createdAt: note.createdAt,
      updatedAt: DateTime.now(), // overwritten by server if online
    );

    // --- LOGIC ---
    // send to server first
    // declare noteToSave = noteModel
    // if block: if succeeds, noteToSave = server response
    // save noteToSave to local

    NoteModel noteToSave = noteModel;

    if (await NetworkInfo.isConnected && user != 'default') {
      try {
        noteToSave = await apiCall(noteModel);
        await authLocal.updateLastSynced(
          user,
          DateTime.now().toIso8601String(),
        );
      } catch (e) {
        // Fail
      }
    }
    await local.saveNote(user, noteToSave);
    return noteToSave;
  }

  Future<NoteModel> createNote(NoteModel note) async {
    return _action(note, remote.createNote);
  }

  Future<NoteModel> updateNote(NoteModel note) async {
    return _action(note, remote.updateNote);
  }

  // --- GET NOTES ---
  Future<Map<String, dynamic>> getNotes(
    String? query,
    String sortBy,
    int sortOrder,
    int page,
    int pageSize,
  ) async {
    final user = await _getCurrentUser();

    if (await NetworkInfo.isConnected && user != 'default') {
      try {
        Map<String, dynamic> queryParameters = {
          'keywords': query ?? '',
          'sortBy': '$sortBy:${sortOrder == 1 ? 'desc' : 'asc'}',
          'skip': (page - 1) * pageSize,
          'limit': pageSize,
        };

        final result = await remote.getNotes(queryParameters);
        final List<dynamic> rawList = result['notes'] ?? [];

        // --- Extract Tags from Note ---
        for (var noteJson in rawList) {
          if (noteJson['tagUUIDs'] is List) {
            for (var tagItem in noteJson['tagUUIDs']) {
              // If backend populated it: {uuid: "...", name: "..."}
              if (tagItem is Map && tagItem['uuid'] != null) {
                await tagLocal.saveTag(
                  user,
                  TagModel(
                    id: tagItem['uuid'],
                    name: tagItem['name'] ?? 'Unknown',
                  ),
                ); // Save extracted tag
              }
            }
          }
        }
        // -------------------------------------

        final List<NoteModel> serverNotes = rawList
            .map((json) => NoteModel.fromJson(json))
            .toList();

        final int total = result['total'] ?? serverNotes.length;

        // Update Local Cache
        await local.saveNotes(user, serverNotes);
        await authLocal.updateLastSynced(
          user,
          DateTime.now().toIso8601String(),
        );

        return {'notes': serverNotes, 'total': total};
      } catch (e) {
        // Fallback to local on error
      }
    }

    final localNotes = await local.getNotes(user);
    final notes = _filterAndSortLocalNotes(
      localNotes,
      query: query,
      sortBy: sortBy,
      sortOrder: sortOrder,
      page: page,
      pageSize: pageSize,
      isDeleted: false,
    );
    return {'notes': notes, 'total': notes.length};
  }

  // --- SYNC NOTES ---
  Future<bool> syncNotes() async {
    final user = await _getCurrentUser();
    if (!await NetworkInfo.isConnected || user == 'default') {
      return false;
    }

    final lastSyncedAt = await authLocal.getLastSynced(user);
    final List<NoteModel> allLocalNotes = await local.getNotes(user);

    // Filter what needs to be sent
    final List<NoteModel> notesToSync = allLocalNotes
        .where(
          (note) => note.updatedAt.isAfter(
            lastSyncedAt != null
                ? DateTime.parse(lastSyncedAt)
                : DateTime.fromMillisecondsSinceEpoch(0),
          ),
        )
        .toList();

    final updated = notesToSync.where((n) => !n.isDeleted).toList();
    final deleted = notesToSync.where((n) => n.isDeleted).toList();

    final fullPayload = {
      'lastSynced': lastSyncedAt,
      'notes': {
        'created': [],
        'updated': updated.map((n) => n.toJson()).toList(),
        'deleted': deleted.map((n) => n.toJson()).toList(),
      },
      'tags': {},
    };

    try {
      final response = await remote.syncNotes(fullPayload);

      final List<dynamic> rawNotes = response['notes'] ?? [];
      final List<NoteModel> serverNotes = rawNotes
          .map((json) => NoteModel.fromJson(json))
          .toList();

      final newTimestamp = response['timestamp'];

      await local.saveNotes(user, serverNotes);
      if (newTimestamp != null) {
        await authLocal.updateLastSynced(user, newTimestamp);
      }
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // --- DELETED NOTES HANDLING ---
  Future<void> _actionDeletedNotes(
    NoteModel note,
    Function apiCall,
    bool isDeleted,
  ) async {
    final user = await _getCurrentUser();
    if (await NetworkInfo.isConnected && user != 'default') {
      try {
        await apiCall(note.id);
        await authLocal.updateLastSynced(
          user,
          DateTime.now().toIso8601String(),
        );
      } catch (e) {
        // Fail
      }
    }

    final updatedNote = NoteModel(
      id: note.id,
      title: note.title,
      body: note.body,
      tagIds: note.tagIds,
      isPinned: note.isPinned,
      isDeleted: isDeleted,
      createdAt: note.createdAt,
      updatedAt: DateTime.now(),
    );

    await local.saveNote(user, updatedNote);
  }

  Future<bool> deleteNote(NoteModel note) async {
    await _actionDeletedNotes(note, remote.deleteNote, true);
    return true;
  }

  Future<bool> restoreNote(NoteModel note) async {
    await _actionDeletedNotes(note, remote.restoreNote, false);
    return true;
  }

  Future<bool> permanentlyDeleteNote(NoteModel note) async {
    final user = await _getCurrentUser();
    if (await NetworkInfo.isConnected && user != 'default') {
      try {
        await remote.permanentlyDeleteNote(note.id);
        await authLocal.updateLastSynced(
          user,
          DateTime.now().toIso8601String(),
        );
        return true;
      } catch (e) {
        // Fail
      }
    }
    return false;
  }

  Future<List<NoteModel>> getTrashedNotes() async {
    final user = await _getCurrentUser();
    List<NoteModel> trashedNotes;

    if (await NetworkInfo.isConnected && user != 'default') {
      try {
        trashedNotes = await remote.getTrashedNotes();
        return trashedNotes;
      } catch (e) {
        // Fallback to local on error
      }
    }

    final localNotes = await local.getNotes(user);
    trashedNotes = _filterAndSortLocalNotes(localNotes, isDeleted: true);

    return trashedNotes;
  }
}
