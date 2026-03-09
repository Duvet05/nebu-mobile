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

/// A conversation memory returned by the backend vector-memory endpoints.
/// Maps to: GET /vector-memory/memories/:toyId/recent
///           POST /vector-memory/memories/search
@freezed
abstract class MemoryEntry with _$MemoryEntry {
  const factory MemoryEntry({
    required String sessionId,
    required String summary,
    double? relevance,
    @Default({}) Map<String, dynamic> metadata,
  }) = _MemoryEntry;

  factory MemoryEntry.fromJson(Map<String, dynamic> json) =>
      _$MemoryEntryFromJson(json);
}

/// Helper extension to extract typed metadata fields from MemoryEntry.
extension MemoryEntryMetadata on MemoryEntry {
  String? get toyId => metadata['toyId'] as String?;
  String? get topics => metadata['topics'] as String?;
  String? get emotion => metadata['emotion'] as String?;
  int? get duration => metadata['duration'] as int?;
  int? get messageCount => metadata['messageCount'] as int?;
  String? get timestamp => metadata['timestamp'] as String?;
}
