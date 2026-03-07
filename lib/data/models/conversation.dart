import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String sessionId,
    required String role,
    required String content,
    required DateTime timestamp,
    String? audioUrl,
    String? toyId,
    String? userId,
    Map<String, dynamic>? metadata,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

@freezed
abstract class MemoryEntry with _$MemoryEntry {
  const factory MemoryEntry({
    required String id,
    required String content,
    required String category,
    required DateTime createdAt,
    double? relevanceScore,
    String? toyId,
    String? userId,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) = _MemoryEntry;

  factory MemoryEntry.fromJson(Map<String, dynamic> json) =>
      _$MemoryEntryFromJson(json);
}

@freezed
abstract class ConversationInsight with _$ConversationInsight {
  const factory ConversationInsight({
    required String id,
    required String type,
    required String summary,
    required DateTime createdAt,
    String? toyId,
    String? userId,
    List<String>? topics,
    Map<String, dynamic>? emotionAnalysis,
    int? messageCount,
    int? sessionCount,
  }) = _ConversationInsight;

  factory ConversationInsight.fromJson(Map<String, dynamic> json) =>
      _$ConversationInsightFromJson(json);
}
