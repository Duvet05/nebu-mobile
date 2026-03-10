import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/voice_session.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

/// Voice session metrics (requires auth)
final voiceMetricsProvider = FutureProvider<VoiceMetrics>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) {
    return const VoiceMetrics();
  }
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
  if (user == null) {
    return [];
  }
  return service.getUserSessions(user.id);
});

/// User limits and usage stats (requires auth)
final userLimitsProvider = FutureProvider<UserLimits>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) {
    return const UserLimits();
  }
  final service = ref.watch(voiceSessionServiceProvider);
  return service.getUserLimits();
});

/// Conversations for a specific session (requires auth)
final sessionConversationsProvider =
    FutureProvider.family<List<AiConversation>, String>((ref, sessionId) async {
      final user = ref.watch(authProvider).value;
      if (user == null) {
        return [];
      }
      final service = ref.watch(voiceSessionServiceProvider);
      return service.getSessionConversations(sessionId);
    });
