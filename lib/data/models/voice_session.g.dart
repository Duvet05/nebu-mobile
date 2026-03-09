// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoiceSession _$VoiceSessionFromJson(Map<String, dynamic> json) =>
    _VoiceSession(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      toyId: json['toyId'] as String?,
      roomName: json['roomName'] as String?,
      status: json['status'] as String,
      language: json['language'] as String? ?? 'es',
      startedAt: DateTime.parse(json['startedAt'] as String),
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
      'userId': instance.userId,
      'toyId': instance.toyId,
      'roomName': instance.roomName,
      'status': instance.status,
      'language': instance.language,
      'startedAt': instance.startedAt.toIso8601String(),
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
