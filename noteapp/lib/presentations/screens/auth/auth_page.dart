import 'package:flutter/material.dart';
import 'package:noteapp/presentations/screens/auth/widgets/auth_form.dart';
import 'package:noteapp/presentations/screens/auth/widgets/user_list.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign In / Register',
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Input Form ---
            AuthForm(
              usernameController: _usernameController,
              passwordController: _passwordController,
            ),

            const Divider(height: 40),

            // --- Saved Accounts List ---
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Saved Accounts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 300, // Fixed height for the list
              child: UserList(
                onUserSelected: (user) {
                  // Auto-fill username when tapping a user in the list
                  _usernameController.text = user.username;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
