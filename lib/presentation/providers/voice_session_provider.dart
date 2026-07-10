import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';
import '../../data/models/voice_session.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

String _scopedCacheKey(String baseKey, String userId) => '$baseKey:$userId';

// ── Voice Metrics (TTL: 15 min) ─────────────────────────────────────────

final voiceMetricsProvider =
    AsyncNotifierProvider<VoiceMetricsNotifier, VoiceMetrics>(
      VoiceMetricsNotifier.new,
    );

class VoiceMetricsNotifier extends AsyncNotifier<VoiceMetrics> {
  static const _staleDuration = Duration(minutes: 15);

  @override
  Future<VoiceMetrics> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null) {
      return const VoiceMetrics();
    }

    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final cached = _loadFromCache(prefs, user.id);

    if (cached != null) {
      unawaited(_refreshIfStale(prefs, user.id));
      return cached;
    }

    return _fetchAndCache(prefs, user.id);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final user = ref.read(authProvider).value;
      if (user == null) {
        return const VoiceMetrics();
      }
      return _fetchAndCache(prefs, user.id);
    });
  }

  VoiceMetrics? _loadFromCache(SharedPreferences prefs, String userId) {
    final raw = prefs.getString(
      _scopedCacheKey(StorageKeys.voiceMetricsCache, userId),
    );
    if (raw == null) {
      return null;
    }
    try {
      return VoiceMetrics.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Exception {
      return null;
    }
  }

  bool _isStale(SharedPreferences prefs, String userId) {
    final ts = prefs.getInt(
      _scopedCacheKey(StorageKeys.voiceMetricsCacheTs, userId),
    );
    if (ts == null) {
      return true;
    }
    return DateTime.now().millisecondsSinceEpoch - ts >
        _staleDuration.inMilliseconds;
  }

  Future<void> _refreshIfStale(SharedPreferences prefs, String userId) async {
    if (!_isStale(prefs, userId)) {
      return;
    }
    var disposed = false;
    ref.onDispose(() => disposed = true);
    try {
      final fresh = await _fetchFromApi();
      if (disposed || ref.read(authProvider).value?.id != userId) {
        return;
      }
      await _saveToCache(prefs, userId, fresh);
      state = AsyncValue.data(fresh);
    } on Exception catch (e) {
      // Cached data still showing; log for observability
      ref.read(loggerProvider).w('VoiceMetrics refresh failed: $e');
    }
  }

  Future<VoiceMetrics> _fetchAndCache(
    SharedPreferences prefs,
    String userId,
  ) async {
    final data = await _fetchFromApi();
    await _saveToCache(prefs, userId, data);
    return data;
  }

  Future<VoiceMetrics> _fetchFromApi() {
    final service = ref.read(voiceSessionServiceProvider);
    return service.getMetrics();
  }

  Future<void> _saveToCache(
    SharedPreferences prefs,
    String userId,
    VoiceMetrics data,
  ) async {
    await prefs.setString(
      _scopedCacheKey(StorageKeys.voiceMetricsCache, userId),
      jsonEncode(data.toJson()),
    );
    await prefs.setInt(
      _scopedCacheKey(StorageKeys.voiceMetricsCacheTs, userId),
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}

// ── User Voice Sessions (TTL: 15 min) ──────────────────────────────────

final userVoiceSessionsProvider =
    AsyncNotifierProvider<UserVoiceSessionsNotifier, List<VoiceSession>>(
      UserVoiceSessionsNotifier.new,
    );

class UserVoiceSessionsNotifier extends AsyncNotifier<List<VoiceSession>> {
  @override
  Future<List<VoiceSession>> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null) {
      return [];
    }
    // Session summaries can contain child data. Keep them in provider memory
    // only; never persist them in SharedPreferences across accounts.
    return _fetchFromApi(user.id);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authProvider).value;
      if (user == null) {
        return [];
      }
      return _fetchFromApi(user.id);
    });
  }

  Future<List<VoiceSession>> _fetchFromApi(String userId) {
    final service = ref.read(voiceSessionServiceProvider);
    return service.getUserSessions(userId);
  }
}

// ── User Limits (TTL: 60 min) ──────────────────────────────────────────

final userLimitsProvider =
    AsyncNotifierProvider<UserLimitsNotifier, UserLimits>(
      UserLimitsNotifier.new,
    );

class UserLimitsNotifier extends AsyncNotifier<UserLimits> {
  static const _staleDuration = Duration(minutes: 60);

  @override
  Future<UserLimits> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null) {
      return const UserLimits();
    }

    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final cached = _loadFromCache(prefs, user.id);

    if (cached != null) {
      unawaited(_refreshIfStale(prefs, user.id));
      return cached;
    }

    return _fetchAndCache(prefs, user.id);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final user = ref.read(authProvider).value;
      if (user == null) {
        return const UserLimits();
      }
      return _fetchAndCache(prefs, user.id);
    });
  }

  UserLimits? _loadFromCache(SharedPreferences prefs, String userId) {
    final raw = prefs.getString(
      _scopedCacheKey(StorageKeys.userLimitsCache, userId),
    );
    if (raw == null) {
      return null;
    }
    try {
      return UserLimits.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Exception {
      return null;
    }
  }

  bool _isStale(SharedPreferences prefs, String userId) {
    final ts = prefs.getInt(
      _scopedCacheKey(StorageKeys.userLimitsCacheTs, userId),
    );
    if (ts == null) {
      return true;
    }
    return DateTime.now().millisecondsSinceEpoch - ts >
        _staleDuration.inMilliseconds;
  }

  Future<void> _refreshIfStale(SharedPreferences prefs, String userId) async {
    if (!_isStale(prefs, userId)) {
      return;
    }
    var disposed = false;
    ref.onDispose(() => disposed = true);
    try {
      final fresh = await _fetchFromApi();
      if (disposed || ref.read(authProvider).value?.id != userId) {
        return;
      }
      await _saveToCache(prefs, userId, fresh);
      state = AsyncValue.data(fresh);
    } on Exception catch (e) {
      // Cached data still showing; log for observability
      ref.read(loggerProvider).w('UserLimits refresh failed: $e');
    }
  }

  Future<UserLimits> _fetchAndCache(
    SharedPreferences prefs,
    String userId,
  ) async {
    final data = await _fetchFromApi();
    await _saveToCache(prefs, userId, data);
    return data;
  }

  Future<UserLimits> _fetchFromApi() {
    final service = ref.read(voiceSessionServiceProvider);
    return service.getUserLimits();
  }

  Future<void> _saveToCache(
    SharedPreferences prefs,
    String userId,
    UserLimits data,
  ) async {
    await prefs.setString(
      _scopedCacheKey(StorageKeys.userLimitsCache, userId),
      jsonEncode(data.toJson()),
    );
    await prefs.setInt(
      _scopedCacheKey(StorageKeys.userLimitsCacheTs, userId),
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}

// ── Session Conversations (no cache — per-session, on-demand) ──────────

final sessionConversationsProvider =
    FutureProvider.family<List<AiConversation>, String>((ref, sessionId) async {
      final user = ref.watch(authProvider).value;
      if (user == null) {
        return [];
      }
      final service = ref.watch(voiceSessionServiceProvider);
      return service.getSessionConversations(sessionId);
    });
