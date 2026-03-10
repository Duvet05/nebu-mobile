import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';
import '../../data/models/personality.dart';
import '../../data/services/personality_service.dart';
import 'api_provider.dart';

final personalityServiceProvider = Provider<PersonalityService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final logger = ref.watch(loggerProvider);
  return PersonalityService(apiService: apiService, logger: logger);
});

final personalitiesProvider =
    AsyncNotifierProvider<PersonalitiesNotifier, List<Personality>>(
      PersonalitiesNotifier.new,
    );

class PersonalitiesNotifier extends AsyncNotifier<List<Personality>> {
  static const _staleDuration = Duration(minutes: 30);

  @override
  Future<List<Personality>> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final cached = _loadFromCache(prefs);

    if (cached != null) {
      // Serve cache immediately; refresh in background if stale
      unawaited(_refreshIfStale(prefs));
      return cached;
    }

    // No cache — must fetch
    return _fetchAndCache(prefs);
  }

  /// Force refresh from API, ignoring cache TTL.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      return _fetchAndCache(prefs);
    });
  }

  // ── Cache helpers ───────────────────────────────────────────────────

  List<Personality>? _loadFromCache(SharedPreferences prefs) {
    final raw = prefs.getString(StorageKeys.personalitiesCache);
    if (raw == null) {
      return null;
    }
    try {
      final list = jsonDecode(raw) as List;
      return list
          .cast<Map<String, dynamic>>()
          .map(Personality.fromJson)
          .toList();
    } on Exception {
      return null;
    }
  }

  bool _isStale(SharedPreferences prefs) {
    final ts = prefs.getInt(StorageKeys.personalitiesCacheTs);
    if (ts == null) {
      return true;
    }
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    return age > _staleDuration.inMilliseconds;
  }

  Future<void> _refreshIfStale(SharedPreferences prefs) async {
    if (!_isStale(prefs)) {
      return;
    }
    try {
      final fresh = await _fetchFromApi();
      await _saveToCache(prefs, fresh);
      state = AsyncValue.data(fresh);
    } on Exception {
      // Silent — cached data is already showing
    }
  }

  Future<List<Personality>> _fetchAndCache(SharedPreferences prefs) async {
    final data = await _fetchFromApi();
    await _saveToCache(prefs, data);
    return data;
  }

  Future<List<Personality>> _fetchFromApi() {
    final service = ref.read(personalityServiceProvider);
    return service.getPersonalities();
  }

  Future<void> _saveToCache(
    SharedPreferences prefs,
    List<Personality> data,
  ) async {
    final json = jsonEncode(data.map((p) => p.toJson()).toList());
    await prefs.setString(StorageKeys.personalitiesCache, json);
    await prefs.setInt(
      StorageKeys.personalitiesCacheTs,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
