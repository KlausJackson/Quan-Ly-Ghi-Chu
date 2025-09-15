import 'package:flutter/material.dart';
import 'package:noteapp/providers/auth_provider.dart';
import 'package:noteapp/presentation/screens/auth/auth.dart';
import 'package:provider/provider.dart';
import 'package:noteapp/presentation/widgets/show_dialog.dart';

class TagListScreen extends StatelessWidget {
  const TagListScreen({super.key, required this.currentUser});
  final String currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('The'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: const Icon(Icons.login),
                tooltip: 'Login / Register',
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        // ---------------------------------
        child: Text('Tag cards $currentUser'), // code o day
        // ---------------------------------
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // --------------------------------
          // Tag Add using showInputDialog in show_dialog.dart
          // --------------------------------
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
