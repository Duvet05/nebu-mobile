import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/storage_keys.dart';
import '../../data/models/user.dart';
import '../../data/services/activity_migration_service.dart';
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
        if (userJson != null) return User.fromJson(json.decode(userJson));
      }
    } catch (e, st) {
      ref.read(loggerProvider).e('Load user failed', error: e, stackTrace: st);
    }
    return null;
  }

  // EL TUBO ÚNICO: Centraliza la lógica de éxito y error
  Future<void> _authenticate(Future<dynamic> Function() authCall) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await authCall();
      if (response.success && response.user != null) {
        await _onAuthSuccess(response.user!);
        return response.user;
      }
      throw response.error ?? 'Authentication failed';
    });
  }

  Future<void> _onAuthSuccess(User user) async {
    await ref
        .read(secureStorageProvider)
        .write(key: StorageKeys.user, value: json.encode(user.toJson()));
    await ref.read(activityMigrationServiceProvider).migrateIfNeeded(user.id);
  }

  void clearError() {
    if (state.hasError) state = const AsyncValue.data(null);
  }

  // Ahora los métodos son "Línea Directa"
  Future<void> login({required String identifier, required String password}) =>
      _authenticate(
        () => ref
            .read(authServiceProvider.future)
            .then((s) => s.login(identifier: identifier, password: password)),
      );

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) => _authenticate(
    () => ref
        .read(authServiceProvider.future)
        .then(
          (s) => s.register(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
          ),
        ),
  );

  Future<void> loginWithGoogle(String token) => _authenticate(
    () =>
        ref.read(authServiceProvider.future).then((s) => s.googleLogin(token)),
  );

  Future<void> loginWithFacebook(String token) => _authenticate(
    () => ref
        .read(authServiceProvider.future)
        .then((s) => s.facebookLogin(token)),
  );

  Future<void> loginWithApple(String token) => _authenticate(
    () => ref.read(authServiceProvider.future).then((s) => s.appleLogin(token)),
  );

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
