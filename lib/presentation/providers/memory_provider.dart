import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/conversation.dart';
import '../../data/services/memory_service.dart';
import 'api_provider.dart';

final memoryServiceProvider = Provider<MemoryService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final logger = ref.watch(loggerProvider);
  return MemoryService(apiService: apiService, logger: logger);
});

/// Recent memories for a specific toy
final toyMemoriesProvider =
    FutureProvider.family<List<MemoryEntry>, String>((ref, toyId) async {
  final service = ref.watch(memoryServiceProvider);
  return service.getRecentMemories(toyId: toyId);
});

/// Memory search
class MemorySearchNotifier extends Notifier<AsyncValue<List<MemoryEntry>>> {
  @override
  AsyncValue<List<MemoryEntry>> build() => const AsyncValue.data([]);

  Future<void> search({required String query, required String toyId}) async {
    state = const AsyncValue<List<MemoryEntry>>.loading();
    final service = ref.read(memoryServiceProvider);
    state = await AsyncValue.guard(
      () => service.searchMemories(toyId: toyId, query: query),
    );
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}

final memorySearchProvider =
    NotifierProvider<MemorySearchNotifier, AsyncValue<List<MemoryEntry>>>(
  MemorySearchNotifier.new,
);
