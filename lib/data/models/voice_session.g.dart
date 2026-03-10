// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoiceSession _$VoiceSessionFromJson(Map<String, dynamic> json) =>
    _VoiceSession(
      id: json['id'] as String,
      status: json['status'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      userId: json['userId'] as String?,
      toyId: json['toyId'] as String?,
      roomName: json['roomName'] as String?,
      language: json['language'] as String? ?? 'es',
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
      summary: json['summary'] as String?,
      topics: _topicsFromJson(json['topics']),
      emotion: json['emotion'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$VoiceSessionToJson(_VoiceSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'startedAt': instance.startedAt.toIso8601String(),
      'userId': instance.userId,
      'toyId': instance.toyId,
      'roomName': instance.roomName,
      'language': instance.language,
      'endedAt': instance.endedAt?.toIso8601String(),
      'durationSeconds': instance.durationSeconds,
      'messageCount': instance.messageCount,
      'summary': instance.summary,
      'topics': instance.topics,
      'emotion': instance.emotion,
      'metadata': instance.metadata,
    };

_AiConversation _$AiConversationFromJson(Map<String, dynamic> json) =>
    _AiConversation(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      messageType: json['messageType'] as String,
      content: json['content'] as String,
      audioUrl: json['audioUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AiConversationToJson(_AiConversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'messageType': instance.messageType,
      'content': instance.content,
      'audioUrl': instance.audioUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_VoiceMetrics _$VoiceMetricsFromJson(Map<String, dynamic> json) =>
    _VoiceMetrics(
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      activeSessions: (json['activeSessions'] as num?)?.toInt() ?? 0,
      totalConversations: (json['totalConversations'] as num?)?.toInt() ?? 0,
      averageSessionDuration:
          (json['averageSessionDuration'] as num?)?.toDouble() ?? 0,
      totalTokensUsed: (json['totalTokensUsed'] as num?)?.toInt() ?? 0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$VoiceMetricsToJson(_VoiceMetrics instance) =>
    <String, dynamic>{
      'totalSessions': instance.totalSessions,
      'activeSessions': instance.activeSessions,
      'totalConversations': instance.totalConversations,
      'averageSessionDuration': instance.averageSessionDuration,
      'totalTokensUsed': instance.totalTokensUsed,
      'totalCost': instance.totalCost,
    };

_UserLimits _$UserLimitsFromJson(Map<String, dynamic> json) => _UserLimits(
  voice: json['voice'] == null
      ? const VoiceLimits()
      : VoiceLimits.fromJson(json['voice'] as Map<String, dynamic>),
  session: json['session'] == null
      ? const SessionLimits()
      : SessionLimits.fromJson(json['session'] as Map<String, dynamic>),
  payments: json['payments'] == null
      ? const PaymentLimits()
      : PaymentLimits.fromJson(json['payments'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserLimitsToJson(_UserLimits instance) =>
    <String, dynamic>{
      'voice': instance.voice,
      'session': instance.session,
      'payments': instance.payments,
    };

_VoiceLimits _$VoiceLimitsFromJson(Map<String, dynamic> json) => _VoiceLimits(
  dailyMinutesUsed: (json['dailyMinutesUsed'] as num?)?.toDouble() ?? 0,
  dailyMinutesLimit: (json['dailyMinutesLimit'] as num?)?.toDouble() ?? 60,
  monthlyMinutesUsed: (json['monthlyMinutesUsed'] as num?)?.toDouble() ?? 0,
  monthlyMinutesLimit: (json['monthlyMinutesLimit'] as num?)?.toDouble() ?? 300,
  maxSessionMinutes: (json['maxSessionMinutes'] as num?)?.toInt() ?? 15,
  toyCount: (json['toyCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$VoiceLimitsToJson(_VoiceLimits instance) =>
    <String, dynamic>{
      'dailyMinutesUsed': instance.dailyMinutesUsed,
      'dailyMinutesLimit': instance.dailyMinutesLimit,
      'monthlyMinutesUsed': instance.monthlyMinutesUsed,
      'monthlyMinutesLimit': instance.monthlyMinutesLimit,
      'maxSessionMinutes': instance.maxSessionMinutes,
      'toyCount': instance.toyCount,
    };

_SessionLimits _$SessionLimitsFromJson(Map<String, dynamic> json) =>
    _SessionLimits(
      maxConcurrentSessions:
          (json['maxConcurrentSessions'] as num?)?.toInt() ?? 3,
      sessionTimeout: json['sessionTimeout'] as String? ?? '30m',
    );

Map<String, dynamic> _$SessionLimitsToJson(_SessionLimits instance) =>
    <String, dynamic>{
      'maxConcurrentSessions': instance.maxConcurrentSessions,
      'sessionTimeout': instance.sessionTimeout,
    };

_PaymentLimits _$PaymentLimitsFromJson(Map<String, dynamic> json) =>
    _PaymentLimits(
      minPurchaseAmount: (json['minPurchaseAmount'] as num?)?.toInt() ?? 5,
      maxPurchaseAmount: (json['maxPurchaseAmount'] as num?)?.toInt() ?? 10000,
      currency: json['currency'] as String? ?? 'USD',
    );

Map<String, dynamic> _$PaymentLimitsToJson(_PaymentLimits instance) =>
    <String, dynamic>{
      'minPurchaseAmount': instance.minPurchaseAmount,
      'maxPurchaseAmount': instance.maxPurchaseAmount,
      'currency': instance.currency,
    };

_KnowledgeEntry _$KnowledgeEntryFromJson(Map<String, dynamic> json) =>
    _KnowledgeEntry(
      id: json['id'] as String,
      content: json['content'] as String,
      relevance: (json['relevance'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$KnowledgeEntryToJson(_KnowledgeEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'relevance': instance.relevance,
      'metadata': instance.metadata,
    };
