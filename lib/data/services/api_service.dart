import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../../core/config/config.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/error_reporting_service.dart';

class ApiService {
  ApiService({
    required this._dio,
    required this._secureStorage,
    required this._logger,
    this.onSessionExpired,
  }) {
    _setupDio();
  }

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;

  /// Called once when the server rejects the current refresh credentials.
  final void Function()? onSessionExpired;

  /// Completer used to serialize concurrent token refresh attempts.
  /// When non-null, a refresh is already in progress — other 401 handlers
  /// await the same future instead of firing a second refresh.
  Completer<String?>? _refreshCompleter;
  String? _refreshAccessToken;
  static const _skipSessionAuth = 'nebuSkipSessionAuth';
  ({String? previousAccessToken, String accessToken, String? refreshToken})?
  _lastRefresh;

  void _setupDio() {
    _dio.options.baseUrl = Config.apiBaseUrl;
    _dio.options.connectTimeout = Config.apiTimeout;
    _dio.options.receiveTimeout = Config.apiTimeout;
    _dio.options.sendTimeout = Config.apiTimeout;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!Config.isMinimalIosReleaseConfigured &&
              options.extra[_skipSessionAuth] != true) {
            final token = await _secureStorage.read(
              key: StorageKeys.accessToken,
            );

            if (options.extra['retried'] == true) {
              // Keep the retry bound to its original session. A later login
              // must not lend its credentials to an older account's request.
              if (token == null ||
                  token.isEmpty ||
                  options.headers['Authorization'] != 'Bearer $token') {
                return handler.reject(
                  DioException(
                    requestOptions: options,
                    type: DioExceptionType.cancel,
                    error: const AuthException(
                      'Session changed before retry',
                      statusCode: 401,
                    ),
                  ),
                );
              }
            } else if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          _logger.d('Request: ${options.method} ${options.path}');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          final path = error.requestOptions.path;
          final body = error.response?.data;
          final msg = _extractBackendMessage(body);
          _logger.e(
            'API $status ${error.requestOptions.method} $path'
            '${msg != null ? ' → $msg' : ''}',
          );

          // Only attempt refresh on 401 if we haven't already retried
          if (!Config.isMinimalIosReleaseConfigured &&
              error.requestOptions.extra[_skipSessionAuth] != true &&
              error.response?.statusCode == 401 &&
              error.requestOptions.extra['retried'] != true) {
            String? newToken;
            try {
              final authorization =
                  error.requestOptions.headers['Authorization'];
              newToken = await _refreshToken(
                authorization is String && authorization.startsWith('Bearer ')
                    ? authorization.substring(7)
                    : null,
              );
            } on Object catch (refreshError) {
              // Preserve the refresh failure's real category (network/5xx/auth).
              // Invalidation belongs to the shared refresh, not every waiter.
              return handler.reject(
                _typedDioError(
                  refreshError is DioException
                      ? refreshError
                      : DioException(
                          requestOptions: error.requestOptions,
                          error: refreshError,
                          message: 'Could not refresh session',
                        ),
                ),
              );
            }

            if (newToken != null) {
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newToken';
              error.requestOptions.extra['retried'] = true;
              try {
                final retryResponse = await _dio.fetch<dynamic>(
                  error.requestOptions,
                );
                return handler.resolve(retryResponse);
              } on DioException catch (retryError) {
                // A failed application request is not a rejected refresh token.
                return handler.reject(_typedDioError(retryError));
              }
            }
          }

          return handler.reject(_typedDioError(error));
        },
      ),
    );

    if (Config.enableDebugLogs) {
      _dio.interceptors.add(
        LogInterceptor(
          request: false,
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          error: false,
          logPrint: _logger.d,
        ),
      );
    }
  }

  /// Refreshes the access token, serializing concurrent attempts.
  /// Returns the new access token, or null if refresh is not possible.
  Future<String?> _refreshToken(String? failedAccessToken) {
    final running = _refreshCompleter;
    if (running != null) {
      // An old account's late 401 cannot join a newer account's renewal.
      return failedAccessToken == _refreshAccessToken
          ? running.future
          : Future<String?>.value();
    }

    // Publish the flight before the first storage await. Every caller receives
    // this exact future, including the initiating caller on an error path.
    final flight = Completer<String?>();
    _refreshAccessToken = failedAccessToken;
    _refreshCompleter = flight;
    unawaited(_completeRefresh(flight, failedAccessToken));
    return flight.future;
  }

  Future<void> _completeRefresh(
    Completer<String?> flight,
    String? failedAccessToken,
  ) async {
    try {
      flight.complete(await _performRefresh(failedAccessToken));
    } on Object catch (error, stackTrace) {
      unawaited(
        ErrorReportingService.recordError(
          error,
          stackTrace,
          reason: 'Token refresh request failed',
          context: {'handler': 'api_service_refresh'},
        ),
      );
      flight.completeError(error, stackTrace);
    } finally {
      if (identical(_refreshCompleter, flight)) {
        _refreshCompleter = null;
        _refreshAccessToken = null;
      }
    }
  }

  Future<String?> _performRefresh(String? failedAccessToken) async {
    final credentials = await _readCredentials();
    final refreshToken = credentials.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    if (credentials.accessToken != failedAccessToken) {
      // A late 401 may belong to the token this service has just renewed. Only
      // reuse that known rotation, never retry under an unrelated new login.
      final previous = _lastRefresh;
      if (previous != null &&
          previous.previousAccessToken == failedAccessToken &&
          previous.accessToken == credentials.accessToken &&
          previous.refreshToken == credentials.refreshToken) {
        return previous.accessToken;
      }
      return null;
    }

    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Authorization': null},
          extra: {_skipSessionAuth: true},
        ),
      );
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if ((status == 401 || status == 403) &&
          await _credentialsStillMatch(credentials)) {
        await _clearTokens();
        _lastRefresh = null;
        onSessionExpired?.call();
      }
      rethrow;
    }

    final newAccessToken = response.data?['accessToken'];
    final newRefreshToken = response.data?['refreshToken'];
    if (newAccessToken is! String ||
        newAccessToken.isEmpty ||
        (newRefreshToken != null &&
            (newRefreshToken is! String || newRefreshToken.isEmpty))) {
      throw const ServerException(
        'Invalid token refresh response',
        statusCode: 502,
      );
    }

    // A newer login/logout must not be overwritten by this older response.
    if (!await _credentialsStillMatch(credentials)) {
      return null;
    }
    await _secureStorage.write(
      key: StorageKeys.accessToken,
      value: newAccessToken,
    );
    if (newRefreshToken is String) {
      await _secureStorage.write(
        key: StorageKeys.refreshToken,
        value: newRefreshToken,
      );
    }
    _lastRefresh = (
      previousAccessToken: credentials.accessToken,
      accessToken: newAccessToken,
      refreshToken: newRefreshToken as String? ?? refreshToken,
    );
    return newAccessToken;
  }

  Future<({String? accessToken, String? refreshToken})>
  _readCredentials() async => (
    accessToken: await _secureStorage.read(key: StorageKeys.accessToken),
    refreshToken: await _secureStorage.read(key: StorageKeys.refreshToken),
  );

  // Secure storage is not transactional. This guards observed replacements;
  // an atomic boundary across AuthService writes would need shared locking.
  Future<bool> _credentialsStillMatch(
    ({String? accessToken, String? refreshToken}) expected,
  ) async => await _readCredentials() == expected;

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
      400 => ValidationException(backendMsg ?? 'Bad request', statusCode: 400),
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
      >= 500 => ServerException(backendMsg ?? 'Server error', statusCode: code),
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
  }) => _request(
    () => _dio.get<T>(path, queryParameters: queryParameters, options: options),
    'GET',
    path,
  );

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(
    () => _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
    'POST',
    path,
  );

  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(
    () => _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
    'PUT',
    path,
  );

  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(
    () => _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
    'DELETE',
    path,
  );

  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _request(
    () => _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
    'PATCH',
    path,
  );

  Future<T> _request<T>(
    Future<Response<T>> Function() execute,
    String method,
    String path,
  ) async {
    try {
      final response = await execute();
      final data = response.data;
      // void returns (DELETE, POST with no body) — data is null, which is correct
      if (null is T) {
        return data as T;
      }
      if (data is! T) {
        throw ServerException(
          'Unexpected response type: ${data.runtimeType}',
          statusCode: response.statusCode,
        );
      }
      return data;
    } on Exception catch (e, st) {
      _logger.e('$method request failed: $e');
      if (_shouldReportError(e)) {
        unawaited(
          ErrorReportingService.recordError(
            e,
            st,
            reason: 'API request failed',
            context: {'method': method, 'path': path},
          ),
        );
      }
      _rethrowTyped(e);
    } catch (e, st) {
      unawaited(
        ErrorReportingService.recordError(
          e,
          st,
          reason: 'Unexpected API request failure',
          context: {'method': method, 'path': path},
        ),
      );
      _rethrowTyped(e);
    }
  }

  bool _shouldReportError(Object error) {
    if (error is DioException && error.error is AppException) {
      return error.error is ServerException || error.error is NetworkException;
    }

    return true;
  }

  static DioException _typedDioError(DioException error) {
    final underlying = error.error;
    final appException = underlying is AppException
        ? underlying
        : _mapDioError(error);
    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: appException,
      message: appException.message,
    );
  }
}
