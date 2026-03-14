import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';
import '../../data/models/voice_session.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

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
    final cached = _loadFromCache(prefs);

    if (cached != null) {
      unawaited(_refreshIfStale(prefs));
      return cached;
    }

    return _fetchAndCache(prefs);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      return _fetchAndCache(prefs);
    });
  }

  VoiceMetrics? _loadFromCache(SharedPreferences prefs) {
    final raw = prefs.getString(StorageKeys.voiceMetricsCache);
    if (raw == null) {
      return null;
    }
    try {
      return VoiceMetrics.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Exception {
      return null;
    }
  }

  bool _isStale(SharedPreferences prefs) {
    final ts = prefs.getInt(StorageKeys.voiceMetricsCacheTs);
    if (ts == null) {
      return true;
    }
    return DateTime.now().millisecondsSinceEpoch - ts >
        _staleDuration.inMilliseconds;
  }

  Future<void> _refreshIfStale(SharedPreferences prefs) async {
    if (!_isStale(prefs)) {
      return;
    }
    var disposed = false;
    ref.onDispose(() => disposed = true);
    try {
      final fresh = await _fetchFromApi();
      if (disposed) {
        return;
      }
      await _saveToCache(prefs, fresh);
      state = AsyncValue.data(fresh);
    } on Exception catch (e) {
      // Cached data still showing; log for observability
      debugPrint('VoiceMetrics refresh failed: $e');
    }
  }

  Future<VoiceMetrics> _fetchAndCache(SharedPreferences prefs) async {
    final data = await _fetchFromApi();
    await _saveToCache(prefs, data);
    return data;
  }

  Future<VoiceMetrics> _fetchFromApi() {
    final service = ref.read(voiceSessionServiceProvider);
    return service.getMetrics();
  }

  Future<void> _saveToCache(SharedPreferences prefs, VoiceMetrics data) async {
    await prefs.setString(
      StorageKeys.voiceMetricsCache,
      jsonEncode(data.toJson()),
    );
    await prefs.setInt(
      StorageKeys.voiceMetricsCacheTs,
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
  static const _staleDuration = Duration(minutes: 15);

  @override
  Future<List<VoiceSession>> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null) {
      return [];
    }

    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final cached = _loadFromCache(prefs);

    if (cached != null) {
      unawaited(_refreshIfStale(prefs, user.id));
      return cached;
    }

    return _fetchAndCache(prefs, user.id);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authProvider).value;
      if (user == null) {
        return [];
      }
      final prefs = await ref.read(sharedPreferencesProvider.future);
      return _fetchAndCache(prefs, user.id);
    });
  }

  List<VoiceSession>? _loadFromCache(SharedPreferences prefs) {
    final raw = prefs.getString(StorageKeys.voiceSessionsCache);
    if (raw == null) {
      return null;
    }
    try {
      final list = jsonDecode(raw) as List;
      return list
          .cast<Map<String, dynamic>>()
          .map(VoiceSession.fromJson)
          .toList();
    } on Exception {
      return null;
    }
  }

  bool _isStale(SharedPreferences prefs) {
    final ts = prefs.getInt(StorageKeys.voiceSessionsCacheTs);
    if (ts == null) {
      return true;
    }
    return DateTime.now().millisecondsSinceEpoch - ts >
        _staleDuration.inMilliseconds;
  }

  Future<void> _refreshIfStale(SharedPreferences prefs, String userId) async {
    if (!_isStale(prefs)) {
      return;
    }
    var disposed = false;
    ref.onDispose(() => disposed = true);
    try {
      final fresh = await _fetchFromApi(userId);
      if (disposed) {
        return;
      }
      await _saveToCache(prefs, fresh);
      state = AsyncValue.data(fresh);
    } on Exception catch (e) {
      // Cached data still showing; log for observability
      debugPrint('UserVoiceSessions refresh failed: $e');
    }
  }

  Future<List<VoiceSession>> _fetchAndCache(
    SharedPreferences prefs,
    String userId,
  ) async {
    final data = await _fetchFromApi(userId);
    await _saveToCache(prefs, data);
    return data;
  }

  Future<List<VoiceSession>> _fetchFromApi(String userId) {
    final service = ref.read(voiceSessionServiceProvider);
    return service.getUserSessions(userId);
  }

  Future<void> _saveToCache(
    SharedPreferences prefs,
    List<VoiceSession> data,
  ) async {
    final json = jsonEncode(data.map((s) => s.toJson()).toList());
    await prefs.setString(StorageKeys.voiceSessionsCache, json);
    await prefs.setInt(
      StorageKeys.voiceSessionsCacheTs,
      DateTime.now().millisecondsSinceEpoch,
    );
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
    final cached = _loadFromCache(prefs);

    if (cached != null) {
      unawaited(_refreshIfStale(prefs));
      return cached;
    }

    return _fetchAndCache(prefs);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      return _fetchAndCache(prefs);
    });
  }

  UserLimits? _loadFromCache(SharedPreferences prefs) {
    final raw = prefs.getString(StorageKeys.userLimitsCache);
    if (raw == null) {
      return null;
    }
    try {
      return UserLimits.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Exception {
      return null;
    }
  }

  bool _isStale(SharedPreferences prefs) {
    final ts = prefs.getInt(StorageKeys.userLimitsCacheTs);
    if (ts == null) {
      return true;
    }
    return DateTime.now().millisecondsSinceEpoch - ts >
        _staleDuration.inMilliseconds;
  }

  Future<void> _refreshIfStale(SharedPreferences prefs) async {
    if (!_isStale(prefs)) {
      return;
    }
    var disposed = false;
    ref.onDispose(() => disposed = true);
    try {
      final fresh = await _fetchFromApi();
      if (disposed) {
        return;
      }
      await _saveToCache(prefs, fresh);
      state = AsyncValue.data(fresh);
    } on Exception catch (e) {
      // Cached data still showing; log for observability
      debugPrint('UserLimits refresh failed: $e');
    }
  }

  Future<UserLimits> _fetchAndCache(SharedPreferences prefs) async {
    final data = await _fetchFromApi();
    await _saveToCache(prefs, data);
    return data;
  }

  Future<UserLimits> _fetchFromApi() {
    final service = ref.read(voiceSessionServiceProvider);
    return service.getUserLimits();
  }

  Future<void> _saveToCache(SharedPreferences prefs, UserLimits data) async {
    await prefs.setString(
      StorageKeys.userLimitsCache,
      jsonEncode(data.toJson()),
    );
    await prefs.setInt(
      StorageKeys.userLimitsCacheTs,
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
