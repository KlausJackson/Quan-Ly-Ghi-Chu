import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:noteapp/core/contants.dart';

class Remote {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Remote() : _dio = Dio(BaseOptions(baseUrl: Constants.server)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: 'authToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options); // Continue with the request
        },
      ),
    );
  } // automatically adds auth token to every request

  String eMessage(DioException e) {
    if (e.response != null && e.response?.data != null) {
      return e.response?.data['message'] ?? 'Lỗi không xác định.';
    } else {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.';
    }
  }

  // ---- AUTH ----
  Future<Response> authenticate({
    required String route,
    required String username,
    required String password,
  }) async {
    try {
      return await _dio.post(
        route,
        data: {'username': username, 'password': password},
      );
    } on DioException catch (e) {
      throw eMessage(e);
    }
  }

  Future<Response> deleteAccount(String password) async {
    try {
      return await _dio.delete('/auth/me', data: {'password': password});
    } on DioException catch (e) {
      throw eMessage(e);
    }
  }

  // ---- SYNC ----
  Future<Response> syncData(Map<String, dynamic> payload) async {
    try {
      return await _dio.post('/sync', data: payload);
    } on DioException catch (e) {
      throw eMessage(e);
    }
  }

  // ---- NOTES ----



  // ---- TAGS ----
}

//   // POST /api/v1/auth/register
//   Future<Response> register({
//     required String username,
//     required String password,
//   }) async {
//     try {
//       return await _dio.post(
//         '/auth/register',
//         data: {'username': username, 'password': password},
//       );
//     } on DioException catch (e) {
//       throw Exception(
//         'Failed to register: ${e.response?.data['message'] ?? e.message}',
//       );
//     }
//   }

//   // POST /api/v1/auth/login
//   Future<Response> login({
//     required String username,
//     required String password,
//   }) async {
//     try {
//       return await _dio.post(
//         '/auth/login',
//         data: {'username': username, 'password': password},
//       );
//     } on DioException catch (e) {
//       throw Exception(
//         'Failed to login: ${e.response?.data['message'] ?? e.message}',
//       );
//     }
//   }
