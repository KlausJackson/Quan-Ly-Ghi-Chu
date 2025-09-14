import 'package:noteapp/data/models/user.dart';
import 'package:noteapp/data/sources/local.dart';
import 'package:noteapp/data/sources/remote.dart';

class AuthService {
  final Remote _remote;
  final Local _local;
  AuthService(this._remote, this._local); // constructor

  Future<void> register({
    required String username,
    required String password,
  }) async {
    final response = await _remote.authenticate(
      route: '/auth/register',
      username: username,
      password: password,
    );

    final token = response.data['data'];
    await _local.saveToken(token);
    await _local.saveUser(username: username);
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final response = await _remote.authenticate(
      route: '/auth/login',
      username: username,
      password: password,
    );

    final token = response.data['data'];
    await _local.saveToken(token);
    await _local.saveUser(username: username);
    return response.statusCode == 200;
  }

  Future<List<User>> fetchUsers() async {
    return _local.getUsers();
  }

  Future<void> deleteUser(String username) async {
    if (await _local.getCurrentUser() == username) {
      await _local.deleteUser(username, true);
    } else {
      await _local.deleteUser(username, false);
    }
  } // delete user locally, and token if current user

  Future<void> deleteAccount(String password) async {
    final response = await _remote.deleteAccount(password);
    if (response.statusCode == 200) {
      await _local.deleteUser(
        await _local.getCurrentUser(),
        true,
      ); // data and token
    } else {
      throw Exception('Lỗi khi xóa tài khoản.');
    }
  }

  Future<bool> hasToken() async {
    return await _local.getToken() != null;
  }

  Future<void> logout() async {
    await _local.deleteToken();
  }

  Future<String> getCurrentUser() async {
    return await _local.getCurrentUser();
  }

  Future<String?> getToken() async {
    return await _local.getToken();
  } // for testing
}
