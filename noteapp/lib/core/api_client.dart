import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String server = 'http://localhost:3000/api/v1';

  ApiClient() : _dio = Dio(BaseOptions(baseUrl: server)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: 'authToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  String _eMessage(DioException e) {
    if (e.response != null && e.response?.data != null) {
      return e.response?.data['message'] ?? 'Unknown error.';
    } else {
      return 'Can\'t connect to the server. Please check your internet connection.';
    }
  }

  // --- API METHODS ---
  Future<dynamic> post(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _eMessage(e);
    }
  }

  Future<dynamic> delete(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _eMessage(e);
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _eMessage(e);
    }
  }

  Future<dynamic> put(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _eMessage(e);
    }
  }
}
