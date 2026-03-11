import 'package:logger/logger.dart';

import '../../core/errors/app_exception.dart';
import '../models/voice_session.dart';
import 'api_service.dart';

class VoiceSessionService {
  VoiceSessionService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  /// Get sessions for the authenticated user.
  /// Backend: GET /voice/sessions/user/:userId
  Future<List<VoiceSession>> getUserSessions(String userId) async {
    _logger.d('Fetching sessions for user: $userId');
    final response = await _apiService.get<dynamic>(
      '/voice/sessions/user/$userId',
    );
    return _parseSessionList(response);
  }

  /// Get a specific session by ID (includes conversations).
  /// Backend: GET /voice/sessions/:id
  Future<VoiceSession> getSession(String sessionId) async {
    _logger.d('Fetching voice session: $sessionId');
    final response = await _apiService.get<Map<String, dynamic>>(
      '/voice/sessions/$sessionId',
    );
    return VoiceSession.fromJson(response);
  }

  /// Get conversations for a session.
  /// Backend: GET /voice/sessions/:id/conversations
  Future<List<AiConversation>> getSessionConversations(String sessionId) async {
    _logger.d('Fetching conversations for session: $sessionId');
    final response = await _apiService.get<dynamic>(
      '/voice/sessions/$sessionId/conversations',
    );
    if (response is List) {
      return response
          .cast<Map<String, dynamic>>()
          .map(AiConversation.fromJson)
          .toList();
    }
    _logger.e(
      'getSessionConversations: unexpected response shape: ${response.runtimeType}',
    );
    throw const ServerException(
      'Unexpected response format from conversations API',
      statusCode: 500,
    );
  }

  /// Get session metrics/statistics.
  /// Backend: GET /voice/sessions/metrics
  Future<VoiceMetrics> getMetrics() async {
    _logger.d('Fetching voice session metrics');
    final response = await _apiService.get<Map<String, dynamic>>(
      '/voice/sessions/metrics',
    );
    return VoiceMetrics.fromJson(response);
  }

  /// Get usage stats and limits for the current user.
  /// Backend: GET /users/me/limits
  Future<UserLimits> getUserLimits() async {
    _logger.d('Fetching user limits');
    final response = await _apiService.get<Map<String, dynamic>>(
      '/users/me/limits',
    );
    return UserLimits.fromJson(response);
  }

  /// Create a new voice session.
  /// Backend: POST /voice/sessions
  Future<VoiceSession> createSession({
    required String userId,
    required String sessionToken,
    required String roomName,
  }) async {
    _logger.d('Creating voice session for user: $userId');
    final response = await _apiService.post<Map<String, dynamic>>(
      '/voice/sessions',
      data: {
        'userId': userId,
        'sessionToken': sessionToken,
        'roomName': roomName,
      },
    );
    return VoiceSession.fromJson(response);
  }

  /// End a voice session.
  /// Backend: POST /voice/sessions/:id/end
  Future<VoiceSession> endSession(String sessionId, {String? reason}) async {
    _logger.d('Ending voice session: $sessionId');
    final response = await _apiService.post<Map<String, dynamic>>(
      '/voice/sessions/$sessionId/end',
      data: {'reason': ?reason},
    );
    return VoiceSession.fromJson(response);
  }

  List<VoiceSession> _parseSessionList(Object? response) {
    if (response is List) {
      return response
          .cast<Map<String, dynamic>>()
          .map(VoiceSession.fromJson)
          .toList();
    }
    if (response is Map<String, dynamic>) {
      final data = response['sessions'] ?? response['data'];
      if (data is List) {
        return data
            .cast<Map<String, dynamic>>()
            .map(VoiceSession.fromJson)
            .toList();
      }
    }
    _logger.e(
      '_parseSessionList: unexpected response shape: ${response.runtimeType}',
    );
    throw const ServerException(
      'Unexpected response format from sessions API',
      statusCode: 500,
    );
  }
}
