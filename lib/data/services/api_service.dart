import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../../core/config/config.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/errors/app_exception.dart';

class ApiService {
  ApiService({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
    required Logger logger,
  }) : _dio = dio,
       _secureStorage = secureStorage,
       _logger = logger {
    _setupDio();
  }

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;

  /// Completer used to serialize concurrent token refresh attempts.
  /// When non-null, a refresh is already in progress — other 401 handlers
  /// await the same future instead of firing a second refresh.
  Completer<String?>? _refreshCompleter;

  void _setupDio() {
    _dio.options.baseUrl = Config.apiBaseUrl;
    _dio.options.connectTimeout = Config.apiTimeout;
    _dio.options.receiveTimeout = Config.apiTimeout;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(
            key: StorageKeys.accessToken,
          );

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          _logger.d(
            'Request: ${options.method} ${options.path}',
          );

          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logger.e(
            'Error: ${error.response?.statusCode} ${error.requestOptions.path}',
          );

          // Only attempt refresh on 401 if we haven't already retried
          if (error.response?.statusCode == 401 &&
              error.requestOptions.extra['retried'] != true) {
            try {
              final newToken = await _refreshToken();
              if (newToken != null) {
                // Retry the original request with the new token
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                error.requestOptions.extra['retried'] = true;
                final retryResponse = await _dio.fetch<dynamic>(
                  error.requestOptions,
                );
                return handler.resolve(retryResponse);
              }
            } on Exception catch (e) {
              _logger.e('Token refresh failed, clearing session: $e');
              await _clearTokens();
            }
          }

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

    if (Config.enableDebugLogs) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: _logger.d,
        ),
      );
    }
  }

  /// Refreshes the access token, serializing concurrent attempts.
  /// Returns the new access token, or null if refresh is not possible.
  Future<String?> _refreshToken() async {
    // If a refresh is already in flight, piggyback on it
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final refreshToken = await _secureStorage.read(
      key: StorageKeys.refreshToken,
    );
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    _refreshCompleter = Completer<String?>();
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      final newAccessToken = response.data?['accessToken'] as String?;
      if (newAccessToken == null) {
        throw const AuthException(
          'No access token in refresh response',
          statusCode: 401,
        );
      }

      await _secureStorage.write(
        key: StorageKeys.accessToken,
        value: newAccessToken,
      );

      _refreshCompleter!.complete(newAccessToken);
      return newAccessToken;
    } on Exception catch (e) {
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
  }

  // ---------------------------------------------------------------------------
  // Error mapping
  // ---------------------------------------------------------------------------

  static AppException _mapDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    final backendMsg = _extractBackendMessage(data);

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const NetworkException('Connection timed out', statusCode: 408);
    }
    if (error.type == DioExceptionType.connectionError) {
      return const NetworkException('No internet connection', statusCode: 0);
    }

    final code = statusCode ?? 0;
    return switch (code) {
      401 => AuthException(backendMsg ?? 'Not authorized', statusCode: 401),
      403 => AuthException(backendMsg ?? 'Forbidden', statusCode: 403),
      404 => NotFoundException(backendMsg ?? 'Not found', statusCode: 404),
      409 => ConflictException(backendMsg ?? 'Conflict', statusCode: 409),
      422 => ValidationException(
        backendMsg ?? 'Validation error',
        statusCode: 422,
      ),
      429 => RateLimitException(
        backendMsg ?? 'Too many requests',
        statusCode: 429,
        retryAfter: _extractRetryAfter(error.response),
      ),
      >= 500 => ServerException(
        backendMsg ?? 'Server error',
        statusCode: code,
      ),
      _ => ServerException(
        backendMsg ?? error.message ?? 'Unknown error',
        statusCode: code,
      ),
    };
  }

  static String? _extractBackendMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String) {
        return message;
      }
      if (message is List) {
        return message.join(', ');
      }
      final error = data['error'];
      if (error is String) {
        return error;
      }
    }
    return null;
  }

  static int? _extractRetryAfter(Response<dynamic>? response) {
    final header = response?.headers.value('retry-after');
    if (header == null) {
      return null;
    }
    return int.tryParse(header);
  }

  static Never _rethrowTyped(Object error) {
    if (error is DioException && error.error is AppException) {
      throw error.error! as AppException;
    }
    throw error;
  }

  // ---------------------------------------------------------------------------
  // HTTP methods — all delegate to _request to avoid duplication
  // ---------------------------------------------------------------------------

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(() => _dio.get<T>(path, queryParameters: queryParameters, options: options), 'GET');

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(() => _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options), 'POST');

  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(() => _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options), 'PUT');

  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(() => _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options), 'DELETE');

  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(() => _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options), 'PATCH');

  Future<T> _request<T>(
    Future<Response<T>> Function() execute,
    String method,
  ) async {
    try {
      final response = await execute();
      final data = response.data;
      if (data is! T) {
        throw ServerException(
          'Unexpected response type: ${data.runtimeType}',
          statusCode: response.statusCode,
        );
      }
      return data;
    } catch (e) {
      _logger.e('$method request failed: $e');
      _rethrowTyped(e);
    }
  }
}
