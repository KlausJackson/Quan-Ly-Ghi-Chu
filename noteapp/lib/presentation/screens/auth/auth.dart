import 'package:flutter/material.dart';
import 'package:noteapp/presentation/widgets/show_dialog.dart';
import 'package:noteapp/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:noteapp/data/models/user.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late AuthProvider _authProvider;

  bool _isLogin = true; // toggle between login and register
  bool _isHidePassword = true; // toggle password visibility
  bool _showDialog = false; // prevent multiple dialogs

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _authProvider.addListener(_handleAuthChanges);
  }

  @override
  void dispose() {
    _authProvider.removeListener(_handleAuthChanges);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuthChanges() {
    if (_showDialog) return; // prevent multiple dialogs
    if (_authProvider.status == AuthStatus.error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _showDialog = true;
          });
        }
        _errorDialog(_authProvider.message);
      });
    } else if (_authProvider.status == AuthStatus.authenticated &&
        _authProvider.message.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _snackbar(_authProvider.message);
      });
    }
  }

  bool _isAuthenticated() {
    return _authProvider.status == AuthStatus.authenticated;
  }

  void _errorDialog(String message) {
    AppDialogs.showInfoDialog(
      context: context,
      title: 'Lỗi !',
      message: message,
    ).then((_) {
      _authProvider.clearMessage();
      setState(() {
        _showDialog = false;
      });
    }); // executes after the dialog is dismissed
  }

  void _snackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    // Navigator.of(context).pop(); // back to note list
  }

  void _selectUser(User profile) async {
    setState(() {
      _usernameController.text = profile.username;
    });
  }

  void _submit() {
    final authProvider = context.read<AuthProvider>();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _errorDialog("Tên người dùng và mật khẩu không thể để trống.");
      return;
    }

    if (_isLogin) {
      authProvider.login(username: username, password: password);
    } else {
      authProvider.register(username: username, password: password);
    }
  }

  TextField _textField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: label == 'Mật khẩu' ? _isHidePassword : false,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: label == 'Mật khẩu'
            ? IconButton(
                icon: Icon(
                  _isHidePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isHidePassword = !_isHidePassword;
                  });
                },
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLogin ? 'Đăng nhập' : 'Đăng ký',
          style: TextStyle(fontSize: 16),
        ),
        toolbarHeight: 45,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- USERNAME & PASSWORD ---
            _textField('Tên người dùng', _usernameController),
            const SizedBox(height: 16),
            _textField('Mật khẩu', _passwordController),
            const SizedBox(height: 16),

            // --- LOGIN / REGISTER BUTTONS ---
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.status == AuthStatus.authenticating) {
                  return const CircularProgressIndicator();
                }

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), // full width
                  ),
                  onPressed: _submit,
                  child: Text(_isLogin ? 'Đăng nhập' : 'Đăng ký'),
                );
              },
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(_isLogin ? 'Đăng ký' : 'Đăng nhập'),
                ),

                TextButton(
                  onPressed: () {
                    if (!_isAuthenticated()) {
                      _snackbar('Bạn chưa đăng nhập.');
                      return;
                    } else {
                      _authProvider.logout();
                      _snackbar('Đăng xuất thành công.');
                    }
                  },
                  child: const Text('Đăng xuất'),
                ),

                // -----------------------------------------------------------------
                // check if logged in
                // true -> showdialog to reenter password to confirm deletion -> delete account
                //    if success -> show snackbar "account deleted" -> back to fresh start (you're using app offline)
                //    if fail -> show snackbar "failed to delete account: reason"
                // false -> show snackbar "must be logged in to delete account"
                TextButton(
                  onPressed: () {
                    if (!_isAuthenticated()) {
                      _snackbar(
                        'Bạn phải đăng nhập để xóa tài khoản.',
                      );
                      return;
                    } else {
                      AppDialogs.showInputDialog(
                        context: context,
                        title: 'Xác nhận xóa tài khoản',
                        message: 'Vui lòng nhập lại mật khẩu của bạn:',
                        confirmText: 'Xóa',
                      ).then((password) {
                        if (password != null && password.isNotEmpty) {
                          _authProvider.deleteAccount(password);
                        } else if (password != null && password.isEmpty) {
                          _snackbar('Mật khẩu không được để trống.');
                        }
                      });
                    }
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),

            // -----------------------------------------------------------------
            const Divider(),
            const Text(
              'Saved Profiles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.profiles.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Chưa có tài khoản nào được lưu.'),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade700),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: authProvider.profiles.length,
                      itemBuilder: (context, index) {
                        final profile = authProvider.profiles[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(profile.username),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(profile.lastSynced ?? ''),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.touch_app,
                                    color: Colors.blue,
                                  ),
                                  tooltip: 'Select',
                                  onPressed: () => _selectUser(profile),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Delete',
                                  onPressed: () {
                                    AppDialogs.showConfirmationDialog(
                                      context: context,
                                      title: 'Xác nhận xóa',
                                      message:
                                          'Bạn có chắc chắn muốn xóa "${profile.username}" khỏi thiết bị không?',
                                      confirmText: 'Xóa',
                                      onConfirm: () {
                                        context.read<AuthProvider>().deleteUser(
                                          profile.username,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
