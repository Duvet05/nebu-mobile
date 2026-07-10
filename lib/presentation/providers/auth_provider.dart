import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/utils/error_reporting_service.dart';
import '../../data/models/user.dart';
import '../../data/services/activity_migration_service.dart';
import '../../data/services/auth_service.dart';
import 'api_provider.dart';

export 'api_provider.dart'
    show sessionExpiredProvider, sharedPreferencesProvider;

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<User?> {
  int _operationGeneration = 0;

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
          final user = User.fromJson(
            json.decode(userJson) as Map<String, dynamic>,
          );
          await _adoptLegacyLocalData(user.id);
          await _removeLegacyVoiceCaches();
          await _applyPrivacyContext(user.id);
          ref.read(apiServiceProvider).markSessionActive();
          unawaited(ref.read(firebasePushServiceProvider).initialize());
          return user;
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
    final operation = ++_operationGeneration;
    state = const AsyncValue.loading();
    try {
      final authService = await ref.read(authServiceProvider.future);
      final response = await authCall(authService);
      if (operation != _operationGeneration) {
        return;
      }
      if (response.success && response.user != null) {
        await _onAuthSuccess(response.user!);
        if (operation == _operationGeneration) {
          state = AsyncValue.data(response.user);
        }
        return;
      }
      final error = response.error ?? 'auth.login_error';
      // Translate if it's an i18n key (contains dots), otherwise show raw backend message
      throw Exception(error.contains('.') ? error.tr() : error);
    } on Object catch (error, stackTrace) {
      if (operation == _operationGeneration) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> _onAuthSuccess(User user) async {
    await _adoptLegacyLocalData(user.id);
    await _removeLegacyVoiceCaches();
    await ref
        .read(secureStorageProvider)
        .write(key: StorageKeys.user, value: json.encode(user.toJson()));
    ref.read(apiServiceProvider).markSessionActive();
    await _applyPrivacyContext(user.id);
    // Fire-and-forget: migration must never block login
    unawaited(() async {
      try {
        await ref
            .read(activityMigrationServiceProvider)
            .migrateIfNeeded(user.id);
      } on Exception catch (e) {
        ref
            .read(loggerProvider)
            .w('Activity migration failed (non-blocking): $e');
      }
    }());
    unawaited(ref.read(firebasePushServiceProvider).initialize());
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
    String? firstName,
    String? lastName,
    String? preferredLanguage,
  }) => _authenticate((s) async {
    final r = await s.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      preferredLanguage: preferredLanguage,
    );
    return (success: r.success, user: r.user, error: r.error);
  });

  Future<void> loginWithGoogle(String token) => _authenticate((s) async {
    final r = await s.googleLogin(token);
    // Google already verified the email — ensure router doesn't gate on emailVerified
    final user = r.user?.copyWith(emailVerified: true);
    return (success: r.success, user: user, error: r.error);
  });

  Future<void> loginWithFacebook(String token) => _authenticate((s) async {
    final r = await s.facebookLogin(token);
    final user = r.user?.copyWith(emailVerified: true);
    return (success: r.success, user: user, error: r.error);
  });

  Future<void> loginWithApple(String token) => _authenticate((s) async {
    final r = await s.appleLogin(token);
    final user = r.user?.copyWith(emailVerified: true);
    return (success: r.success, user: user, error: r.error);
  });

  Future<void> updateUser(User user) async {
    if (state.value?.id != user.id) {
      return;
    }
    await ref
        .read(secureStorageProvider)
        .write(key: StorageKeys.user, value: json.encode(user.toJson()));
    if (state.value?.id == user.id) {
      state = AsyncValue.data(user);
    }
  }

  /// Force logout without backend call — used when session expired.
  Future<void> forceLogout() async {
    final operation = ++_operationGeneration;
    await _clearRuntimeConnections(unregisterPush: false);
    final storage = ref.read(secureStorageProvider);
    await Future.wait([
      storage.delete(key: StorageKeys.accessToken),
      storage.delete(key: StorageKeys.refreshToken),
      storage.delete(key: StorageKeys.user),
    ]);
    await _clearTransientSetupData();
    await ErrorReportingService.clearUserContext();
    await ErrorReportingService.setCollectionEnabled(enabled: false);
    if (operation == _operationGeneration) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> logout() async {
    final operation = ++_operationGeneration;
    state = const AsyncValue.loading();
    await _clearRuntimeConnections(unregisterPush: true);
    try {
      await (await ref.read(authServiceProvider.future)).logout();
    } on Exception catch (e) {
      ref.read(loggerProvider).w('Backend logout failed: $e');
    }
    await ref.read(secureStorageProvider).delete(key: StorageKeys.user);
    await _clearTransientSetupData();
    await ErrorReportingService.clearUserContext();
    await ErrorReportingService.setCollectionEnabled(enabled: false);
    if (operation == _operationGeneration) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> _clearRuntimeConnections({required bool unregisterPush}) async {
    final pushService = ref.read(firebasePushServiceProvider);
    final bluetoothService = ref.read(bluetoothServiceProvider);
    final liveKitService = ref.read(liveKitServiceProvider);
    ref.read(deviceTokenServiceProvider).clearTokenCache();

    await Future.wait([
      if (unregisterPush)
        pushService.unregister()
      else
        pushService.resetLocal(),
      () async {
        await bluetoothService.stopScan();
        await bluetoothService.disconnect();
      }(),
      () async {
        try {
          await liveKitService.setMicrophoneEnabled(enabled: false);
        } on Exception catch (e) {
          ref.read(loggerProvider).w('Microphone cleanup failed: $e');
        }
        await liveKitService.disconnect();
      }(),
    ]);
  }

  Future<void> _removeLegacyVoiceCaches() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    for (final key in const [
      StorageKeys.voiceMetricsCache,
      StorageKeys.voiceMetricsCacheTs,
      StorageKeys.voiceSessionsCache,
      StorageKeys.voiceSessionsCacheTs,
      StorageKeys.userLimitsCache,
      StorageKeys.userLimitsCacheTs,
    ]) {
      await prefs.remove(key);
    }
  }

  Future<void> _adoptLegacyLocalData(String userId) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    for (final baseKey in const <String>[
      StorageKeys.localChildName,
      StorageKeys.localChildAge,
      StorageKeys.localChildPersonality,
      StorageKeys.localCustomPrompt,
      StorageKeys.localToys,
      StorageKeys.setupCompletedLocally,
    ]) {
      final scopedKey = StorageKeys.scoped(baseKey, userId);
      if (prefs.containsKey(scopedKey) || !prefs.containsKey(baseKey)) {
        continue;
      }
      final value = prefs.get(baseKey);
      final saved = switch (value) {
        final String value => await prefs.setString(scopedKey, value),
        final bool value => await prefs.setBool(scopedKey, value),
        final int value => await prefs.setInt(scopedKey, value),
        final double value => await prefs.setDouble(scopedKey, value),
        final List<String> value => await prefs.setStringList(scopedKey, value),
        _ => false,
      };
      if (saved) {
        await prefs.remove(baseKey);
      }
    }

    final storage = ref.read(secureStorageProvider);
    final legacyAvatar = await storage.read(key: StorageKeys.localAvatar);
    final scopedAvatarKey = StorageKeys.scoped(StorageKeys.localAvatar, userId);
    final scopedAvatar = await storage.read(key: scopedAvatarKey);
    if (scopedAvatar == null && legacyAvatar != null) {
      await storage.write(key: scopedAvatarKey, value: legacyAvatar);
      await storage.delete(key: StorageKeys.localAvatar);
    }
  }

  Future<void> _applyPrivacyContext(String userId) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final enabled =
        prefs.getBool(
          StorageKeys.scoped(StorageKeys.privacyAnalyticsEnabled, userId),
        ) ??
        false;
    await ErrorReportingService.clearUserContext();
    await ErrorReportingService.setCollectionEnabled(enabled: enabled);
    if (enabled) {
      await ErrorReportingService.setUserContext(userId: userId);
    }
  }

  Future<void> _clearTransientSetupData() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    for (final key in const <String>[
      StorageKeys.setupDeviceRegistered,
      StorageKeys.setupToyName,
      StorageKeys.setupToyId,
      StorageKeys.setupOwnerId,
      StorageKeys.setupMacAddress,
      StorageKeys.setupChildName,
      StorageKeys.setupChildAge,
      StorageKeys.setupPersonalityId,
      StorageKeys.setupVoicePreference,
      StorageKeys.setupFavorites,
      StorageKeys.voiceMetricsCache,
      StorageKeys.voiceMetricsCacheTs,
      StorageKeys.voiceSessionsCache,
      StorageKeys.voiceSessionsCacheTs,
      StorageKeys.userLimitsCache,
      StorageKeys.userLimitsCacheTs,
    ]) {
      await prefs.remove(key);
    }
  }

  Future<bool> requestPasswordReset(String email) async =>
      (await ref.read(authServiceProvider.future)).requestPasswordReset(email);

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async => (await ref.read(
    authServiceProvider.future,
  )).resetPassword(token: token, newPassword: newPassword);

  /// Re-fetch user profile from backend and update local state.
  /// Used after email verification to pick up emailVerified: true.
  Future<bool> refreshUser() async {
    final operation = _operationGeneration;
    final expectedUserId = state.value?.id;
    try {
      final userService = ref.read(userServiceProvider);
      final user = await userService.getCurrentUserProfile();
      if (operation != _operationGeneration ||
          (expectedUserId != null && expectedUserId != user.id)) {
        return false;
      }
      await _onAuthSuccess(user);
      if (operation != _operationGeneration) {
        return false;
      }
      state = AsyncValue.data(user);
      return true;
    } on Exception catch (e) {
      ref.read(loggerProvider).e('Failed to refresh user', error: e);
      return false;
    }
  }

  Future<bool> verifyEmail(String token) async =>
      (await ref.read(authServiceProvider.future)).verifyEmail(token);

  Future<bool> resendVerification(String email) async =>
      (await ref.read(authServiceProvider.future)).resendVerification(email);
}
