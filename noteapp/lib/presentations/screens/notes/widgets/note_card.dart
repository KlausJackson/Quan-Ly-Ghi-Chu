import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteapp/features/notes/note_model.dart';
import 'package:noteapp/features/tags/tag_provider.dart';
import 'package:noteapp/features/tags/tag_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;

  const NoteCard({super.key, required this.note});

  String _getPreviewText() {
    for (var block in note.body) {
      if (block.text.trim().isNotEmpty) {
        return block.text.trim();
      }
    } // Find the first block that isn't empty
    return 'Empty note';
  }

  @override
  Widget build(BuildContext context) {
    // Resolve Tag UUIDs to Tag Models to get the names
    // Get all tags from provider
    final allTags = context
        .watch<TagProvider>()
        .tags; // Use watch to update if tags change
    final noteTags = allTags.where((t) => note.tagIds.contains(t.id)).toList(); // Filter tags that are associated with the current note

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).pushNamed('/notes/edit', arguments: note);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Title
              if (note.title.isNotEmpty)
                Text(
                  note.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

              // 2. Body Preview (First line)
              const SizedBox(height: 6),
              Text(
                _getPreviewText(),
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // 3. Tags (Scrollable Chips)
              if (noteTags.isNotEmpty) ...[
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: noteTags
                        .map((tag) => _buildTagChip(context, tag))
                        .toList(),
                  ),
                ),
              ],

              // 4. Footer (Time)
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _formatDate(note.updatedAt),
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagChip(BuildContext context, TagModel tag) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Text(
        tag.name,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
