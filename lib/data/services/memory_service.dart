import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../models/conversation.dart';
import 'api_service.dart';

class MemoryService {
  MemoryService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  // ─── Conversations ───

  /// Get conversations for a specific voice session
  Future<List<Conversation>> getSessionConversations(String sessionId) async {
    try {
      _logger.d('Fetching conversations for session: $sessionId');
      final response = await _apiService.get<dynamic>(
        '/voice/sessions/$sessionId/conversations',
      );

      if (response is List) {
        return response
            .cast<Map<String, dynamic>>()
            .map(Conversation.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching conversations: ${e.message}');
      return [];
    }
  }

  /// Get all conversations for a toy (across sessions)
  Future<List<Conversation>> getToyConversations({
    required String toyId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      _logger.d('Fetching conversations for toy: $toyId');
      final response = await _apiService.get<dynamic>(
        '/voice/sessions',
        queryParameters: {'toyId': toyId, 'page': '$page', 'limit': '$limit'},
      );

      // Backend returns sessions, we need to aggregate conversations
      if (response is List) {
        final conversations = <Conversation>[];
        for (final session in response.cast<Map<String, dynamic>>()) {
          final sessionId = session['id'] as String?;
          if (sessionId != null) {
            final sessionConvos = await getSessionConversations(sessionId);
            conversations.addAll(sessionConvos);
          }
        }
        return conversations;
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching toy conversations: ${e.message}');
      return [];
    }
  }

  // ─── Memory (Vector Store) ───

  /// Search memory for relevant context
  Future<List<MemoryEntry>> searchMemory({
    required String query,
    String? toyId,
    int limit = 10,
  }) async {
    try {
      _logger.d('Searching memory: "$query"');
      final response = await _apiService.get<dynamic>(
        '/agent/memory/search',
        queryParameters: {
          'query': query,
          'limit': '$limit',
          if (toyId != null) 'toyId': toyId,
        },
      );

      if (response is List) {
        return response
            .cast<Map<String, dynamic>>()
            .map(MemoryEntry.fromJson)
            .toList();
      }
      if (response is Map<String, dynamic>) {
        final data = response['results'] ?? response['memories'] ?? response['data'];
        if (data is List) {
          return data
              .cast<Map<String, dynamic>>()
              .map(MemoryEntry.fromJson)
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error searching memory: ${e.message}');
      return [];
    }
  }

  /// Get all memories for a toy
  Future<List<MemoryEntry>> getToyMemories({
    required String toyId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _logger.d('Fetching memories for toy: $toyId');
      final response = await _apiService.get<dynamic>(
        '/agent/memory',
        queryParameters: {
          'toyId': toyId,
          'page': '$page',
          'limit': '$limit',
        },
      );

      if (response is List) {
        return response
            .cast<Map<String, dynamic>>()
            .map(MemoryEntry.fromJson)
            .toList();
      }
      if (response is Map<String, dynamic>) {
        final data = response['memories'] ?? response['data'];
        if (data is List) {
          return data
              .cast<Map<String, dynamic>>()
              .map(MemoryEntry.fromJson)
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching memories: ${e.message}');
      return [];
    }
  }

  /// Delete a specific memory
  Future<bool> deleteMemory(String memoryId) async {
    try {
      _logger.d('Deleting memory: $memoryId');
      await _apiService.delete<dynamic>('/agent/memory/$memoryId');
      return true;
    } on DioException catch (e) {
      _logger.e('Error deleting memory: ${e.message}');
      return false;
    }
  }

  // ─── Insights ───

  /// Get conversation insights for a toy
  Future<List<ConversationInsight>> getToyInsights({
    required String toyId,
  }) async {
    try {
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
    } on DioException catch (e) {
      _logger.e('Error fetching insights: ${e.message}');
      return [];
    }
  }

  /// Get voice session metrics
  Future<Map<String, dynamic>?> getSessionMetrics() async {
    try {
      _logger.d('Fetching session metrics');
      return await _apiService
          .get<Map<String, dynamic>>('/voice/sessions/metrics');
    } on DioException catch (e) {
      _logger.e('Error fetching metrics: ${e.message}');
      return null;
    }
  }
}
