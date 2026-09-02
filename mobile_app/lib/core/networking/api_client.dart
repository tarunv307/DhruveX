import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import '../errors/app_exception.dart';

class ApiClient {
  final Dio _dio;
  final SecureStorageService _secureStorage;

  ApiClient({Dio? dio, SecureStorageService? secureStorage, String? baseUrl})
      : _dio = dio ?? Dio(),
        _secureStorage = secureStorage ?? SecureStorageService() {
    _dio.options.baseUrl = baseUrl ?? ApiConstants.defaultBaseUrl;
    _dio.options.connectTimeout = const Duration(milliseconds: ApiConstants.connectTimeoutMs);
    _dio.options.receiveTimeout = const Duration(milliseconds: ApiConstants.receiveTimeoutMs);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Request & Response Interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Handle token expiry / 401
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return NetworkException('Unable to reach server. Operating in offline cache mode.');
    }
    final res = error.response;
    if (res != null && res.data is Map && res.data['error'] != null) {
      final errMap = res.data['error'];
      return ServerException(
        errMap['message'] ?? 'Server error occurred',
        details: errMap['details'],
      );
    }
    return ServerException(error.message ?? 'An unexpected network error occurred');
  }
}
