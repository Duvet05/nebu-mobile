import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import '../../presentation/providers/api_provider.dart';

/// Service to handle migration of activities from local UUID to authenticated user ID
/// This service is called after successful registration or login to transfer
/// all activities created while the user was using the app without an account
class ActivityMigrationService {
  ActivityMigrationService(this._ref);

  final Ref _ref;

  /// Check if there are activities to migrate
  /// Returns the local UUID if it exists and hasn't been migrated yet
  Future<String?> getLocalUserIdForMigration() async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    final localUserId = prefs.getString(StorageKeys.localUserId);
    final migrationCompleted =
        prefs.getBool(StorageKeys.activitiesMigrated) ?? false;

    if (localUserId != null && !migrationCompleted) {
      _ref
          .read(loggerProvider)
          .d(
            '📦 [MIGRATION] Found local user ID pending migration: $localUserId',
          );
      return localUserId;
    }

    return null;
  }

  /// Migrate activities from local UUID to authenticated user ID
  /// This should be called after successful registration or login
  ///
  /// Returns the number of activities migrated, or null if no migration was needed
  Future<int?> migrateIfNeeded(String newUserId) async {
    try {
      final localUserId = await getLocalUserIdForMigration();

      if (localUserId == null) {
        _ref.read(loggerProvider).d('✅ [MIGRATION] No migration needed');
        return null;
      }

      _ref
          .read(loggerProvider)
          .i(
            '🔄 [MIGRATION] Starting migration from $localUserId to $newUserId',
          );

      final activityService = _ref.read(activityServiceProvider);
      final result = await activityService.migrateActivities(
        localUserId: localUserId,
        newUserId: newUserId,
      );

      final migratedCount = result['migratedCount'] as int? ?? 0;

      // Mark migration as completed
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      await prefs.setBool(StorageKeys.activitiesMigrated, true);

      // Optionally remove the local user ID (keep it for reference)
      // await prefs.remove(StorageKeys.localUserId);

      _ref
          .read(loggerProvider)
          .i(
            '✅ [MIGRATION] Migration completed successfully: $migratedCount activities',
          );

      return migratedCount;
    } catch (e) {
      _ref
          .read(loggerProvider)
          .e('❌ [MIGRATION] Failed to migrate activities: $e');
      rethrow;
    }
  }

  /// Reset migration state (for testing or cleanup)
  Future<void> resetMigrationState() async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    await prefs.remove(StorageKeys.activitiesMigrated);
    _ref.read(loggerProvider).d('🔄 [MIGRATION] Migration state reset');
  }

  /// Check if activities have been migrated
  Future<bool> isMigrationCompleted() async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    return prefs.getBool(StorageKeys.activitiesMigrated) ?? false;
  }

  /// Clear local user ID and migration state
  /// Use this when you want to start fresh (e.g., after logout)
  Future<void> clearMigrationData() async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    await prefs.remove(StorageKeys.localUserId);
    await prefs.remove(StorageKeys.activitiesMigrated);
    _ref.read(loggerProvider).d('🗑️ [MIGRATION] Migration data cleared');
  }
}

/// Provider for ActivityMigrationService
final activityMigrationServiceProvider = Provider<ActivityMigrationService>(
  ActivityMigrationService.new,
);
