import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import '../../data/models/user.dart';
import '../../data/services/activity_migration_service.dart';
import '../../data/services/auth_service.dart';
import 'api_provider.dart';

// Re-export sharedPreferencesProvider for use in other files
export 'api_provider.dart' show sharedPreferencesProvider;

// Auth provider using AsyncNotifier for cleaner state management
final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() => _loadUserFromStorage();

  Future<User?> _loadUserFromStorage() async {
    try {
      final authService = await ref.watch(authServiceProvider.future);
      final secureStorage = ref.watch(secureStorageProvider);

      final isAuthenticated = await authService.isAuthenticated();
      if (isAuthenticated) {
        final userJson = await secureStorage.read(key: StorageKeys.user);
        if (userJson != null) {
          final user = User.fromJson(
            json.decode(userJson) as Map<String, dynamic>,
          );
          ref
              .read(loggerProvider)
              .d('👤 [AUTH] Loaded user from secure storage');
          return user;
        }
      }
    } on Exception catch (e, st) {
      ref
          .read(loggerProvider)
          .e('Failed to load user from storage', error: e, stackTrace: st);
    }
    return null;
  }

  Future<void> _saveUser(User user) async {
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.write(
      key: StorageKeys.user,
      value: json.encode(user.toJson()),
    );
    ref.read(loggerProvider).d('💾 [AUTH] User saved to secure storage');
  }

  /// Migrate activities from local UUID to authenticated user
  /// This is called automatically after successful login/register
  Future<void> _migrateActivities(String newUserId) async {
    try {
      final migrationService = ref.read(activityMigrationServiceProvider);
      final migratedCount = await migrationService.migrateIfNeeded(newUserId);

      if (migratedCount != null && migratedCount > 0) {
        ref
            .read(loggerProvider)
            .i(
              '✅ [AUTH] Successfully migrated $migratedCount activities for user $newUserId',
            );
      }
    } on Exception catch (e) {
      // Log error but don't fail the login/register process
      ref
          .read(loggerProvider)
          .e(
            '⚠️ [AUTH] Failed to migrate activities, but authentication succeeded: $e',
          );
    }
  }

  /// Clear any previous error state (e.g. when navigating between login/signup)
  void clearError() {
    if (state.hasError) {
      state = const AsyncValue.data(null);
    }
  }

  /// Single pipeline for all auth flows: call service → validate → save → migrate.
  Future<void> _authenticate(
    Future<AuthResponse> Function(AuthService service) authCall,
    String fallbackError,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = await ref.read(authServiceProvider.future);
      final response = await authCall(authService);
      if (response.success && response.user != null) {
        await _saveUser(response.user!);
        await _migrateActivities(response.user!.id);
        return response.user;
      }
      throw Exception(response.error ?? fallbackError);
    });
  }

  Future<void> login({required String identifier, required String password}) =>
      _authenticate(
        (s) => s.login(identifier: identifier, password: password),
        'Login failed',
      );

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) => _authenticate(
    (s) => s.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    ),
    'Registration failed',
  );

  Future<void> loginWithGoogle(String googleToken) =>
      _authenticate((s) => s.googleLogin(googleToken), 'Google login failed');

  Future<void> loginWithFacebook(String facebookToken) => _authenticate(
    (s) => s.facebookLogin(facebookToken),
    'Facebook login failed',
  );

  Future<void> loginWithApple(String appleToken) =>
      _authenticate((s) => s.appleLogin(appleToken), 'Apple login failed');

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      final authService = await ref.read(authServiceProvider.future);
      final secureStorage = ref.read(secureStorageProvider);
      await authService.logout();
      await secureStorage.delete(key: StorageKeys.user);
      state = const AsyncValue.data(null);
    } on Exception catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateUser(User user) async {
    await _saveUser(user);
    state = AsyncValue.data(user);
  }

  Future<bool> requestPasswordReset(String email) async {
    final authService = await ref.read(authServiceProvider.future);
    return authService.requestPasswordReset(email);
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final authService = await ref.read(authServiceProvider.future);
    return authService.resetPassword(token: token, newPassword: newPassword);
  }
}
