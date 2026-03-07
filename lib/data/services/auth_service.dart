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
      // Send as 'email' field for backend compatibility
      // The backend should accept both email and username in this field
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': identifier, 'password': password},
      );

      _logger.d('[AUTH] Login response received');

      // Use fromBackend to handle NestJS response format
      final authResponse = AuthResponse.fromBackend(response.data!);

      if (authResponse.success && authResponse.tokens != null) {
        await _storeTokens(authResponse.tokens!);
      }

      return authResponse;
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        error: _extractErrorMessage(e) ??
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
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
        },
      );

      // Use fromBackend to handle NestJS response format
      final authResponse = AuthResponse.fromBackend(response.data!);

      if (authResponse.success && authResponse.tokens != null) {
        await _storeTokens(authResponse.tokens!);
      }

      return authResponse;
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        error: _extractErrorMessage(e) ??
            'Registration failed. Please try again.',
      );
    } on Exception {
      return const AuthResponse(
        success: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  // Social Authentication
  Future<SocialAuthResult> googleLogin(String googleToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/google',
        data: {'token': googleToken},
      );

      // Use fromBackend to handle NestJS response format
      final authResult = SocialAuthResult.fromBackend(response.data!);

      if (authResult.success && authResult.tokens != null) {
        await _storeTokens(authResult.tokens!);
      }

      return authResult;
    } on DioException catch (e) {
      return SocialAuthResult(
        success: false,
        error:
            (e.response?.data['message'] as String?) ??
            'Google login failed. Please try again.',
      );
    } on Exception {
      return const SocialAuthResult(
        success: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  Future<SocialAuthResult> facebookLogin(String facebookToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/facebook',
        data: {'token': facebookToken},
      );

      // Use fromBackend to handle NestJS response format
      final authResult = SocialAuthResult.fromBackend(response.data!);

      if (authResult.success && authResult.tokens != null) {
        await _storeTokens(authResult.tokens!);
      }

      return authResult;
    } on DioException catch (e) {
      return SocialAuthResult(
        success: false,
        error:
            (e.response?.data['message'] as String?) ??
            'Facebook login failed. Please try again.',
      );
    } on Exception {
      return const SocialAuthResult(
        success: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  Future<SocialAuthResult> appleLogin(String appleToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/apple',
        data: {'token': appleToken},
      );

      // Use fromBackend to handle NestJS response format
      final authResult = SocialAuthResult.fromBackend(response.data!);

      if (authResult.success && authResult.tokens != null) {
        await _storeTokens(authResult.tokens!);
      }

      return authResult;
    } on DioException catch (e) {
      return SocialAuthResult(
        success: false,
        error:
            (e.response?.data['message'] as String?) ??
            'Apple login failed. Please try again.',
      );
    } on Exception {
      return const SocialAuthResult(
        success: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  /// Extract error message from backend response (supports 'message' and 'error' fields)
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
        throw Exception('No refresh token available');
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data?['accessToken'] as String?;
      if (newAccessToken == null) {
        throw Exception('No access token in refresh response');
      }
      await _secureStorage.write(
        key: StorageKeys.accessToken,
        value: newAccessToken,
      );

      return newAccessToken;
    } on Exception {
      await logout();
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
    } on Exception {
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
    } on Exception {
      return false;
    }
  }

  // Email Verification
  Future<bool> verifyEmail(String token) async {
    try {
      await _dio.post<void>('/auth/verify-email', data: {'token': token});
      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> resendVerificationEmail(String email) async {
    try {
      await _dio.post<void>(
        '/auth/resend-verification',
        data: {'email': email},
      );
      return true;
    } on Exception {
      return false;
    }
  }
}
