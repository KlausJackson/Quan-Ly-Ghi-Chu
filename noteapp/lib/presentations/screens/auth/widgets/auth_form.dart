import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteapp/features/auth/auth_provider.dart';

class AuthForm extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const AuthForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool _isLogin = true;
  bool _isHidePassword = true;

  void _submit() async {
    final provider = context.read<AuthProvider>();
    final username = widget.usernameController.text.trim();
    final password = widget.passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    // Call Provider and wait for result
    String? error;
    if (_isLogin) {
      error = await provider.login(username, password);
    } else {
      error = await provider.register(username, password);
    }

    if (!mounted) return;

    if (error != null) {
      // Show Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
      );
    } else {
      // Success -> Navigate to Notes
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Success!')));
      Navigator.pushReplacementNamed(context, '/notes');
    }
  }

  void _delete() async {
    final provider = context.read<AuthProvider>();
    final password = widget.passwordController.text.trim();
    String? error = await provider.deleteAccount(password);
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
      );
    } else {
      // Success -> Navigate to Notes
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Account deleted successfully!')));
      Navigator.pushReplacementNamed(context, '/notes');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthProvider, bool>((p) => p.isLoading);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _isHidePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () =>
                  setState(() => _isHidePassword = !_isHidePassword),
            ),
          ),
          obscureText: _isHidePassword,
        ),
        const SizedBox(height: 20),

        if (isLoading)
          const CircularProgressIndicator()
        else 
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
            ),
            child: Text(_isLogin ? 'Sign in' : 'Register'),
          ),
        ElevatedButton(
          onPressed: _delete,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 45),
          ),
          child: Text('Delete Account'),
        ),

        TextButton(
          onPressed: () => setState(() => _isLogin = !_isLogin),
          child: Text(
            _isLogin
                ? 'Don\'t have an account? Register'
                : 'Already have an account? Sign in',
          ),
        ),
      ],
    );
  }
}
