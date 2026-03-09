import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_session.freezed.dart';
part 'voice_session.g.dart';

@freezed
abstract class VoiceSession with _$VoiceSession {
  const factory VoiceSession({
    required String id,
    String? userId,
    String? toyId,
    String? roomName,
    required String status,
    @Default('es') String language,
    required DateTime startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    @Default(0) int messageCount,
    String? summary,
    @JsonKey(fromJson: _topicsFromJson) List<String>? topics,
    String? emotion,
    Map<String, dynamic>? metadata,
  }) = _VoiceSession;

  factory VoiceSession.fromJson(Map<String, dynamic> json) =>
      _$VoiceSessionFromJson(json);
}

/// Backend may return topics as JSON array or comma string.
List<String>? _topicsFromJson(dynamic value) {
  if (value == null) return null;
  if (value is List) return value.cast<String>();
  if (value is String) return value.split(',').map((e) => e.trim()).toList();
  return null;
}

@freezed
abstract class AiConversation with _$AiConversation {
  const factory AiConversation({
    required String id,
    required String sessionId,
    required String messageType,
    required String content,
    String? audioUrl,
    DateTime? createdAt,
  }) = _AiConversation;

  factory AiConversation.fromJson(Map<String, dynamic> json) =>
      _$AiConversationFromJson(json);
}

@freezed
abstract class VoiceMetrics with _$VoiceMetrics {
  const factory VoiceMetrics({
    @Default(0) int totalSessions,
    @Default(0) int activeSessions,
    @Default(0) int totalConversations,
    @Default(0) double averageSessionDuration,
    @Default(0) int totalTokensUsed,
    @Default(0) double totalCost,
  }) = _VoiceMetrics;

  factory VoiceMetrics.fromJson(Map<String, dynamic> json) =>
      _$VoiceMetricsFromJson(json);
}

@freezed
abstract class KnowledgeEntry with _$KnowledgeEntry {
  const factory KnowledgeEntry({
    required String id,
    required String content,
    double? relevance,
    @Default({}) Map<String, dynamic> metadata,
  }) = _KnowledgeEntry;

  factory KnowledgeEntry.fromJson(Map<String, dynamic> json) =>
      _$KnowledgeEntryFromJson(json);
}

extension KnowledgeEntryMetadata on KnowledgeEntry {
  String? get topic => metadata['topic'] as String?;
  String? get category => metadata['category'] as String?;
  String? get ageRange => metadata['ageRange'] as String?;
  bool get verified => (metadata['verified'] as bool?) ?? false;
  String? get source => metadata['source'] as String?;
  String? get language => metadata['language'] as String?;
}
