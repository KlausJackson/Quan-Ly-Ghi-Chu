import 'package:flutter/material.dart';
import 'package:noteapp/providers/auth_provider.dart';
import 'package:noteapp/presentation/screens/auth/auth.dart';
import 'package:provider/provider.dart';

class TrashListScreen extends StatelessWidget {
  const TrashListScreen({super.key, required this.currentUser});
  final String currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Tim kiem thung rac...',
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
        ),
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
        child: Text('Trash cards $currentUser'), // code o day
        // ---------------------------------
      ),
    );
  }
}
