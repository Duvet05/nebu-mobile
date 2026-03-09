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
  sessionId: json['sessionId'] as String,
  summary: json['summary'] as String,
  relevance: (json['relevance'] as num?)?.toDouble(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$MemoryEntryToJson(_MemoryEntry instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'summary': instance.summary,
      'relevance': instance.relevance,
      'metadata': instance.metadata,
    };
