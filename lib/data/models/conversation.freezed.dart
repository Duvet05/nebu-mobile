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

 String get sessionId; String get summary; double? get relevance; Map<String, dynamic> get metadata;
/// Create a copy of MemoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemoryEntryCopyWith<MemoryEntry> get copyWith => _$MemoryEntryCopyWithImpl<MemoryEntry>(this as MemoryEntry, _$identity);

  /// Serializes this MemoryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemoryEntry&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.relevance, relevance) || other.relevance == relevance)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,summary,relevance,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'MemoryEntry(sessionId: $sessionId, summary: $summary, relevance: $relevance, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $MemoryEntryCopyWith<$Res>  {
  factory $MemoryEntryCopyWith(MemoryEntry value, $Res Function(MemoryEntry) _then) = _$MemoryEntryCopyWithImpl;
@useResult
$Res call({
 String sessionId, String summary, double? relevance, Map<String, dynamic> metadata
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
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? summary = null,Object? relevance = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,relevance: freezed == relevance ? _self.relevance : relevance // ignore: cast_nullable_to_non_nullable
as double?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sessionId,  String summary,  double? relevance,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemoryEntry() when $default != null:
return $default(_that.sessionId,_that.summary,_that.relevance,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sessionId,  String summary,  double? relevance,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _MemoryEntry():
return $default(_that.sessionId,_that.summary,_that.relevance,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sessionId,  String summary,  double? relevance,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _MemoryEntry() when $default != null:
return $default(_that.sessionId,_that.summary,_that.relevance,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemoryEntry implements MemoryEntry {
  const _MemoryEntry({required this.sessionId, required this.summary, this.relevance, final  Map<String, dynamic> metadata = const {}}): _metadata = metadata;
  factory _MemoryEntry.fromJson(Map<String, dynamic> json) => _$MemoryEntryFromJson(json);

@override final  String sessionId;
@override final  String summary;
@override final  double? relevance;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemoryEntry&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.relevance, relevance) || other.relevance == relevance)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,summary,relevance,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'MemoryEntry(sessionId: $sessionId, summary: $summary, relevance: $relevance, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$MemoryEntryCopyWith<$Res> implements $MemoryEntryCopyWith<$Res> {
  factory _$MemoryEntryCopyWith(_MemoryEntry value, $Res Function(_MemoryEntry) _then) = __$MemoryEntryCopyWithImpl;
@override @useResult
$Res call({
 String sessionId, String summary, double? relevance, Map<String, dynamic> metadata
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
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? summary = null,Object? relevance = freezed,Object? metadata = null,}) {
  return _then(_MemoryEntry(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,relevance: freezed == relevance ? _self.relevance : relevance // ignore: cast_nullable_to_non_nullable
as double?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
