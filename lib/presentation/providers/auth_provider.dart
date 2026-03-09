import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/storage_keys.dart';
import '../../data/models/user.dart';
import '../../data/services/activity_migration_service.dart';
import '../../data/services/auth_service.dart';
import 'api_provider.dart';

export 'api_provider.dart' show sharedPreferencesProvider;

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() => _loadUserFromStorage();

  Future<User?> _loadUserFromStorage() async {
    try {
      final authService = await ref.watch(authServiceProvider.future);
      if (await authService.isAuthenticated()) {
        final userJson = await ref
            .watch(secureStorageProvider)
            .read(key: StorageKeys.user);
        if (userJson != null) {
          return User.fromJson(json.decode(userJson) as Map<String, dynamic>);
        }
      }
    } on Exception catch (e, st) {
      ref.read(loggerProvider).e('Load user failed', error: e, stackTrace: st);
    }
    return null;
  }

  /// Single pipeline for all auth flows: call service → validate → save → migrate.
  Future<void> _authenticate(
    Future<({bool success, User? user, String? error})> Function(
      AuthService service,
    )
    authCall,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = await ref.read(authServiceProvider.future);
      final response = await authCall(authService);
      if (response.success && response.user != null) {
        await _onAuthSuccess(response.user!);
        return response.user;
      }
      throw Exception(response.error ?? 'Authentication failed');
    });
  }

  Future<void> _onAuthSuccess(User user) async {
    await ref
        .read(secureStorageProvider)
        .write(key: StorageKeys.user, value: json.encode(user.toJson()));
    await ref.read(activityMigrationServiceProvider).migrateIfNeeded(user.id);
  }

  void clearError() {
    if (state.hasError) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login({required String identifier, required String password}) =>
      _authenticate((s) async {
        final r = await s.login(identifier: identifier, password: password);
        return (success: r.success, user: r.user, error: r.error);
      });

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) => _authenticate((s) async {
    final r = await s.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    return (success: r.success, user: r.user, error: r.error);
  });

  Future<void> loginWithGoogle(String token) => _authenticate((s) async {
    final r = await s.googleLogin(token);
    return (success: r.success, user: r.user, error: r.error);
  });

  Future<void> loginWithFacebook(String token) => _authenticate((s) async {
    final r = await s.facebookLogin(token);
    return (success: r.success, user: r.user, error: r.error);
  });

  Future<void> loginWithApple(String token) => _authenticate((s) async {
    final r = await s.appleLogin(token);
    return (success: r.success, user: r.user, error: r.error);
  });

  Future<void> updateUser(User user) async {
    await ref
        .read(secureStorageProvider)
        .write(key: StorageKeys.user, value: json.encode(user.toJson()));
    state = AsyncValue.data(user);
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await (await ref.read(authServiceProvider.future)).logout();
      await ref.read(secureStorageProvider).delete(key: StorageKeys.user);
      return null;
    });
  }

  Future<bool> requestPasswordReset(String email) async =>
      (await ref.read(authServiceProvider.future)).requestPasswordReset(email);

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async => (await ref.read(
    authServiceProvider.future,
  )).resetPassword(token: token, newPassword: newPassword);
}
