// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Conversation _$ConversationFromJson(Map<String, dynamic> json) =>
    _Conversation(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      audioUrl: json['audioUrl'] as String?,
      toyId: json['toyId'] as String?,
      userId: json['userId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ConversationToJson(_Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'role': instance.role,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'audioUrl': instance.audioUrl,
      'toyId': instance.toyId,
      'userId': instance.userId,
      'metadata': instance.metadata,
    };

_MemoryEntry _$MemoryEntryFromJson(Map<String, dynamic> json) => _MemoryEntry(
  id: json['id'] as String,
  content: json['content'] as String,
  category: json['category'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  relevanceScore: (json['relevanceScore'] as num?)?.toDouble(),
  toyId: json['toyId'] as String?,
  userId: json['userId'] as String?,
  sessionId: json['sessionId'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$MemoryEntryToJson(_MemoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'category': instance.category,
      'createdAt': instance.createdAt.toIso8601String(),
      'relevanceScore': instance.relevanceScore,
      'toyId': instance.toyId,
      'userId': instance.userId,
      'sessionId': instance.sessionId,
      'metadata': instance.metadata,
    };

_ConversationInsight _$ConversationInsightFromJson(Map<String, dynamic> json) =>
    _ConversationInsight(
      id: json['id'] as String,
      type: json['type'] as String,
      summary: json['summary'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      toyId: json['toyId'] as String?,
      userId: json['userId'] as String?,
      topics: (json['topics'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      emotionAnalysis: json['emotionAnalysis'] as Map<String, dynamic>?,
      messageCount: (json['messageCount'] as num?)?.toInt(),
      sessionCount: (json['sessionCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ConversationInsightToJson(
  _ConversationInsight instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'summary': instance.summary,
  'createdAt': instance.createdAt.toIso8601String(),
  'toyId': instance.toyId,
  'userId': instance.userId,
  'topics': instance.topics,
  'emotionAnalysis': instance.emotionAnalysis,
  'messageCount': instance.messageCount,
  'sessionCount': instance.sessionCount,
};
