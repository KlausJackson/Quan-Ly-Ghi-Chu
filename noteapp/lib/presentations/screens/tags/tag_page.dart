import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteapp/features/tags/tag_model.dart';
import 'package:noteapp/features/tags/tag_provider.dart';
import 'package:noteapp/features/notes/note_provider.dart';
import 'package:noteapp/presentations/screens/tags/widgets/tag_card.dart';
import 'package:noteapp/presentations/shared_widgets/show_dialogs.dart';

class TagPage extends StatefulWidget {
  const TagPage({super.key});

  @override
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TagProvider>().loadTags();
    });
  }

  void _showTagDialog({TagModel? tag}) async {
    // if a tag is provided, editing = true
    // else, adding new tag
    final isEditing = tag != null;

    final name = await ShowDialogs.showInputDialog(
        context: context,
        title: isEditing ? 'Edit Tag' : 'Add Tag',
        message: isEditing ? 'Update the tag name.' : 'Enter a name for the new tag.',
        onConfirm: ArgumentError.notNull
      );
      
    if (name == null || name.isEmpty) return; // user cancelled or empty
    
    final tagProvider = context.read<TagProvider>();
      if (isEditing) {
      await tagProvider.updateTag(tag.id, name);
    } else {
      await tagProvider.createTag(name);
    }
  }

  void _confirmDelete(TagModel tag) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete?'),
        content: Text('Are you sure you want to delete the tag "${tag.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TagProvider>().deleteTag(tag.id);
              Navigator.pop(ctx); // Close dialog
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tagProvider = context.watch<TagProvider>();
    final noteProvider = context.watch<NoteProvider>();

    return Scaffold(
      //   appBar: AppBar(
      //     title: const Text('Your Tags'),
      //     centerTitle: true,
      //   ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tag_add_fab',
        onPressed: () => _showTagDialog(),
        child: const Icon(Icons.add),
      ),
      body: tagProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tagProvider.tags.isEmpty
          ? const Center(child: Text('No tags yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tagProvider.tags.length,
              itemBuilder: (context, index) {
                final tag = tagProvider.tags[index];
                int count = noteProvider.countNotesByTag(tag.id);

                return TagCard(
                  title: tag.name,
                  content: '$count notes',
                  onTap: () => _showTagDialog(tag: tag),
                  onLongPress: () => _confirmDelete(tag),
                );
              },
            ),
    );
  }
}
