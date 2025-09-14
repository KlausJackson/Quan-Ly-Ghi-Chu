import 'package:flutter/material.dart';
import 'package:noteapp/data/models/user.dart';
import 'package:noteapp/data/services/auth_service.dart';

enum AuthStatus {
  unauthenticated, // not logged in
  authenticating, // show circular progress indicator
  authenticated, // successfully logged in.
  error, // failed
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  AuthStatus _status = AuthStatus.unauthenticated;
  String _message = '';
  String _currentUser = 'default';
  List<User> _profiles = [];

  AuthProvider(this._authService) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchUsers();
    await _updateAuthState();
  }

  Future<void> _updateAuthState() async {
    final user = await _authService.getCurrentUser();
    if (user == 'default') {
      _status = AuthStatus.unauthenticated;
    } else {
      _status = AuthStatus.authenticated;
    }
    _currentUser = user;
    notifyListeners();
  }

  Future<void> _fetchUsers() async {
    _profiles = await _authService.fetchUsers();
    notifyListeners(); // update UI after login, register, delete user
  }

  // helper
  Future<void> _handleAuth(Future<void> Function() authAction) async {
    _status = AuthStatus.authenticating; // authenticating
    _message = '';
    notifyListeners();

    try {
      await authAction();
      _status = AuthStatus.authenticated;
      _message = 'Successfully authenticated.';
    } catch (e) {
      _status = AuthStatus.error;
      _message = e.toString();
    }

    notifyListeners();
  }

  void _reset() {
    _status = AuthStatus.unauthenticated;
    _currentUser = 'default';
    notifyListeners();
  }

  // ------- FOR UI -------
  // get methods for private fields
  AuthStatus get status => _status;
  String get currentUser => _currentUser;
  String get message => _message;
  List<User> get profiles => _profiles;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    await _handleAuth(() async {
      await _authService.login(username: username, password: password);
      await _updateAuthState();
      await _fetchUsers();
    });
  }

  Future<void> register({
    required String username,
    required String password,
  }) async {
    await _handleAuth(() async {
      await _authService.register(username: username, password: password);
      await _updateAuthState();
      await _fetchUsers();
    });
  }

  Future<void> deleteUser(String username) async {
    await _authService.deleteUser(username);
    if (_currentUser == username) {
      _reset();
    }
    await _fetchUsers();
  }

  // Delete account:
  // 1. Re-authenticate with password
  // 2. If successful, call deleteAccount (delete from remote & local)
  // 3. Update state in UI -> unauthenticated, default current user -> back to Fresh Start
  Future<void> deleteAccount(String password) async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      await _authService.deleteAccount(password);
      // await deleteUser(username); // already in deleteAccount (auth_service.dart)
      _reset();
      await _fetchUsers();
    } catch (e) {
      _status = AuthStatus.error;
      _message = e.toString();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _reset();
    notifyListeners();
  }

  void clearMessage() {
    _message = '';
   // notifyListeners();
  }

  Future<String> getToken() async {
    return await _authService.getToken() ?? 'None';
  } // for testing
}
