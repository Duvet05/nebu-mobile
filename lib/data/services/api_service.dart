import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../../core/config/config.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/errors/app_exception.dart';

class ApiService {
  ApiService({
    required this.dio,
    required FlutterSecureStorage secureStorage,
    required Logger logger,
  }) : _secureStorage = secureStorage,
       _logger = logger {
    _setupDio();
  }
  final Dio dio;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;
  bool _isRefreshing = false;

  void _setupDio() {
    dio.options.baseUrl = Config.apiBaseUrl;
    dio.options.connectTimeout = Config.apiTimeout;
    dio.options.receiveTimeout = Config.apiTimeout;

    // Request interceptor - Add auth token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: StorageKeys.accessToken);

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          _logger
            ..d('Request: ${options.method} ${options.path}')
            ..d('Headers: ${options.headers}');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logger
            ..e(
              'Error: ${error.response?.statusCode} ${error.requestOptions.path}',
            )
            ..e('Error message: ${error.message}');

          // Handle 401 Unauthorized - Try to refresh token
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            final refreshToken = await _secureStorage.read(
              key: StorageKeys.refreshToken,
            );

            if (refreshToken != null && refreshToken.isNotEmpty) {
              _isRefreshing = true;
              try {
                final refreshResponse = await dio.post<Map<String, dynamic>>(
                  '/auth/refresh',
                  data: {'refreshToken': refreshToken},
                  options: Options(
                    headers: {
                      'Authorization': null, // Remove old token
                    },
                  ),
                );

                final newAccessToken =
                    refreshResponse.data?['accessToken'] as String?;
                if (newAccessToken == null) {
                  throw Exception('No access token in refresh response');
                }
                await _secureStorage.write(
                  key: StorageKeys.accessToken,
                  value: newAccessToken,
                );

                // Retry the original request with new token
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final retryResponse = await dio.fetch<dynamic>(
                  error.requestOptions,
                );
                _isRefreshing = false;
                return handler.resolve(retryResponse);
              } on Exception catch (e) {
                _isRefreshing = false;
                _logger.e('Token refresh failed: $e');
                await _secureStorage.delete(key: StorageKeys.accessToken);
                await _secureStorage.delete(key: StorageKeys.refreshToken);
              }
            }
          }

          // Convert DioException to typed AppException for non-401 errors
          final appException = _mapDioError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: appException,
              message: appException.message,
            ),
          );
        },
      ),
    );

    // Logging interceptor (only in debug mode)
    if (Config.enableDebugLogs) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: _logger.d,
        ),
      );
    }
  }

  /// Maps a [DioException] to a typed [AppException] based on status code.
  static AppException _mapDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    final backendMsg = _extractBackendMessage(data);

    // Connection-level errors (no response from server)
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const NetworkException('Connection timed out', statusCode: 408);
    }
    if (error.type == DioExceptionType.connectionError) {
      return const NetworkException(
        'No internet connection',
        statusCode: 0,
      );
    }

    // HTTP status-based errors
    return switch (statusCode) {
      401 => AuthException(backendMsg ?? 'Not authorized', statusCode: 401),
      403 => AuthException(backendMsg ?? 'Forbidden', statusCode: 403),
      404 => NotFoundException(backendMsg ?? 'Not found', statusCode: 404),
      409 => ConflictException(backendMsg ?? 'Conflict', statusCode: 409),
      422 =>
          ValidationException(
            backendMsg ?? 'Validation error',
            statusCode: 422,
          ),
      429 =>
          RateLimitException(
            backendMsg ?? 'Too many requests',
            statusCode: 429,
            retryAfter: _extractRetryAfter(error.response),
          ),
      >= 500 =>
          ServerException(
            backendMsg ?? 'Server error',
            statusCode: statusCode,
          ),
      _ =>
          ServerException(
            backendMsg ?? error.message ?? 'Unknown error',
            statusCode: statusCode,
          ),
    };
  }

  static String? _extractBackendMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String) return message;
      if (message is List) return message.join(', ');
      final error = data['error'];
      if (error is String) return error;
    }
    return null;
  }

  static int? _extractRetryAfter(Response<dynamic>? response) {
    final header = response?.headers.value('retry-after');
    if (header == null) return null;
    return int.tryParse(header);
  }

  /// Rethrows the inner [AppException] from a [DioException] if present,
  /// otherwise rethrows the original error.
  static Never _rethrowTyped(Object error) {
    if (error is DioException && error.error is AppException) {
      throw error.error! as AppException;
    }
    throw error;
  }

  // Generic GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } catch (e) {
      _logger.e('GET request failed: $e');
      _rethrowTyped(e);
    }
  }

  // Generic POST request
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } catch (e) {
      _logger.e('POST request failed: $e');
      _rethrowTyped(e);
    }
  }

  // Generic PUT request
  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } catch (e) {
      _logger.e('PUT request failed: $e');
      _rethrowTyped(e);
    }
  }

  // Generic DELETE request
  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } catch (e) {
      _logger.e('DELETE request failed: $e');
      _rethrowTyped(e);
    }
  }

  // Generic PATCH request
  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } catch (e) {
      _logger.e('PATCH request failed: $e');
      _rethrowTyped(e);
    }
  }
}
