import 'package:logger/logger.dart';

import 'api_service.dart';

class VoiceSessionService {
  VoiceSessionService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  /// Create a new voice session
  Future<Map<String, dynamic>> createSession({
    required String userId,
    String? sessionToken,
    String? roomName,
    String language = 'es',
    Map<String, dynamic>? metadata,
  }) async {
    _logger.d('Creating voice session for user: $userId');
    final response = await _apiService.post<Map<String, dynamic>>(
      '/voice/sessions',
      data: {
        'userId': userId,
        if (sessionToken != null) 'sessionToken': sessionToken,
        if (roomName != null) 'roomName': roomName,
        'language': language,
        if (metadata != null) 'metadata': metadata,
      },
    );
    _logger.d('Voice session created: ${response['id']}');
    return response;
  }

  /// Get voice sessions with optional filters
  Future<List<Map<String, dynamic>>> getSessions({
    String? userId,
    String? status,
    String? language,
  }) async {
    _logger.d('Fetching voice sessions');
    final response = await _apiService.get<dynamic>(
      '/voice/sessions',
      queryParameters: {
        if (userId != null) 'userId': userId,
        if (status != null) 'status': status,
        if (language != null) 'language': language,
      },
    );
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Get a specific session by ID (includes conversations)
  Future<Map<String, dynamic>> getSession(String sessionId) async {
    _logger.d('Fetching voice session: $sessionId');
    return _apiService
        .get<Map<String, dynamic>>('/voice/sessions/$sessionId');
  }

  /// Get sessions for a specific user
  Future<List<Map<String, dynamic>>> getUserSessions(String userId) async {
    _logger.d('Fetching sessions for user: $userId');
    final response = await _apiService
        .get<dynamic>('/voice/sessions/user/$userId');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Get active voice sessions
  Future<List<Map<String, dynamic>>> getActiveSessions() async {
    _logger.d('Fetching active voice sessions');
    final response = await _apiService
        .get<dynamic>('/voice/sessions/active');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// End a voice session
  Future<Map<String, dynamic>> endSession(
    String sessionId, {
    String? reason,
  }) async {
    _logger.d('Ending voice session: $sessionId');
    return _apiService.post<Map<String, dynamic>>(
      '/voice/sessions/$sessionId/end',
      data: {if (reason != null) 'reason': reason},
    );
  }

  /// Get conversations for a session
  Future<List<Map<String, dynamic>>> getSessionConversations(
    String sessionId,
  ) async {
    _logger.d('Fetching conversations for session: $sessionId');
    final response = await _apiService
        .get<dynamic>('/voice/sessions/$sessionId/conversations');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Get session metrics/statistics
  Future<Map<String, dynamic>> getSessionMetrics() async {
    _logger.d('Fetching voice session metrics');
    return _apiService
        .get<Map<String, dynamic>>('/voice/sessions/metrics');
  }
}
