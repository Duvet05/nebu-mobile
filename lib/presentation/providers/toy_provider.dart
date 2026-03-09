import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';
import '../../data/models/toy.dart';
import '../../data/services/toy_service.dart';
import 'api_provider.dart';
import 'auth_provider.dart' as auth_provider;

// Toy state provider using AsyncNotifier
final toyProvider = AsyncNotifierProvider<ToyNotifier, List<Toy>>(
  ToyNotifier.new,
);

class ToyNotifier extends AsyncNotifier<List<Toy>> {
  @override
  Future<List<Toy>> build() => Future.value([]);

  ToyService get _toyService => ref.read(toyServiceProvider);

  /// Returns the current toy list, or reloads from API if state is error.
  /// This prevents the silent data-loss bug where `state.value ?? []`
  /// would return an empty list when the previous operation had failed.
  Future<List<Toy>> _currentToys() async {
    if (state.hasError) {
      ref.read(loggerProvider).w('Toy state was error, reloading from API');
      final toys = await _toyService.getMyToys();
      state = AsyncValue.data(toys);
      return toys;
    }
    return state.value ?? [];
  }

  /// Load user's toys
  Future<void> loadMyToys() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final toys = await _toyService.getMyToys();
      ref.read(loggerProvider).d('Loaded ${toys.length} toys');
      return toys;
    });
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

      final currentState = await _currentToys();
      state = AsyncValue.data([...currentState, toy]);

      return toy;
    } catch (e, st) {
      ref.read(loggerProvider).e('Error creating toy: $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Assign toy to user account
  Future<AssignToyResponse> assignToy({
    required String macAddress,
    required String userId,
    String? toyName,
  }) async {
    try {
      final response = await _toyService.assignToy(
        macAddress: macAddress,
        userId: userId,
        toyName: toyName,
      );

      ref
          .read(loggerProvider)
          .d('Toy assigned successfully: ${response.toy?.name}');

      if (response.toy != null) {
        final currentState = await _currentToys();
        state = AsyncValue.data([...currentState, response.toy!]);
      }

      return response;
    } catch (e, st) {
      ref.read(loggerProvider).e('Error assigning toy: $e');
      state = AsyncValue.error(e, st);
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
    try {
      final updatedToy = await _toyService.updateToyConnectionStatus(
        deviceId: deviceId,
        status: status,
        batteryLevel: batteryLevel,
        signalStrength: signalStrength,
      );

      ref.read(loggerProvider).d('Toy status updated: ${updatedToy.name}');

      final currentState = await _currentToys();
      final index = currentState.indexWhere((toy) => toy.id == updatedToy.id);
      if (index != -1) {
        final newList = [...currentState];
        newList[index] = updatedToy;
        state = AsyncValue.data(newList);
      }
    } catch (e, st) {
      ref.read(loggerProvider).e('Error updating toy status: $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Get a toy by ID — does NOT set error state on failure
  /// (a single toy fetch failure should not corrupt the entire list)
  Future<Toy> getToyById(String id) async {
    final toy = await _toyService.getToyById(id);
    ref.read(loggerProvider).d('Loaded toy: ${toy.name}');

    final currentState = await _currentToys();
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
    try {
      final updatedToy = await _toyService.updateToy(
        id: id,
        name: name,
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

      final currentState = await _currentToys();
      final index = currentState.indexWhere((toy) => toy.id == updatedToy.id);
      if (index != -1) {
        final newList = [...currentState];
        newList[index] = updatedToy;
        state = AsyncValue.data(newList);
      }

      return updatedToy;
    } catch (e, st) {
      ref.read(loggerProvider).e('Error updating toy: $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Unassign a toy (release from user without deleting it)
  Future<void> unassignToy(String id) async {
    try {
      await _toyService.unassignToy(id);
      ref.read(loggerProvider).d('Toy unassigned: $id');

      final currentState = await _currentToys();
      state = AsyncValue.data(
        currentState.where((toy) => toy.id != id).toList(),
      );
    } catch (e, st) {
      ref.read(loggerProvider).e('Error unassigning toy: $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Delete a toy
  Future<void> deleteToy(String id) async {
    try {
      await _toyService.deleteToy(id);
      ref.read(loggerProvider).d('Toy deleted: $id');

      final currentState = await _currentToys();
      state = AsyncValue.data(
        currentState.where((toy) => toy.id != id).toList(),
      );
    } catch (e, st) {
      ref.read(loggerProvider).e('Error deleting toy: $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Set the toy list directly
  void setToys(List<Toy> toys) {
    state = AsyncValue.data(toys);
  }

  /// Clear all toys
  void clear() {
    state = const AsyncValue.data([]);
  }

  // --- Local Toys (stored in SharedPreferences) ---

  /// Save a local toy to SharedPreferences
  Future<void> saveLocalToy(Toy toy) async {
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );
    final existing = prefs.getString(StorageKeys.localToys);
    final List<dynamic> toyList =
        existing != null ? json.decode(existing) as List<dynamic> : []
          ..add(toy.toJson());
    await prefs.setString(StorageKeys.localToys, json.encode(toyList));
    ref.read(loggerProvider).d('Local toy saved: ${toy.name}');

    final currentState = await _currentToys();
    state = AsyncValue.data([...currentState, toy]);
  }

  /// Load local toys from SharedPreferences
  Future<List<Toy>> loadLocalToys() async {
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );
    final stored = prefs.getString(StorageKeys.localToys);
    if (stored == null) {
      return [];
    }

    final List<dynamic> toyList = json.decode(stored) as List<dynamic>;
    final toys = toyList
        .map((e) => Toy.fromJson(e as Map<String, dynamic>))
        .toList();

    ref.read(loggerProvider).d('Loaded ${toys.length} local toys');
    return toys;
  }

  /// Remove a local toy from SharedPreferences
  Future<void> removeLocalToy(String id) async {
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );
    final stored = prefs.getString(StorageKeys.localToys);
    if (stored == null) {
      return;
    }

    final List<dynamic> toyList = json.decode(stored) as List<dynamic>
      ..removeWhere((e) => (e as Map<String, dynamic>)['id'] == id);
    await prefs.setString(StorageKeys.localToys, json.encode(toyList));
    ref.read(loggerProvider).d('Local toy removed: $id');

    final currentState = await _currentToys();
    state = AsyncValue.data(currentState.where((toy) => toy.id != id).toList());
  }
}

/// Whether any local toys exist in SharedPreferences.
/// Used by the router to skip welcome screen if user has already set up a toy.
final hasLocalToysProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final toysJson = prefs.getString(StorageKeys.localToys);
  return toysJson != null && toysJson != '[]' && toysJson.isNotEmpty;
});
