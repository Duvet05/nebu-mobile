import 'package:logger/logger.dart';

import '../models/conversation.dart';
import 'api_service.dart';

class MemoryService {
  MemoryService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  // ─── Memory (Vector Store) ───

  /// Search memory for relevant context
  Future<List<MemoryEntry>> searchMemory({
    required String query,
    String? toyId,
    int limit = 10,
  }) async {
    _logger.d('Searching memory: "$query"');
    final response = await _apiService.get<dynamic>(
      '/agent/memory/search',
      queryParameters: {
        'query': query,
        'limit': '$limit',
        if (toyId != null) 'toyId': toyId,
      },
    );

    return _parseMemoryList(response);
  }

  /// Get all memories for a toy
  Future<List<MemoryEntry>> getToyMemories({
    required String toyId,
    int page = 1,
    int limit = 20,
  }) async {
    _logger.d('Fetching memories for toy: $toyId');
    final response = await _apiService.get<dynamic>(
      '/agent/memory',
      queryParameters: {
        'toyId': toyId,
        'page': '$page',
        'limit': '$limit',
      },
    );

    return _parseMemoryList(response);
  }

  /// Delete a specific memory
  Future<void> deleteMemory(String memoryId) async {
    _logger.d('Deleting memory: $memoryId');
    await _apiService.delete<dynamic>('/agent/memory/$memoryId');
  }

  // ─── Insights ───

  /// Get conversation insights for a toy
  Future<List<ConversationInsight>> getToyInsights({
    required String toyId,
  }) async {
    _logger.d('Fetching insights for toy: $toyId');
    final response = await _apiService.get<dynamic>(
      '/agent/insights',
      queryParameters: {'toyId': toyId},
    );

    if (response is List) {
      return response
          .cast<Map<String, dynamic>>()
          .map(ConversationInsight.fromJson)
          .toList();
    }
    if (response is Map<String, dynamic>) {
      final data = response['insights'] ?? response['data'];
      if (data is List) {
        return data
            .cast<Map<String, dynamic>>()
            .map(ConversationInsight.fromJson)
            .toList();
      }
    }
    return [];
  }

  /// Parses memory entries from various backend response shapes.
  List<MemoryEntry> _parseMemoryList(response) {
    if (response is List) {
      return response
          .cast<Map<String, dynamic>>()
          .map(MemoryEntry.fromJson)
          .toList();
    }
    if (response is Map<String, dynamic>) {
      final data =
          response['results'] ?? response['memories'] ?? response['data'];
      if (data is List) {
        return data
            .cast<Map<String, dynamic>>()
            .map(MemoryEntry.fromJson)
            .toList();
      }
    }
    return [];
  }
}
