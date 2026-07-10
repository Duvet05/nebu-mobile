import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/errors/app_exception.dart';
import '../../data/models/activity.dart';
import '../../data/services/activity_service.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

/// Estado del log de actividades
class ActivityState {
  const ActivityState({
    this.activities = const [],
    this.stats,
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });
  final List<Activity> activities;
  final ActivityStats? stats;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  ActivityState copyWith({
    List<Activity>? activities,
    ActivityStats? stats,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) => ActivityState(
    activities: activities ?? this.activities,
    stats: stats ?? this.stats,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    hasMore: hasMore ?? this.hasMore,
    currentPage: currentPage ?? this.currentPage,
  );
}

/// Provider para gestionar el estado de actividades
class ActivityNotifier extends Notifier<ActivityState> {
  ActivityService get _activityService => ref.read(activityServiceProvider);

  @override
  ActivityState build() {
    // Do not retain another account's activities after auth transitions.
    ref.watch(authProvider).value?.id;
    return const ActivityState();
  }

  bool _isCurrentUser(String userId) =>
      ref.read(authProvider).value?.id == userId;

  /// Cargar actividades con filtros opcionales
  Future<void> loadActivities({
    required String userId,
    String? toyId,
    ActivityType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
    bool append = false,
  }) async {
    if (state.isLoading || !_isCurrentUser(userId)) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final response = await _activityService.getActivities(
        userId: userId,
        toyId: toyId,
        type: type,
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );
      if (!_isCurrentUser(userId)) {
        return;
      }

      final newActivities = append
          ? [...state.activities, ...response.activities]
          : response.activities;

      final hasMore = response.page < response.totalPages;

      state = state.copyWith(
        activities: newActivities,
        isLoading: false,
        hasMore: hasMore,
        currentPage: page,
      );
    } on NotFoundException {
      if (!_isCurrentUser(userId)) {
        return;
      }
      state = state.copyWith(
        activities: append ? state.activities : [],
        isLoading: false,
        hasMore: false,
      );
    } on Exception catch (e) {
      if (_isCurrentUser(userId)) {
        state = state.copyWith(isLoading: false, error: _mapErrorMessage(e));
      }
    } on Object catch (_) {
      if (_isCurrentUser(userId)) {
        state = state.copyWith(
          isLoading: false,
          error: 'activity_log.error_loading',
        );
      }
    }
  }

  /// Cargar más actividades (paginación)
  Future<void> loadMore({
    required String userId,
    String? toyId,
    ActivityType? type,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
  }) async {
    if (!state.hasMore || state.isLoading) {
      return;
    }

    await loadActivities(
      userId: userId,
      toyId: toyId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      page: state.currentPage + 1,
      limit: limit,
      append: true,
    );
  }

  /// Crear una nueva actividad
  Future<bool> createActivity({
    required String userId,
    required ActivityType type,
    required String description,
    String? toyId,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) async {
    try {
      if (!_isCurrentUser(userId)) {
        return false;
      }
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final sharingEnabled =
          prefs.getBool(
            StorageKeys.scoped(StorageKeys.privacyShareActivityData, userId),
          ) ??
          false;
      if (!sharingEnabled) {
        return false;
      }
      final activity = await _activityService.createActivity(
        userId: userId,
        toyId: toyId,
        type: type,
        description: description,
        metadata: metadata,
        timestamp: timestamp,
      );
      if (!_isCurrentUser(userId)) {
        return false;
      }

      // Agregar al inicio de la lista
      state = state.copyWith(activities: [activity, ...state.activities]);

      return true;
    } on Exception catch (e) {
      if (_isCurrentUser(userId)) {
        state = state.copyWith(error: _mapErrorMessage(e));
      }
      return false;
    }
  }

  /// Cargar estadísticas de actividades
  Future<void> loadStats(String userId) async {
    if (!_isCurrentUser(userId)) {
      return;
    }
    try {
      final stats = await _activityService.getActivityStats(userId);
      if (_isCurrentUser(userId)) {
        state = state.copyWith(stats: stats);
      }
    } on Exception catch (e) {
      if (_isCurrentUser(userId)) {
        state = state.copyWith(error: _mapErrorMessage(e));
      }
    }
  }

  /// Map exceptions to user-friendly i18n keys
  String _mapErrorMessage(Exception e) {
    if (e is NetworkException) {
      return 'errors.network';
    }
    if (e is AuthException) {
      return 'errors.unauthorized';
    }
    if (e is ServerException) {
      return 'errors.server';
    }
    return 'activity_log.error_loading';
  }

  /// Refrescar actividades (pull to refresh)
  Future<void> refresh({
    required String userId,
    String? toyId,
    ActivityType? type,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
  }) async {
    await loadActivities(
      userId: userId,
      toyId: toyId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }

  /// Limpiar estado
  void clear() {
    state = const ActivityState();
  }
}

/// Provider del notifier de actividades
final activityNotifierProvider =
    NotifierProvider<ActivityNotifier, ActivityState>(ActivityNotifier.new);

/// Provider para obtener actividades filtradas por tipo
final activitiesByTypeProvider = Provider.family<List<Activity>, ActivityType?>(
  (ref, type) {
    final state = ref.watch(activityNotifierProvider);
    if (type == null) {
      return state.activities;
    }
    return state.activities.where((a) => a.type == type).toList();
  },
);

/// Provider para obtener actividades por toy
final activitiesByToyProvider = Provider.family<List<Activity>, String?>((
  ref,
  toyId,
) {
  final state = ref.watch(activityNotifierProvider);
  if (toyId == null) {
    return state.activities;
  }
  return state.activities.where((a) => a.toyId == toyId).toList();
});

/// Provider para contar actividades por tipo
final activityCountByTypeProvider = Provider.family<int, ActivityType>((
  ref,
  type,
) {
  final activities = ref.watch(activitiesByTypeProvider(type));
  return activities.length;
});
