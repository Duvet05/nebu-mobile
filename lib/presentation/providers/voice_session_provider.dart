import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/voice_session.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

/// Voice session metrics
final voiceMetricsProvider = FutureProvider<VoiceMetrics>((ref) async {
  final service = ref.watch(voiceSessionServiceProvider);
  return service.getMetrics();
});

/// Voice sessions for the current user
final userVoiceSessionsProvider = FutureProvider<List<VoiceSession>>((
  ref,
) async {
  final service = ref.watch(voiceSessionServiceProvider);
  final authState = ref.watch(authProvider);
  final user = authState.value;
  if (user == null) return [];
  return service.getUserSessions(user.id);
});

/// Conversations for a specific session
final sessionConversationsProvider =
    FutureProvider.family<List<AiConversation>, String>((ref, sessionId) async {
      final service = ref.watch(voiceSessionServiceProvider);
      return service.getSessionConversations(sessionId);
    });
