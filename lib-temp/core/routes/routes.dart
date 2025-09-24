import 'package:flutter/material.dart';
import 'package:noteapp/features/auth/presentation/pages/auth_page.dart';
import 'package:noteapp/features/notes/presentation/pages/notes_page.dart';
import 'package:noteapp/features/tags/presentation/pages/tags_page.dart';
import 'package:noteapp/features/notes/presentation/pages/trash_page.dart';
import 'package:noteapp/presentation/pages/main_layout_page.dart';

// /notes
// where to put ?
// /notes/trash
// /notes/edit 

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/auth') {
      return MaterialPageRoute(builder: (_) => const AuthPage());
    } else if (settings.name == '/notes') {
      return MaterialPageRoute(
        builder: (_) => const MainLayoutPage(title: 'Notes', body: NotesPage()),
      );
    } else if (settings.name == '/notes/trash') {
      return MaterialPageRoute(
        builder: (_) => const MainLayoutPage(title: 'Trash', body: TrashPage()),
      );
    } else if (settings.name == '/tags') {
      return MaterialPageRoute(
        builder: (_) => const MainLayoutPage(title: 'Tags', body: TagsPage()),
      );
    } else {
      return MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text('Route not found'))),
      );
    }
  }
}
