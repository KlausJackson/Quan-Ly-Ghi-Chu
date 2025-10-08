import 'package:flutter/material.dart';
import 'package:notes/core/presentation/widget/app_drawer.dart';
import 'package:notes/core/network/api_client.dart';
import 'package:notes/features/notes/data/datasources/notes_remote_datasources.dart';
import 'package:notes/features/notes/data/repositories/note_repositories_impl.dart';
import 'package:notes/features/notes/domain/entities/note.dart';
import 'package:notes/features/notes/domain/usercases/delete_trash_note.dart';
import 'package:notes/features/notes/domain/usercases/restore_note.dart';
import 'package:notes/features/notes/domain/usercases/trash_note.dart';
// toolbar and note card widgets moved to specialized files
import 'package:notes/features/notes/presentation/widgets/note_tile.dart';
import 'package:notes/features/notes/presentation/widgets/trash_top_area.dart';

class TrashPage extends StatefulWidget{
  const TrashPage({super.key});
  @override
  State<TrashPage> createState() => _TrashPageState();
}
class _TrashPageState extends State<TrashPage>{
  // Simple wiring for this screen. In real apps, inject via DI.
  late final ApiClient _apiClient;
  late final NoteRemoteDataSource _remote;
  late final NoteRepositoryImpl _repository;
  late final FetchTrashNotes _fetchTrashNotes;
  late final RestoreNote _restoreNote;
  late final DeleteTrashNote _deleteTrashNote;

  bool _isLoading = true;
  String? _errorMessage;
  List<Note> _notes = [];
  int? _hoveredIndex;
  bool _selectMode = false;
  final Set<String> _selectedNoteIds = {};
  bool _isGridView = false; // Toggle between grid and list view
  String _searchQuery = '';

  // TODO: Replace with your real auth token provider
  static const String _token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2OGQyYjMzMTRiZmI2N2Y3YzQwZGI4ZWQiLCJ1c2VybmFtZSI6InR1YW5kZXB0cmFpMjM0IiwiaWF0IjoxNzU5Mzk2Mzc3LCJleHAiOjE3NjAwMDExNzd9.s8DaLUBPj8rNqZgNTFR6sb6xtkoOFjiaiRtRkMhBLz0';

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _remote = NoteRemoteDataSource(_apiClient);
    _repository = NoteRepositoryImpl(_remote);
    _fetchTrashNotes = FetchTrashNotes(_repository);
    _restoreNote = RestoreNote(_repository);
    _deleteTrashNote = DeleteTrashNote(_repository);
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      print('Loading trash notes...');
      final notes = await _fetchTrashNotes(_token);
      print('Loaded ${notes.length} notes');
      
      if (mounted) {
        setState(() {
          _notes = notes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notes: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRestore(Note note) async {
    try {
      await _restoreNote(note.id, _token);
      setState(() {
        _notes.removeWhere((n) => n.id == note.id);
      });
    } catch (e) {
      _showSnack('Khôi phục thất bại: $e');
    }
  }

  Future<void> _handleDeletePermanently(Note note) async {
    try {
      await _deleteTrashNote(note.id, _token);
      setState(() {
        _notes.removeWhere((n) => n.id == note.id);
      });
    } catch (e) {
      _showSnack('Xóa vĩnh viễn thất bại: $e');
    }
  }

  Future<void> _handleDeleteSelected() async {
    final ids = _selectedNoteIds.toList();
    if (ids.isEmpty) return;
    try {
      for (final id in ids) {
        try {
          await _deleteTrashNote(id, _token);
        } catch (_) {
          // continue deleting others even if one fails
        }
      }
      setState(() {
        _notes.removeWhere((n) => ids.contains(n.id));
        _selectedNoteIds.clear();
        _selectMode = false;
      });
      _showSnack('Đã xóa ${ids.length} ghi chú');
    } catch (e) {
      _showSnack('Xóa thất bại: $e');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  // Compact helpers to reduce build() size
  // removed helper (moved to TrashTopArea)

  // Note tiles moved to NoteTile widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TrashTopArea(
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                notesCount: _notes.length,
                selectMode: _selectMode,
                selectedCount: _selectedNoteIds.length,
                isGridView: _isGridView,
                onRefresh: _loadNotes,
                onToggleView: () => setState(() => _isGridView = !_isGridView),
                onEnterSelectMode: () => setState(() => _selectMode = true),
                onSelectAllToggle: () => setState(() {
                  if (_selectedNoteIds.length == _notes.length) {
                    _selectedNoteIds.clear();
                    _selectMode = false;
                  } else {
                    _selectedNoteIds.addAll(_notes.map((n) => n.id));
                  }
                }),
                onDeleteSelected: () => _handleDeleteSelected(),
                onCancelSelection: () => setState(() { _selectMode = false; _selectedNoteIds.clear(); }),
                onSearchPressed: () => setState(() {}),
                onSearch: (q) => setState(() { _searchQuery = q; }),
              ),
              Expanded(child: _buildBody()),
              const Padding(padding: EdgeInsets.only(bottom: 8.0, top: 4), child: Center(child: Text('Ghi chú của bạn sẽ bị xóa vĩnh viễn sau 30 ngày', style: TextStyle(color: Colors.white54, fontSize: 13)))),
            ],
          ),
        ),
      ),
      // Xóa bottomNavigationBar, vì đã chuyển lên trên
    );
  }


  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Có lỗi xảy ra', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(_errorMessage ?? 'Unknown error', style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadNotes,
              child: const Text('Thử lại'),
            )
          ],
        ),
      );
    }
    final visibleNotes = _searchQuery.isEmpty
        ? _notes
        : _notes.where((n) => (n.title + '\n' + n.content).toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    if (visibleNotes.isEmpty) {
      return const Center(
        child: Text('Không có ghi chú trong thùng rác', style: TextStyle(color: Colors.white70)),
      );
    }
    if (_isGridView) {
      // Grid view layout
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: visibleNotes.length,
        itemBuilder: (context, index) {
          final note = visibleNotes[index];
          final isSelected = _selectedNoteIds.contains(note.id);
          final isHovered = _hoveredIndex == index;
          return NoteTile(
            note: note,
            index: index,
            isSelected: isSelected,
            isHovered: isHovered,
            selectMode: _selectMode,
            isGridView: _isGridView,
            selectedNoteIds: _selectedNoteIds,
            onToggleSelect: (id) => setState(() {
              _selectMode = true;
              if (_selectedNoteIds.contains(id)) _selectedNoteIds.remove(id);
              else _selectedNoteIds.add(id);
              if (_selectedNoteIds.isEmpty) _selectMode = false;
            }),
            onRestore: () => _handleRestore(note),
            onDeletePermanently: () => _handleDeletePermanently(note),
          );
        },
      );
    } else {
      // List view layout
      return ListView.separated(
        itemCount: visibleNotes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final note = visibleNotes[index];
          final isSelected = _selectedNoteIds.contains(note.id);
          final isHovered = _hoveredIndex == index;
          return NoteTile(
            note: note,
            index: index,
            isSelected: isSelected,
            isHovered: isHovered,
            selectMode: _selectMode,
            isGridView: _isGridView,
            selectedNoteIds: _selectedNoteIds,
            onToggleSelect: (id) => setState(() {
              _selectMode = true;
              if (_selectedNoteIds.contains(id)) _selectedNoteIds.remove(id);
              else _selectedNoteIds.add(id);
              if (_selectedNoteIds.isEmpty) _selectMode = false;
            }),
            onRestore: () => _handleRestore(note),
            onDeletePermanently: () => _handleDeletePermanently(note),
          );
        },
      );
    }
  }
}
