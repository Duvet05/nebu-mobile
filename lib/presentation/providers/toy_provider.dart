import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';
import '../../data/models/toy.dart';
import '../../data/services/local_toy_store.dart';
import '../../data/services/toy_service.dart';
import 'api_provider.dart';
import 'auth_provider.dart' as auth_provider;

// Toy state provider using AsyncNotifier
final toyProvider = AsyncNotifierProvider<ToyNotifier, List<Toy>>(
  ToyNotifier.new,
);

class ToyNotifier extends AsyncNotifier<List<Toy>> {
  @override
  Future<List<Toy>> build() {
    // Rebuild to an empty state immediately on logout/account switch.
    ref.watch(auth_provider.authProvider);
    return Future.value([]);
  }

  ToyService get _toyService => ref.read(toyServiceProvider);
  String? get _userId => ref.read(auth_provider.authProvider).value?.id;
  String _localToysKey(String? userId) => userId == null
      ? StorageKeys.localToys
      : StorageKeys.scoped(StorageKeys.localToys, userId);
  bool _isCurrentAccount(String? userId) => _userId == userId;

  /// Returns the current toy list, or reloads from API if state is error.
  /// This prevents the silent data-loss bug where `state.value ?? []`
  /// would return an empty list when the previous operation had failed.
  Future<List<Toy>> _currentToys(String? userId) async {
    if (!_isCurrentAccount(userId)) {
      return [];
    }
    if (state.hasError) {
      ref.read(loggerProvider).w('Toy state was error, reloading from API');
      final toys = await _toyService.getMyToys();
      if (_isCurrentAccount(userId)) {
        state = AsyncValue.data(toys);
      }
      return toys;
    }
    return state.value ?? [];
  }

  /// Load user's toys
  Future<void> loadMyToys() async {
    final userId = _userId;
    if (userId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      final toys = await _toyService.getMyToys();
      ref.read(loggerProvider).d('Loaded ${toys.length} toys');
      return toys;
    });
    if (_isCurrentAccount(userId)) {
      state = result;
    }
  }

  /// Create/register a new toy
  /// Backend auto-injects user from JWT. Identify device by [deviceId] (preferred) or [macAddress].
  Future<Toy> createToy({
    required String name,
    String? deviceId,
    String? macAddress,
    String? model,
    String? manufacturer,
    ToyStatus? status,
    String? firmwareVersion,
    Map<String, dynamic>? capabilities,
    Map<String, dynamic>? settings,
    String? notes,
    String? prompt,
    String? personalityProfile,
    String? greeting,
  }) async {
    final userId = _userId;
    try {
      final toy = await _toyService.createToy(
        name: name,
        deviceId: deviceId,
        macAddress: macAddress,
        model: model,
        manufacturer: manufacturer,
        status: status,
        firmwareVersion: firmwareVersion,
        capabilities: capabilities,
        settings: settings,
        notes: notes,
        prompt: prompt,
        personalityProfile: personalityProfile,
        greeting: greeting,
      );

      ref.read(loggerProvider).d('Toy created successfully: ${toy.name}');

      if (_isCurrentAccount(userId)) {
        final currentState = await _currentToys(userId);
        if (_isCurrentAccount(userId)) {
          state = AsyncValue.data([...currentState, toy]);
        }
      }

      return toy;
    } catch (e) {
      ref.read(loggerProvider).e('Error creating toy: $e');
      rethrow;
    }
  }

  /// Assign toy to user account
  Future<AssignToyResponse> assignToy({
    required String userId,
    String? deviceId,
    String? macAddress,
    String? toyName,
  }) async {
    final currentUserId = _userId;
    try {
      final response = await _toyService.assignToy(
        userId: userId,
        deviceId: deviceId,
        macAddress: macAddress,
        toyName: toyName,
      );

      ref
          .read(loggerProvider)
          .d('Toy assigned successfully: ${response.toy?.name}');

      if (response.toy != null && _isCurrentAccount(currentUserId)) {
        final currentState = await _currentToys(currentUserId);
        if (_isCurrentAccount(currentUserId)) {
          state = AsyncValue.data([...currentState, response.toy!]);
        }
      }

      return response;
    } catch (e) {
      ref.read(loggerProvider).e('Error assigning toy: $e');
      rethrow;
    }
  }

  /// Update toy connection status
  Future<void> updateToyConnectionStatus({
    required String deviceId,
    required ToyStatus status,
    String? batteryLevel,
    String? signalStrength,
  }) async {
    final userId = _userId;
    try {
      final updatedToy = await _toyService.updateToyConnectionStatus(
        deviceId: deviceId,
        status: status,
        batteryLevel: batteryLevel,
        signalStrength: signalStrength,
      );

      ref.read(loggerProvider).d('Toy status updated: ${updatedToy.name}');

      if (!_isCurrentAccount(userId)) {
        return;
      }
      final currentState = await _currentToys(userId);
      if (!_isCurrentAccount(userId)) {
        return;
      }
      final index = currentState.indexWhere((toy) => toy.id == updatedToy.id);
      if (index != -1) {
        final newList = [...currentState];
        newList[index] = updatedToy;
        state = AsyncValue.data(newList);
      }
    } on Exception catch (e) {
      // BLE status ping failure should NOT corrupt the entire toy list state
      ref.read(loggerProvider).e('Error updating toy status: $e');
    }
  }

  /// Get a toy by ID — does NOT set error state on failure
  /// (a single toy fetch failure should not corrupt the entire list)
  Future<Toy> getToyById(String id) async {
    final userId = _userId;
    final toy = await _toyService.getToyById(id);
    ref.read(loggerProvider).d('Loaded toy: ${toy.name}');

    if (!_isCurrentAccount(userId)) {
      return toy;
    }
    final currentState = await _currentToys(userId);
    if (!_isCurrentAccount(userId)) {
      return toy;
    }
    final index = currentState.indexWhere((t) => t.id == toy.id);
    if (index != -1) {
      final newList = [...currentState];
      newList[index] = toy;
      state = AsyncValue.data(newList);
    } else {
      state = AsyncValue.data([...currentState, toy]);
    }

    return toy;
  }

  /// Update toy information
  Future<Toy> updateToy({
    required String id,
    String? name,
    String? ownerId,
    String? model,
    String? manufacturer,
    ToyStatus? status,
    String? firmwareVersion,
    Map<String, dynamic>? capabilities,
    Map<String, dynamic>? settings,
    String? notes,
    String? prompt,
    String? personalityProfile,
    String? greeting,
  }) async {
    final userId = _userId;
    try {
      final updatedToy = await _toyService.updateToy(
        id: id,
        name: name,
        ownerId: ownerId,
        model: model,
        manufacturer: manufacturer,
        status: status,
        firmwareVersion: firmwareVersion,
        capabilities: capabilities,
        settings: settings,
        notes: notes,
        prompt: prompt,
        personalityProfile: personalityProfile,
        greeting: greeting,
      );

      ref.read(loggerProvider).d('Toy updated: ${updatedToy.name}');

      if (!_isCurrentAccount(userId)) {
        return updatedToy;
      }
      final currentState = await _currentToys(userId);
      if (!_isCurrentAccount(userId)) {
        return updatedToy;
      }
      final index = currentState.indexWhere((toy) => toy.id == updatedToy.id);
      if (index != -1) {
        final newList = [...currentState];
        newList[index] = updatedToy;
        state = AsyncValue.data(newList);
      }

      return updatedToy;
    } catch (e) {
      ref.read(loggerProvider).e('Error updating toy: $e');
      rethrow;
    }
  }

  /// Unassign a toy (release from user without deleting it)
  Future<void> unassignToy(String id) async {
    final userId = _userId;
    try {
      await _toyService.unassignToy(id);
      ref.read(loggerProvider).d('Toy unassigned: $id');

      if (!_isCurrentAccount(userId)) {
        return;
      }
      final currentState = await _currentToys(userId);
      if (!_isCurrentAccount(userId)) {
        return;
      }
      state = AsyncValue.data(
        currentState.where((toy) => toy.id != id).toList(),
      );
    } catch (e) {
      ref.read(loggerProvider).e('Error unassigning toy: $e');
      rethrow;
    }
  }

  /// Delete a toy
  Future<void> deleteToy(String id) async {
    final userId = _userId;
    try {
      await _toyService.deleteToy(id);
      ref.read(loggerProvider).d('Toy deleted: $id');

      if (!_isCurrentAccount(userId)) {
        return;
      }
      final currentState = await _currentToys(userId);
      if (!_isCurrentAccount(userId)) {
        return;
      }
      state = AsyncValue.data(
        currentState.where((toy) => toy.id != id).toList(),
      );
    } catch (e) {
      ref.read(loggerProvider).e('Error deleting toy: $e');
      rethrow;
    }
  }

  /// Set the toy list directly
  void setToys(List<Toy> toys, {required String? expectedUserId}) {
    if (_isCurrentAccount(expectedUserId)) {
      state = AsyncValue.data(toys);
    }
  }

  /// Clear all toys
  void clear() {
    state = const AsyncValue.data([]);
  }

  // --- Local Toys (stored in SharedPreferences) ---

  /// Save a local toy to SharedPreferences
  Future<void> saveLocalToy(Toy toy) async {
    final userId = _userId;
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );
    final storageKey = _localToysKey(userId);
    final existing = prefs.getString(storageKey);
    final decoded = existing != null
        ? (json.decode(existing) as List<dynamic>).map(
            (entry) => Map<String, dynamic>.from(entry as Map<String, dynamic>),
          )
        : const Iterable<Map<String, dynamic>>.empty();
    final toyList = upsertLocalToyEntry(decoded, toy.toJson());
    await prefs.setString(storageKey, json.encode(toyList));
    ref.read(loggerProvider).d('Local toy saved: ${toy.name}');
    if (!_isCurrentAccount(userId)) {
      return;
    }

    final currentState = await _currentToys(userId);
    if (!_isCurrentAccount(userId)) {
      return;
    }
    final existingIndex = currentState.indexWhere(
      (entry) => entry.id == toy.id,
    );
    if (existingIndex == -1) {
      state = AsyncValue.data([...currentState, toy]);
    } else {
      final updated = [...currentState];
      updated[existingIndex] = toy;
      state = AsyncValue.data(updated);
    }
  }

  /// Load local toys from SharedPreferences
  Future<List<Toy>> loadLocalToys() async {
    final userId = _userId;
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );
    final stored = prefs.getString(_localToysKey(userId));
    if (stored == null) {
      return [];
    }

    final List<dynamic> toyList = json.decode(stored) as List<dynamic>;
    final toys = toyList
        .map((e) => Toy.fromJson(e as Map<String, dynamic>))
        .toList();

    if (!_isCurrentAccount(userId)) {
      return [];
    }

    ref.read(loggerProvider).d('Loaded ${toys.length} local toys');
    return toys;
  }

  /// Remove a local toy from SharedPreferences
  Future<void> removeLocalToy(String id) async {
    final userId = _userId;
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );
    final storageKey = _localToysKey(userId);
    final stored = prefs.getString(storageKey);
    if (stored == null) {
      return;
    }

    final List<dynamic> toyList = json.decode(stored) as List<dynamic>
      ..removeWhere((e) => (e as Map<String, dynamic>)['id'] == id);
    await prefs.setString(storageKey, json.encode(toyList));
    ref.read(loggerProvider).d('Local toy removed: $id');
    if (!_isCurrentAccount(userId)) {
      return;
    }

    final currentState = await _currentToys(userId);
    if (!_isCurrentAccount(userId)) {
      return;
    }
    state = AsyncValue.data(currentState.where((toy) => toy.id != id).toList());
  }
}

/// Whether any local toys exist in SharedPreferences.
/// Used by the router to skip welcome screen if user has already set up a toy.
final hasLocalToysProvider = FutureProvider<bool>((ref) async {
  final userId = ref.watch(auth_provider.authProvider).value?.id;
  final prefs = await ref.watch(auth_provider.sharedPreferencesProvider.future);
  final storageKey = userId == null
      ? StorageKeys.localToys
      : StorageKeys.scoped(StorageKeys.localToys, userId);
  final toysJson = prefs.getString(storageKey);
  return toysJson != null && toysJson != '[]' && toysJson.isNotEmpty;
});

/// Whether the user explicitly skipped setup to enter guest mode.
final setupSkippedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(StorageKeys.setupSkipped) ?? false;
});
