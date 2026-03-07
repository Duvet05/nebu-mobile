import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/conversation.dart';
import '../../data/services/memory_service.dart';
import 'api_provider.dart';

final memoryServiceProvider = Provider<MemoryService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final logger = ref.watch(loggerProvider);
  return MemoryService(apiService: apiService, logger: logger);
});

/// Conversations for a specific session
final sessionConversationsProvider =
    FutureProvider.family<List<Conversation>, String>((ref, sessionId) async {
  final service = ref.watch(memoryServiceProvider);
  return service.getSessionConversations(sessionId);
});

/// Memories for a specific toy
final toyMemoriesProvider =
    FutureProvider.family<List<MemoryEntry>, String>((ref, toyId) async {
  final service = ref.watch(memoryServiceProvider);
  return service.getToyMemories(toyId: toyId);
});

/// Insights for a specific toy
final toyInsightsProvider =
    FutureProvider.family<List<ConversationInsight>, String>((ref, toyId) async {
  final service = ref.watch(memoryServiceProvider);
  return service.getToyInsights(toyId: toyId);
});

/// Session metrics
final sessionMetricsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final service = ref.watch(memoryServiceProvider);
  return service.getSessionMetrics();
});

/// Memory search state
class MemorySearchNotifier extends StateNotifier<AsyncValue<List<MemoryEntry>>> {
  MemorySearchNotifier(this._service) : super(const AsyncValue.data([]));

  final MemoryService _service;

  Future<void> search({required String query, String? toyId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.searchMemory(query: query, toyId: toyId),
    );
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}

final memorySearchProvider =
    StateNotifierProvider<MemorySearchNotifier, AsyncValue<List<MemoryEntry>>>(
  (ref) => MemorySearchNotifier(ref.watch(memoryServiceProvider)),
);
