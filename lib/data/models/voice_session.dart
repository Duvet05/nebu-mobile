import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_session.freezed.dart';
part 'voice_session.g.dart';

@freezed
abstract class VoiceSession with _$VoiceSession {
  const factory VoiceSession({
    required String id,
    required String status,
    required DateTime startedAt,
    String? userId,
    String? toyId,
    String? roomName,
    @Default('es') String language,
    DateTime? endedAt,
    int? durationSeconds,
    @Default(0) int messageCount,
    String? summary,
    @JsonKey(fromJson: _topicsFromJson) List<String>? topics,
    String? emotion,
    Map<String, dynamic>? metadata,
    EngagementStats? engagementStats,
  }) = _VoiceSession;

  factory VoiceSession.fromJson(Map<String, dynamic> json) =>
      _$VoiceSessionFromJson(json);
}

/// Backend may return topics as JSON array or comma string.
List<String>? _topicsFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is List) {
    return value.cast<String>();
  }
  if (value is String) {
    return value.split(',').map((e) => e.trim()).toList();
  }
  return null;
}

@freezed
abstract class EngagementStats with _$EngagementStats {
  const factory EngagementStats({
    @Default(0) int turnCount,
    String? mood,
    String? rapport,
    @Default(0) int factsTold,
    @Default(0) int riddlesTold,
    String? favoriteCategory,
    @Default(0) double sessionMinutes,
    @Default(0) double cultureHype,
    String? profileId,
  }) = _EngagementStats;

  factory EngagementStats.fromJson(Map<String, dynamic> json) =>
      _$EngagementStatsFromJson(json);
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
abstract class UserLimits with _$UserLimits {
  const factory UserLimits({
    @Default(VoiceLimits()) VoiceLimits voice,
    @Default(SessionLimits()) SessionLimits session,
    @Default(PaymentLimits()) PaymentLimits payments,
  }) = _UserLimits;

  factory UserLimits.fromJson(Map<String, dynamic> json) =>
      _$UserLimitsFromJson(json);
}

@freezed
abstract class VoiceLimits with _$VoiceLimits {
  const factory VoiceLimits({
    @Default(0) double dailyMinutesUsed,
    @Default(60) double dailyMinutesLimit,
    @Default(0) double monthlyMinutesUsed,
    @Default(300) double monthlyMinutesLimit,
    @Default(15) int maxSessionMinutes,
    @Default(0) int toyCount,
  }) = _VoiceLimits;

  factory VoiceLimits.fromJson(Map<String, dynamic> json) =>
      _$VoiceLimitsFromJson(json);
}

@freezed
abstract class SessionLimits with _$SessionLimits {
  const factory SessionLimits({
    @Default(3) int maxConcurrentSessions,
    @Default('30m') String sessionTimeout,
  }) = _SessionLimits;

  factory SessionLimits.fromJson(Map<String, dynamic> json) =>
      _$SessionLimitsFromJson(json);
}

@freezed
abstract class PaymentLimits with _$PaymentLimits {
  const factory PaymentLimits({
    @Default(5) int minPurchaseAmount,
    @Default(10000) int maxPurchaseAmount,
    @Default('USD') String currency,
  }) = _PaymentLimits;

  factory PaymentLimits.fromJson(Map<String, dynamic> json) =>
      _$PaymentLimitsFromJson(json);
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
