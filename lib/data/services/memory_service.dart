import 'package:logger/logger.dart';

import '../models/conversation.dart';
import 'api_service.dart';

class MemoryService {
  MemoryService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  // ─── Recent Memories ───

  /// Get recent conversation memories for a toy.
  /// Backend: GET /vector-memory/memories/:toyId/recent?limit=N
  Future<List<MemoryEntry>> getRecentMemories({
    required String toyId,
    int limit = 20,
  }) async {
    _logger.d('Fetching recent memories for toy: $toyId');
    final response = await _apiService.get<dynamic>(
      '/vector-memory/memories/$toyId/recent',
      queryParameters: {'limit': '$limit'},
    );

    return _parseMemoryList(response);
  }

  // ─── Semantic Search ───

  /// Search conversation memories using vector similarity.
  /// Backend: POST /vector-memory/memories/search
  Future<List<MemoryEntry>> searchMemories({
    required String toyId,
    required String query,
    int limit = 5,
    int daysBack = 30,
  }) async {
    _logger.d('Searching memories: "$query" for toy: $toyId');
    final response = await _apiService.post<dynamic>(
      '/vector-memory/memories/search',
      data: {
        'toyId': toyId,
        'query': query,
        'limit': limit,
        'daysBack': daysBack,
      },
    );

    return _parseMemoryList(response);
  }

  // ─── Parsing ───

  List<MemoryEntry> _parseMemoryList(Object? response) {
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
