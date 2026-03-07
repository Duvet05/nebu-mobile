// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Conversation {

 String get id; String get sessionId; String get role; String get content; DateTime get timestamp; String? get audioUrl; String? get toyId; String? get userId; Map<String, dynamic>? get metadata;
/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationCopyWith<Conversation> get copyWith => _$ConversationCopyWithImpl<Conversation>(this as Conversation, _$identity);

  /// Serializes this Conversation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Conversation&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.toyId, toyId) || other.toyId == toyId)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,role,content,timestamp,audioUrl,toyId,userId,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'Conversation(id: $id, sessionId: $sessionId, role: $role, content: $content, timestamp: $timestamp, audioUrl: $audioUrl, toyId: $toyId, userId: $userId, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $ConversationCopyWith<$Res>  {
  factory $ConversationCopyWith(Conversation value, $Res Function(Conversation) _then) = _$ConversationCopyWithImpl;
@useResult
$Res call({
 String id, String sessionId, String role, String content, DateTime timestamp, String? audioUrl, String? toyId, String? userId, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$ConversationCopyWithImpl<$Res>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._self, this._then);

  final Conversation _self;
  final $Res Function(Conversation) _then;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = null,Object? role = null,Object? content = null,Object? timestamp = null,Object? audioUrl = freezed,Object? toyId = freezed,Object? userId = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,toyId: freezed == toyId ? _self.toyId : toyId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Conversation].
extension ConversationPatterns on Conversation {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Conversation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Conversation() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Conversation value)  $default,){
final _that = this;
switch (_that) {
case _Conversation():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Conversation value)?  $default,){
final _that = this;
switch (_that) {
case _Conversation() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sessionId,  String role,  String content,  DateTime timestamp,  String? audioUrl,  String? toyId,  String? userId,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Conversation() when $default != null:
return $default(_that.id,_that.sessionId,_that.role,_that.content,_that.timestamp,_that.audioUrl,_that.toyId,_that.userId,_that.metadata);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sessionId,  String role,  String content,  DateTime timestamp,  String? audioUrl,  String? toyId,  String? userId,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _Conversation():
return $default(_that.id,_that.sessionId,_that.role,_that.content,_that.timestamp,_that.audioUrl,_that.toyId,_that.userId,_that.metadata);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sessionId,  String role,  String content,  DateTime timestamp,  String? audioUrl,  String? toyId,  String? userId,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _Conversation() when $default != null:
return $default(_that.id,_that.sessionId,_that.role,_that.content,_that.timestamp,_that.audioUrl,_that.toyId,_that.userId,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Conversation implements Conversation {
  const _Conversation({required this.id, required this.sessionId, required this.role, required this.content, required this.timestamp, this.audioUrl, this.toyId, this.userId, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);

@override final  String id;
@override final  String sessionId;
@override final  String role;
@override final  String content;
@override final  DateTime timestamp;
@override final  String? audioUrl;
@override final  String? toyId;
@override final  String? userId;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationCopyWith<_Conversation> get copyWith => __$ConversationCopyWithImpl<_Conversation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Conversation&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.toyId, toyId) || other.toyId == toyId)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,role,content,timestamp,audioUrl,toyId,userId,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'Conversation(id: $id, sessionId: $sessionId, role: $role, content: $content, timestamp: $timestamp, audioUrl: $audioUrl, toyId: $toyId, userId: $userId, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ConversationCopyWith<$Res> implements $ConversationCopyWith<$Res> {
  factory _$ConversationCopyWith(_Conversation value, $Res Function(_Conversation) _then) = __$ConversationCopyWithImpl;
@override @useResult
$Res call({
 String id, String sessionId, String role, String content, DateTime timestamp, String? audioUrl, String? toyId, String? userId, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$ConversationCopyWithImpl<$Res>
    implements _$ConversationCopyWith<$Res> {
  __$ConversationCopyWithImpl(this._self, this._then);

  final _Conversation _self;
  final $Res Function(_Conversation) _then;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? role = null,Object? content = null,Object? timestamp = null,Object? audioUrl = freezed,Object? toyId = freezed,Object? userId = freezed,Object? metadata = freezed,}) {
  return _then(_Conversation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,toyId: freezed == toyId ? _self.toyId : toyId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$MemoryEntry {

 String get id; String get content; String get category; DateTime get createdAt; double? get relevanceScore; String? get toyId; String? get userId; String? get sessionId; Map<String, dynamic>? get metadata;
/// Create a copy of MemoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemoryEntryCopyWith<MemoryEntry> get copyWith => _$MemoryEntryCopyWithImpl<MemoryEntry>(this as MemoryEntry, _$identity);

  /// Serializes this MemoryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemoryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.category, category) || other.category == category)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.relevanceScore, relevanceScore) || other.relevanceScore == relevanceScore)&&(identical(other.toyId, toyId) || other.toyId == toyId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,category,createdAt,relevanceScore,toyId,userId,sessionId,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'MemoryEntry(id: $id, content: $content, category: $category, createdAt: $createdAt, relevanceScore: $relevanceScore, toyId: $toyId, userId: $userId, sessionId: $sessionId, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $MemoryEntryCopyWith<$Res>  {
  factory $MemoryEntryCopyWith(MemoryEntry value, $Res Function(MemoryEntry) _then) = _$MemoryEntryCopyWithImpl;
@useResult
$Res call({
 String id, String content, String category, DateTime createdAt, double? relevanceScore, String? toyId, String? userId, String? sessionId, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$MemoryEntryCopyWithImpl<$Res>
    implements $MemoryEntryCopyWith<$Res> {
  _$MemoryEntryCopyWithImpl(this._self, this._then);

  final MemoryEntry _self;
  final $Res Function(MemoryEntry) _then;

/// Create a copy of MemoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? category = null,Object? createdAt = null,Object? relevanceScore = freezed,Object? toyId = freezed,Object? userId = freezed,Object? sessionId = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,relevanceScore: freezed == relevanceScore ? _self.relevanceScore : relevanceScore // ignore: cast_nullable_to_non_nullable
as double?,toyId: freezed == toyId ? _self.toyId : toyId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [MemoryEntry].
extension MemoryEntryPatterns on MemoryEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemoryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemoryEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemoryEntry value)  $default,){
final _that = this;
switch (_that) {
case _MemoryEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemoryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MemoryEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String content,  String category,  DateTime createdAt,  double? relevanceScore,  String? toyId,  String? userId,  String? sessionId,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemoryEntry() when $default != null:
return $default(_that.id,_that.content,_that.category,_that.createdAt,_that.relevanceScore,_that.toyId,_that.userId,_that.sessionId,_that.metadata);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String content,  String category,  DateTime createdAt,  double? relevanceScore,  String? toyId,  String? userId,  String? sessionId,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _MemoryEntry():
return $default(_that.id,_that.content,_that.category,_that.createdAt,_that.relevanceScore,_that.toyId,_that.userId,_that.sessionId,_that.metadata);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String content,  String category,  DateTime createdAt,  double? relevanceScore,  String? toyId,  String? userId,  String? sessionId,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _MemoryEntry() when $default != null:
return $default(_that.id,_that.content,_that.category,_that.createdAt,_that.relevanceScore,_that.toyId,_that.userId,_that.sessionId,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemoryEntry implements MemoryEntry {
  const _MemoryEntry({required this.id, required this.content, required this.category, required this.createdAt, this.relevanceScore, this.toyId, this.userId, this.sessionId, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _MemoryEntry.fromJson(Map<String, dynamic> json) => _$MemoryEntryFromJson(json);

@override final  String id;
@override final  String content;
@override final  String category;
@override final  DateTime createdAt;
@override final  double? relevanceScore;
@override final  String? toyId;
@override final  String? userId;
@override final  String? sessionId;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of MemoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemoryEntryCopyWith<_MemoryEntry> get copyWith => __$MemoryEntryCopyWithImpl<_MemoryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemoryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemoryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.category, category) || other.category == category)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.relevanceScore, relevanceScore) || other.relevanceScore == relevanceScore)&&(identical(other.toyId, toyId) || other.toyId == toyId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,category,createdAt,relevanceScore,toyId,userId,sessionId,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'MemoryEntry(id: $id, content: $content, category: $category, createdAt: $createdAt, relevanceScore: $relevanceScore, toyId: $toyId, userId: $userId, sessionId: $sessionId, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$MemoryEntryCopyWith<$Res> implements $MemoryEntryCopyWith<$Res> {
  factory _$MemoryEntryCopyWith(_MemoryEntry value, $Res Function(_MemoryEntry) _then) = __$MemoryEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String content, String category, DateTime createdAt, double? relevanceScore, String? toyId, String? userId, String? sessionId, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$MemoryEntryCopyWithImpl<$Res>
    implements _$MemoryEntryCopyWith<$Res> {
  __$MemoryEntryCopyWithImpl(this._self, this._then);

  final _MemoryEntry _self;
  final $Res Function(_MemoryEntry) _then;

/// Create a copy of MemoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? category = null,Object? createdAt = null,Object? relevanceScore = freezed,Object? toyId = freezed,Object? userId = freezed,Object? sessionId = freezed,Object? metadata = freezed,}) {
  return _then(_MemoryEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,relevanceScore: freezed == relevanceScore ? _self.relevanceScore : relevanceScore // ignore: cast_nullable_to_non_nullable
as double?,toyId: freezed == toyId ? _self.toyId : toyId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$ConversationInsight {

 String get id; String get type; String get summary; DateTime get createdAt; String? get toyId; String? get userId; List<String>? get topics; Map<String, dynamic>? get emotionAnalysis; int? get messageCount; int? get sessionCount;
/// Create a copy of ConversationInsight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationInsightCopyWith<ConversationInsight> get copyWith => _$ConversationInsightCopyWithImpl<ConversationInsight>(this as ConversationInsight, _$identity);

  /// Serializes this ConversationInsight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationInsight&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.toyId, toyId) || other.toyId == toyId)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.topics, topics)&&const DeepCollectionEquality().equals(other.emotionAnalysis, emotionAnalysis)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,summary,createdAt,toyId,userId,const DeepCollectionEquality().hash(topics),const DeepCollectionEquality().hash(emotionAnalysis),messageCount,sessionCount);

@override
String toString() {
  return 'ConversationInsight(id: $id, type: $type, summary: $summary, createdAt: $createdAt, toyId: $toyId, userId: $userId, topics: $topics, emotionAnalysis: $emotionAnalysis, messageCount: $messageCount, sessionCount: $sessionCount)';
}


}

/// @nodoc
abstract mixin class $ConversationInsightCopyWith<$Res>  {
  factory $ConversationInsightCopyWith(ConversationInsight value, $Res Function(ConversationInsight) _then) = _$ConversationInsightCopyWithImpl;
@useResult
$Res call({
 String id, String type, String summary, DateTime createdAt, String? toyId, String? userId, List<String>? topics, Map<String, dynamic>? emotionAnalysis, int? messageCount, int? sessionCount
});




}
/// @nodoc
class _$ConversationInsightCopyWithImpl<$Res>
    implements $ConversationInsightCopyWith<$Res> {
  _$ConversationInsightCopyWithImpl(this._self, this._then);

  final ConversationInsight _self;
  final $Res Function(ConversationInsight) _then;

/// Create a copy of ConversationInsight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? summary = null,Object? createdAt = null,Object? toyId = freezed,Object? userId = freezed,Object? topics = freezed,Object? emotionAnalysis = freezed,Object? messageCount = freezed,Object? sessionCount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,toyId: freezed == toyId ? _self.toyId : toyId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,topics: freezed == topics ? _self.topics : topics // ignore: cast_nullable_to_non_nullable
as List<String>?,emotionAnalysis: freezed == emotionAnalysis ? _self.emotionAnalysis : emotionAnalysis // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,messageCount: freezed == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int?,sessionCount: freezed == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConversationInsight].
extension ConversationInsightPatterns on ConversationInsight {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationInsight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationInsight() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationInsight value)  $default,){
final _that = this;
switch (_that) {
case _ConversationInsight():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationInsight value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationInsight() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String summary,  DateTime createdAt,  String? toyId,  String? userId,  List<String>? topics,  Map<String, dynamic>? emotionAnalysis,  int? messageCount,  int? sessionCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationInsight() when $default != null:
return $default(_that.id,_that.type,_that.summary,_that.createdAt,_that.toyId,_that.userId,_that.topics,_that.emotionAnalysis,_that.messageCount,_that.sessionCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String summary,  DateTime createdAt,  String? toyId,  String? userId,  List<String>? topics,  Map<String, dynamic>? emotionAnalysis,  int? messageCount,  int? sessionCount)  $default,) {final _that = this;
switch (_that) {
case _ConversationInsight():
return $default(_that.id,_that.type,_that.summary,_that.createdAt,_that.toyId,_that.userId,_that.topics,_that.emotionAnalysis,_that.messageCount,_that.sessionCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String summary,  DateTime createdAt,  String? toyId,  String? userId,  List<String>? topics,  Map<String, dynamic>? emotionAnalysis,  int? messageCount,  int? sessionCount)?  $default,) {final _that = this;
switch (_that) {
case _ConversationInsight() when $default != null:
return $default(_that.id,_that.type,_that.summary,_that.createdAt,_that.toyId,_that.userId,_that.topics,_that.emotionAnalysis,_that.messageCount,_that.sessionCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConversationInsight implements ConversationInsight {
  const _ConversationInsight({required this.id, required this.type, required this.summary, required this.createdAt, this.toyId, this.userId, final  List<String>? topics, final  Map<String, dynamic>? emotionAnalysis, this.messageCount, this.sessionCount}): _topics = topics,_emotionAnalysis = emotionAnalysis;
  factory _ConversationInsight.fromJson(Map<String, dynamic> json) => _$ConversationInsightFromJson(json);

@override final  String id;
@override final  String type;
@override final  String summary;
@override final  DateTime createdAt;
@override final  String? toyId;
@override final  String? userId;
 final  List<String>? _topics;
@override List<String>? get topics {
  final value = _topics;
  if (value == null) return null;
  if (_topics is EqualUnmodifiableListView) return _topics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _emotionAnalysis;
@override Map<String, dynamic>? get emotionAnalysis {
  final value = _emotionAnalysis;
  if (value == null) return null;
  if (_emotionAnalysis is EqualUnmodifiableMapView) return _emotionAnalysis;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  int? messageCount;
@override final  int? sessionCount;

/// Create a copy of ConversationInsight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationInsightCopyWith<_ConversationInsight> get copyWith => __$ConversationInsightCopyWithImpl<_ConversationInsight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationInsightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationInsight&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.toyId, toyId) || other.toyId == toyId)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other._topics, _topics)&&const DeepCollectionEquality().equals(other._emotionAnalysis, _emotionAnalysis)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,summary,createdAt,toyId,userId,const DeepCollectionEquality().hash(_topics),const DeepCollectionEquality().hash(_emotionAnalysis),messageCount,sessionCount);

@override
String toString() {
  return 'ConversationInsight(id: $id, type: $type, summary: $summary, createdAt: $createdAt, toyId: $toyId, userId: $userId, topics: $topics, emotionAnalysis: $emotionAnalysis, messageCount: $messageCount, sessionCount: $sessionCount)';
}


}

/// @nodoc
abstract mixin class _$ConversationInsightCopyWith<$Res> implements $ConversationInsightCopyWith<$Res> {
  factory _$ConversationInsightCopyWith(_ConversationInsight value, $Res Function(_ConversationInsight) _then) = __$ConversationInsightCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String summary, DateTime createdAt, String? toyId, String? userId, List<String>? topics, Map<String, dynamic>? emotionAnalysis, int? messageCount, int? sessionCount
});




}
/// @nodoc
class __$ConversationInsightCopyWithImpl<$Res>
    implements _$ConversationInsightCopyWith<$Res> {
  __$ConversationInsightCopyWithImpl(this._self, this._then);

  final _ConversationInsight _self;
  final $Res Function(_ConversationInsight) _then;

/// Create a copy of ConversationInsight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? summary = null,Object? createdAt = null,Object? toyId = freezed,Object? userId = freezed,Object? topics = freezed,Object? emotionAnalysis = freezed,Object? messageCount = freezed,Object? sessionCount = freezed,}) {
  return _then(_ConversationInsight(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,toyId: freezed == toyId ? _self.toyId : toyId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,topics: freezed == topics ? _self._topics : topics // ignore: cast_nullable_to_non_nullable
as List<String>?,emotionAnalysis: freezed == emotionAnalysis ? _self._emotionAnalysis : emotionAnalysis // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,messageCount: freezed == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int?,sessionCount: freezed == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
