import 'package:flutter/material.dart';
import 'package:noteapp/presentation/widgets/menu_drawer.dart';
import 'package:noteapp/features/notes/presentation/pages/notes_page.dart';
import 'package:noteapp/features/tags/presentation/pages/tags_page.dart';
import 'package:noteapp/features/notes/presentation/pages/trash_page.dart';

class MainLayoutPage extends StatelessWidget {
  final String title;
  final Widget body;

  const MainLayoutPage({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const MenuDrawer(),
      body: body,
      floatingActionButton: _buildFloatingActionButton(context)
    );
  }
    Widget? _buildFloatingActionButton(BuildContext context) {
    if (body is NotesPage) {
      return FloatingActionButton(
        onPressed: () {
          // Navigator.of(context).pushNamed('/notes/edit');
        },
        tooltip: 'Create Note',
        child: const Icon(Icons.add),
      );
    }
    if (body is TagsPage) {
      return FloatingActionButton(
        onPressed: () {
          // Show dialog to create a new tag
        },
        tooltip: 'Create Tag',
        child: const Icon(Icons.add),
      );
    }
    if (body is TrashPage) {
      return FloatingActionButton(
        onPressed: () {
          // Show confirmation dialog to empty trash
        },
        tooltip: 'Empty Trash',
        child: const Icon(Icons.delete_forever),
      );
    }
    return null;
  }
}
