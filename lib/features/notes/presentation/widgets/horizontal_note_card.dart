import 'package:flutter/material.dart';
import 'package:notes/features/notes/domain/entities/note.dart';

class HorizontalNoteCard extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final bool isHovered;
  final bool selectMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onRestore;
  final VoidCallback? onDeletePermanently;

  const HorizontalNoteCard({
    super.key,
    required this.note,
    required this.isSelected,
    required this.isHovered,
    required this.selectMode,
    this.onTap,
    this.onLongPress,
    this.onRestore,
    this.onDeletePermanently,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Always call onTap; NoteTile will decide whether to toggle selection or navigate
        onTap?.call();
      },
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isHovered ? Colors.grey[850] : Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isHovered ? Colors.white24 : Colors.white10),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        padding: const EdgeInsets.all(15),
        child: Stack(
          children: [
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            if (selectMode || isHovered)
              Positioned(
                top: -4,
                right: -4,
                child: Radio<bool>(
                  value: true,
                  groupValue: isSelected,
                  onChanged: (_) {
                    if (selectMode || isHovered) onTap?.call();
                  },
                  activeColor: Colors.deepPurple,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  note.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onRestore,
                      icon: const Icon(Icons.restore, color: Colors.lightGreenAccent),
                      label: const Text('Khôi phục', style: TextStyle(color: Colors.lightGreenAccent)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
