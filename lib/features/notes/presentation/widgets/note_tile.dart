import 'package:flutter/material.dart';
import 'package:notes/features/notes/domain/entities/note.dart';
import 'package:notes/features/notes/presentation/widgets/customers_notes_list.dart';
import 'package:notes/features/notes/presentation/pages/note_detail_page.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final int index;
  final bool isSelected;
  final bool isHovered;
  final bool selectMode;
  final bool isGridView;
  final Set<String> selectedNoteIds;
  final ValueChanged<String>? onToggleSelect;
  final VoidCallback? onRestore;
  final VoidCallback? onDeletePermanently;

  const NoteTile({
    super.key,
    required this.note,
    required this.index,
    required this.isSelected,
    required this.isHovered,
    required this.selectMode,
    required this.isGridView,
    required this.selectedNoteIds,
    this.onToggleSelect,
    this.onRestore,
    this.onDeletePermanently,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => {},
      onExit: (_) => {},
      child: GestureDetector(
        onLongPress: () => onToggleSelect?.call(note.id),
        child: NoteCard(
          note: note,
          isSelected: isSelected,
          isHovered: isHovered,
          selectMode: selectMode,
          isGridView: isGridView,
          onTap: () {
            if (selectMode) {
              onToggleSelect?.call(note.id);
            } else {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoteDetailPage(note: note)));
            }
          },
          onLongPress: () => onToggleSelect?.call(note.id),
          onRestore: onRestore,
          onDeletePermanently: onDeletePermanently,
        ),
      ),
    );
  }
}
