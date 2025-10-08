import 'package:flutter/material.dart';
import 'package:notes/features/notes/domain/entities/note.dart';
import 'package:notes/features/notes/presentation/widgets/horizontal_note_card.dart';
import 'package:notes/features/notes/presentation/widgets/vertical_note_card.dart';

// Simple note card component
class NoteCard extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final bool isHovered;
  final bool selectMode;
  final bool isGridView; // Add this to distinguish layout
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onRestore;
  final VoidCallback? onDeletePermanently;

  const NoteCard({
    super.key,
    required this.note,
    required this.isSelected,
    required this.isHovered,
    required this.selectMode,
    this.isGridView = false,
    this.onTap,
    this.onLongPress,
    this.onRestore,
    this.onDeletePermanently,
  });

  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return VerticalNoteCard(
        note: note,
        isSelected: isSelected,
        isHovered: isHovered,
        selectMode: selectMode,
        onTap: onTap,
        onLongPress: onLongPress,
        onRestore: onRestore,
        onDeletePermanently: onDeletePermanently,
      );
    }

    return HorizontalNoteCard(
      note: note,
      isSelected: isSelected,
      isHovered: isHovered,
      selectMode: selectMode,
      onTap: onTap,
      onLongPress: onLongPress,
      onRestore: onRestore,
      onDeletePermanently: onDeletePermanently,
    );
  }
}
