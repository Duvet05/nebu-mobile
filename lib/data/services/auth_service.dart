import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/config.dart';
import '../../core/constants/storage_keys.dart';
import '../models/user.dart';

class AuthService {
  AuthService({
    required Dio dio,
    required SharedPreferences prefs,
    required FlutterSecureStorage secureStorage,
    required Logger logger,
  }) : _dio = dio,
       _prefs = prefs,
       _secureStorage = secureStorage,
       _logger = logger {
    _dio.options.baseUrl = Config.apiBaseUrl;
    _dio.options.connectTimeout = Config.apiTimeout;
    _dio.options.receiveTimeout = Config.apiTimeout;
    _dio.options.sendTimeout = Config.apiTimeout;
  }
  final Dio _dio;
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;

  // Email/Password Authentication
  Future<AuthResponse> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': identifier, 'password': password},
      );

      _logger.d('[AUTH] Login response received');

      final authResponse = AuthResponse.fromBackend(response.data!);

      if (authResponse.success && authResponse.tokens != null) {
        await _storeTokens(authResponse.tokens!);
      }

      return authResponse;
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        error:
            _extractErrorMessage(e) ??
            'Login failed. Please check your credentials.',
      );
    } on Exception {
      return const AuthResponse(
        success: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'firstName': 'Usuario',
          'lastName': 'Nebu',
        },
      );

      final authResponse = AuthResponse.fromBackend(response.data!);

      if (authResponse.success && authResponse.tokens != null) {
        await _storeTokens(authResponse.tokens!);
      }

      return authResponse;
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        error:
            _extractErrorMessage(e) ?? 'Registration failed. Please try again.',
      );
    } on Exception {
      return const AuthResponse(
        success: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  // Social Authentication — single implementation for all providers
  Future<SocialAuthResult> googleLogin(String token) =>
      _socialLogin('/auth/google', token, 'Google');

  Future<SocialAuthResult> facebookLogin(String token) =>
      _socialLogin('/auth/facebook', token, 'Facebook');

  Future<SocialAuthResult> appleLogin(String token) =>
      _socialLogin('/auth/apple', token, 'Apple');

  Future<SocialAuthResult> _socialLogin(
    String endpoint,
    String token,
    String providerName,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        endpoint,
        data: {'token': token},
      );

      final authResult = SocialAuthResult.fromBackend(response.data!);

      if (authResult.success && authResult.tokens != null) {
        await _storeTokens(authResult.tokens!);
      }

      return authResult;
    } on DioException catch (e) {
      return SocialAuthResult(
        success: false,
        error:
            _extractErrorMessage(e) ??
            '$providerName login failed. Please try again.',
      );
    } on Exception {
      return const SocialAuthResult(
        success: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  /// Extract error message from backend response.
  static String? _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String) {
        return _cleanMessage(message);
      }
      if (message is List) {
        return _cleanMessage(message.join(', '));
      }
      final error = data['error'];
      if (error is String) {
        return _cleanMessage(error);
      }
    }
    return null;
  }

  /// Remove technical prefixes from backend error messages
  static String _cleanMessage(String msg) => msg
      .replaceFirst(RegExp(r'^Validation failed:\s*'), '')
      .replaceFirst(RegExp(r'^Error:\s*'), '');

  // Token Management
  Future<void> _storeTokens(AuthTokens tokens) async {
    await _secureStorage.write(
      key: StorageKeys.accessToken,
      value: tokens.accessToken,
    );
    await _secureStorage.write(
      key: StorageKeys.refreshToken,
      value: tokens.refreshToken,
    );
  }

  Future<String?> getAccessToken() async =>
      _secureStorage.read(key: StorageKeys.accessToken);

  Future<String?> getRefreshToken() async =>
      _secureStorage.read(key: StorageKeys.refreshToken);

  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        _logger.w('No refresh token available, logging out');
        await logout();
        return null;
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data?['accessToken'] as String?;
      if (newAccessToken == null) {
        _logger.w('No access token in refresh response, logging out');
        await logout();
        return null;
      }
      await _secureStorage.write(
        key: StorageKeys.accessToken,
        value: newAccessToken,
      );

      return newAccessToken;
    } on DioException catch (e) {
      // Only logout on auth errors (401/403), not transient network issues
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        _logger.w('Refresh token rejected ($statusCode), logging out');
        await logout();
      } else {
        _logger.w('Transient error during token refresh: $e');
      }
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final token = await _secureStorage.read(key: StorageKeys.accessToken);
      if (token != null && token.isNotEmpty) {
        await _dio.post<void>(
          '/auth/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } on Exception catch (e) {
      _logger.w('Backend logout failed (clearing locally anyway): $e');
    }
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
    await _prefs.remove(StorageKeys.user);
  }

  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  // Password Reset
  Future<bool> requestPasswordReset(String email) async {
    try {
      await _dio.post<void>('/auth/forgot-password', data: {'email': email});
      return true;
    } on DioException catch (e) {
      _logger.e('Password reset request failed: ${e.message}');
      return false;
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _dio.post<void>(
        '/auth/reset-password',
        data: {'token': token, 'newPassword': newPassword},
      );
      return true;
    } on DioException catch (e) {
      _logger.e('Password reset failed: ${e.message}');
      return false;
    }
  }
}
