// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoiceSession {

 String get id; String get status; DateTime get startedAt; String? get userId; String? get toyId; String? get roomName; String get language; DateTime? get endedAt; int? get durationSeconds; int get messageCount; String? get summary;@JsonKey(fromJson: _topicsFromJson) List<String>? get topics; String? get emotion; Map<String, dynamic>? get metadata; EngagementStats? get engagementStats;
/// Create a copy of VoiceSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceSessionCopyWith<VoiceSession> get copyWith => _$VoiceSessionCopyWithImpl<VoiceSession>(this as VoiceSession, _$identity);

  /// Serializes this VoiceSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceSession&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.toyId, toyId) || other.toyId == toyId)&&(identical(other.roomName, roomName) || other.roomName == roomName)&&(identical(other.language, language) || other.language == language)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.topics, topics)&&(identical(other.emotion, emotion) || other.emotion == emotion)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.engagementStats, engagementStats) || other.engagementStats == engagementStats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,startedAt,userId,toyId,roomName,language,endedAt,durationSeconds,messageCount,summary,const DeepCollectionEquality().hash(topics),emotion,const DeepCollectionEquality().hash(metadata),engagementStats);

@override
String toString() {
  return 'VoiceSession(id: $id, status: $status, startedAt: $startedAt, userId: $userId, toyId: $toyId, roomName: $roomName, language: $language, endedAt: $endedAt, durationSeconds: $durationSeconds, messageCount: $messageCount, summary: $summary, topics: $topics, emotion: $emotion, metadata: $metadata, engagementStats: $engagementStats)';
}


}

/// @nodoc
abstract mixin class $VoiceSessionCopyWith<$Res>  {
  factory $VoiceSessionCopyWith(VoiceSession value, $Res Function(VoiceSession) _then) = _$VoiceSessionCopyWithImpl;
@useResult
$Res call({
 String id, String status, DateTime startedAt, String? userId, String? toyId, String? roomName, String language, DateTime? endedAt, int? durationSeconds, int messageCount, String? summary,@JsonKey(fromJson: _topicsFromJson) List<String>? topics, String? emotion, Map<String, dynamic>? metadata, EngagementStats? engagementStats
});


$EngagementStatsCopyWith<$Res>? get engagementStats;

}
/// @nodoc
class _$VoiceSessionCopyWithImpl<$Res>
    implements $VoiceSessionCopyWith<$Res> {
  _$VoiceSessionCopyWithImpl(this._self, this._then);

  final VoiceSession _self;
  final $Res Function(VoiceSession) _then;

/// Create a copy of VoiceSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? startedAt = null,Object? userId = freezed,Object? toyId = freezed,Object? roomName = freezed,Object? language = null,Object? endedAt = freezed,Object? durationSeconds = freezed,Object? messageCount = null,Object? summary = freezed,Object? topics = freezed,Object? emotion = freezed,Object? metadata = freezed,Object? engagementStats = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,toyId: freezed == toyId ? _self.toyId : toyId // ignore: cast_nullable_to_non_nullable
as String?,roomName: freezed == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,topics: freezed == topics ? _self.topics : topics // ignore: cast_nullable_to_non_nullable
as List<String>?,emotion: freezed == emotion ? _self.emotion : emotion // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,engagementStats: freezed == engagementStats ? _self.engagementStats : engagementStats // ignore: cast_nullable_to_non_nullable
as EngagementStats?,
  ));
}
/// Create a copy of VoiceSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EngagementStatsCopyWith<$Res>? get engagementStats {
    if (_self.engagementStats == null) {
    return null;
  }

  return $EngagementStatsCopyWith<$Res>(_self.engagementStats!, (value) {
    return _then(_self.copyWith(engagementStats: value));
  });
}
}


/// Adds pattern-matching-related methods to [VoiceSession].
extension VoiceSessionPatterns on VoiceSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceSession value)  $default,){
final _that = this;
switch (_that) {
case _VoiceSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceSession value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status,  DateTime startedAt,  String? userId,  String? toyId,  String? roomName,  String language,  DateTime? endedAt,  int? durationSeconds,  int messageCount,  String? summary, @JsonKey(fromJson: _topicsFromJson)  List<String>? topics,  String? emotion,  Map<String, dynamic>? metadata,  EngagementStats? engagementStats)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceSession() when $default != null:
return $default(_that.id,_that.status,_that.startedAt,_that.userId,_that.toyId,_that.roomName,_that.language,_that.endedAt,_that.durationSeconds,_that.messageCount,_that.summary,_that.topics,_that.emotion,_that.metadata,_that.engagementStats);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status,  DateTime startedAt,  String? userId,  String? toyId,  String? roomName,  String language,  DateTime? endedAt,  int? durationSeconds,  int messageCount,  String? summary, @JsonKey(fromJson: _topicsFromJson)  List<String>? topics,  String? emotion,  Map<String, dynamic>? metadata,  EngagementStats? engagementStats)  $default,) {final _that = this;
switch (_that) {
case _VoiceSession():
return $default(_that.id,_that.status,_that.startedAt,_that.userId,_that.toyId,_that.roomName,_that.language,_that.endedAt,_that.durationSeconds,_that.messageCount,_that.summary,_that.topics,_that.emotion,_that.metadata,_that.engagementStats);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status,  DateTime startedAt,  String? userId,  String? toyId,  String? roomName,  String language,  DateTime? endedAt,  int? durationSeconds,  int messageCount,  String? summary, @JsonKey(fromJson: _topicsFromJson)  List<String>? topics,  String? emotion,  Map<String, dynamic>? metadata,  EngagementStats? engagementStats)?  $default,) {final _that = this;
switch (_that) {
case _VoiceSession() when $default != null:
return $default(_that.id,_that.status,_that.startedAt,_that.userId,_that.toyId,_that.roomName,_that.language,_that.endedAt,_that.durationSeconds,_that.messageCount,_that.summary,_that.topics,_that.emotion,_that.metadata,_that.engagementStats);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceSession implements VoiceSession {
  const _VoiceSession({required this.id, required this.status, required this.startedAt, this.userId, this.toyId, this.roomName, this.language = 'es', this.endedAt, this.durationSeconds, this.messageCount = 0, this.summary, @JsonKey(fromJson: _topicsFromJson) final  List<String>? topics, this.emotion, final  Map<String, dynamic>? metadata, this.engagementStats}): _topics = topics,_metadata = metadata;
  factory _VoiceSession.fromJson(Map<String, dynamic> json) => _$VoiceSessionFromJson(json);

@override final  String id;
@override final  String status;
@override final  DateTime startedAt;
@override final  String? userId;
@override final  String? toyId;
@override final  String? roomName;
@override@JsonKey() final  String language;
@override final  DateTime? endedAt;
@override final  int? durationSeconds;
@override@JsonKey() final  int messageCount;
@override final  String? summary;
 final  List<String>? _topics;
@override@JsonKey(fromJson: _topicsFromJson) List<String>? get topics {
  final value = _topics;
  if (value == null) return null;
  if (_topics is EqualUnmodifiableListView) return _topics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? emotion;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  EngagementStats? engagementStats;

/// Create a copy of VoiceSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceSessionCopyWith<_VoiceSession> get copyWith => __$VoiceSessionCopyWithImpl<_VoiceSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceSession&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.toyId, toyId) || other.toyId == toyId)&&(identical(other.roomName, roomName) || other.roomName == roomName)&&(identical(other.language, language) || other.language == language)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._topics, _topics)&&(identical(other.emotion, emotion) || other.emotion == emotion)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.engagementStats, engagementStats) || other.engagementStats == engagementStats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,startedAt,userId,toyId,roomName,language,endedAt,durationSeconds,messageCount,summary,const DeepCollectionEquality().hash(_topics),emotion,const DeepCollectionEquality().hash(_metadata),engagementStats);

@override
String toString() {
  return 'VoiceSession(id: $id, status: $status, startedAt: $startedAt, userId: $userId, toyId: $toyId, roomName: $roomName, language: $language, endedAt: $endedAt, durationSeconds: $durationSeconds, messageCount: $messageCount, summary: $summary, topics: $topics, emotion: $emotion, metadata: $metadata, engagementStats: $engagementStats)';
}


}

/// @nodoc
abstract mixin class _$VoiceSessionCopyWith<$Res> implements $VoiceSessionCopyWith<$Res> {
  factory _$VoiceSessionCopyWith(_VoiceSession value, $Res Function(_VoiceSession) _then) = __$VoiceSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String status, DateTime startedAt, String? userId, String? toyId, String? roomName, String language, DateTime? endedAt, int? durationSeconds, int messageCount, String? summary,@JsonKey(fromJson: _topicsFromJson) List<String>? topics, String? emotion, Map<String, dynamic>? metadata, EngagementStats? engagementStats
});


@override $EngagementStatsCopyWith<$Res>? get engagementStats;

}
/// @nodoc
class __$VoiceSessionCopyWithImpl<$Res>
    implements _$VoiceSessionCopyWith<$Res> {
  __$VoiceSessionCopyWithImpl(this._self, this._then);

  final _VoiceSession _self;
  final $Res Function(_VoiceSession) _then;

/// Create a copy of VoiceSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? startedAt = null,Object? userId = freezed,Object? toyId = freezed,Object? roomName = freezed,Object? language = null,Object? endedAt = freezed,Object? durationSeconds = freezed,Object? messageCount = null,Object? summary = freezed,Object? topics = freezed,Object? emotion = freezed,Object? metadata = freezed,Object? engagementStats = freezed,}) {
  return _then(_VoiceSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,toyId: freezed == toyId ? _self.toyId : toyId // ignore: cast_nullable_to_non_nullable
as String?,roomName: freezed == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,topics: freezed == topics ? _self._topics : topics // ignore: cast_nullable_to_non_nullable
as List<String>?,emotion: freezed == emotion ? _self.emotion : emotion // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,engagementStats: freezed == engagementStats ? _self.engagementStats : engagementStats // ignore: cast_nullable_to_non_nullable
as EngagementStats?,
  ));
}

/// Create a copy of VoiceSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EngagementStatsCopyWith<$Res>? get engagementStats {
    if (_self.engagementStats == null) {
    return null;
  }

  return $EngagementStatsCopyWith<$Res>(_self.engagementStats!, (value) {
    return _then(_self.copyWith(engagementStats: value));
  });
}
}


/// @nodoc
mixin _$EngagementStats {

 int get turnCount; String? get mood; String? get rapport; int get factsTold; int get riddlesTold; String? get favoriteCategory; double get sessionMinutes; double get cultureHype; String? get profileId;
/// Create a copy of EngagementStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EngagementStatsCopyWith<EngagementStats> get copyWith => _$EngagementStatsCopyWithImpl<EngagementStats>(this as EngagementStats, _$identity);

  /// Serializes this EngagementStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EngagementStats&&(identical(other.turnCount, turnCount) || other.turnCount == turnCount)&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.rapport, rapport) || other.rapport == rapport)&&(identical(other.factsTold, factsTold) || other.factsTold == factsTold)&&(identical(other.riddlesTold, riddlesTold) || other.riddlesTold == riddlesTold)&&(identical(other.favoriteCategory, favoriteCategory) || other.favoriteCategory == favoriteCategory)&&(identical(other.sessionMinutes, sessionMinutes) || other.sessionMinutes == sessionMinutes)&&(identical(other.cultureHype, cultureHype) || other.cultureHype == cultureHype)&&(identical(other.profileId, profileId) || other.profileId == profileId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,turnCount,mood,rapport,factsTold,riddlesTold,favoriteCategory,sessionMinutes,cultureHype,profileId);

@override
String toString() {
  return 'EngagementStats(turnCount: $turnCount, mood: $mood, rapport: $rapport, factsTold: $factsTold, riddlesTold: $riddlesTold, favoriteCategory: $favoriteCategory, sessionMinutes: $sessionMinutes, cultureHype: $cultureHype, profileId: $profileId)';
}


}

/// @nodoc
abstract mixin class $EngagementStatsCopyWith<$Res>  {
  factory $EngagementStatsCopyWith(EngagementStats value, $Res Function(EngagementStats) _then) = _$EngagementStatsCopyWithImpl;
@useResult
$Res call({
 int turnCount, String? mood, String? rapport, int factsTold, int riddlesTold, String? favoriteCategory, double sessionMinutes, double cultureHype, String? profileId
});




}
/// @nodoc
class _$EngagementStatsCopyWithImpl<$Res>
    implements $EngagementStatsCopyWith<$Res> {
  _$EngagementStatsCopyWithImpl(this._self, this._then);

  final EngagementStats _self;
  final $Res Function(EngagementStats) _then;

/// Create a copy of EngagementStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? turnCount = null,Object? mood = freezed,Object? rapport = freezed,Object? factsTold = null,Object? riddlesTold = null,Object? favoriteCategory = freezed,Object? sessionMinutes = null,Object? cultureHype = null,Object? profileId = freezed,}) {
  return _then(_self.copyWith(
turnCount: null == turnCount ? _self.turnCount : turnCount // ignore: cast_nullable_to_non_nullable
as int,mood: freezed == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String?,rapport: freezed == rapport ? _self.rapport : rapport // ignore: cast_nullable_to_non_nullable
as String?,factsTold: null == factsTold ? _self.factsTold : factsTold // ignore: cast_nullable_to_non_nullable
as int,riddlesTold: null == riddlesTold ? _self.riddlesTold : riddlesTold // ignore: cast_nullable_to_non_nullable
as int,favoriteCategory: freezed == favoriteCategory ? _self.favoriteCategory : favoriteCategory // ignore: cast_nullable_to_non_nullable
as String?,sessionMinutes: null == sessionMinutes ? _self.sessionMinutes : sessionMinutes // ignore: cast_nullable_to_non_nullable
as double,cultureHype: null == cultureHype ? _self.cultureHype : cultureHype // ignore: cast_nullable_to_non_nullable
as double,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EngagementStats].
extension EngagementStatsPatterns on EngagementStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EngagementStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EngagementStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EngagementStats value)  $default,){
final _that = this;
switch (_that) {
case _EngagementStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EngagementStats value)?  $default,){
final _that = this;
switch (_that) {
case _EngagementStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int turnCount,  String? mood,  String? rapport,  int factsTold,  int riddlesTold,  String? favoriteCategory,  double sessionMinutes,  double cultureHype,  String? profileId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EngagementStats() when $default != null:
return $default(_that.turnCount,_that.mood,_that.rapport,_that.factsTold,_that.riddlesTold,_that.favoriteCategory,_that.sessionMinutes,_that.cultureHype,_that.profileId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int turnCount,  String? mood,  String? rapport,  int factsTold,  int riddlesTold,  String? favoriteCategory,  double sessionMinutes,  double cultureHype,  String? profileId)  $default,) {final _that = this;
switch (_that) {
case _EngagementStats():
return $default(_that.turnCount,_that.mood,_that.rapport,_that.factsTold,_that.riddlesTold,_that.favoriteCategory,_that.sessionMinutes,_that.cultureHype,_that.profileId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int turnCount,  String? mood,  String? rapport,  int factsTold,  int riddlesTold,  String? favoriteCategory,  double sessionMinutes,  double cultureHype,  String? profileId)?  $default,) {final _that = this;
switch (_that) {
case _EngagementStats() when $default != null:
return $default(_that.turnCount,_that.mood,_that.rapport,_that.factsTold,_that.riddlesTold,_that.favoriteCategory,_that.sessionMinutes,_that.cultureHype,_that.profileId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EngagementStats implements EngagementStats {
  const _EngagementStats({this.turnCount = 0, this.mood, this.rapport, this.factsTold = 0, this.riddlesTold = 0, this.favoriteCategory, this.sessionMinutes = 0, this.cultureHype = 0, this.profileId});
  factory _EngagementStats.fromJson(Map<String, dynamic> json) => _$EngagementStatsFromJson(json);

@override@JsonKey() final  int turnCount;
@override final  String? mood;
@override final  String? rapport;
@override@JsonKey() final  int factsTold;
@override@JsonKey() final  int riddlesTold;
@override final  String? favoriteCategory;
@override@JsonKey() final  double sessionMinutes;
@override@JsonKey() final  double cultureHype;
@override final  String? profileId;

/// Create a copy of EngagementStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EngagementStatsCopyWith<_EngagementStats> get copyWith => __$EngagementStatsCopyWithImpl<_EngagementStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EngagementStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EngagementStats&&(identical(other.turnCount, turnCount) || other.turnCount == turnCount)&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.rapport, rapport) || other.rapport == rapport)&&(identical(other.factsTold, factsTold) || other.factsTold == factsTold)&&(identical(other.riddlesTold, riddlesTold) || other.riddlesTold == riddlesTold)&&(identical(other.favoriteCategory, favoriteCategory) || other.favoriteCategory == favoriteCategory)&&(identical(other.sessionMinutes, sessionMinutes) || other.sessionMinutes == sessionMinutes)&&(identical(other.cultureHype, cultureHype) || other.cultureHype == cultureHype)&&(identical(other.profileId, profileId) || other.profileId == profileId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,turnCount,mood,rapport,factsTold,riddlesTold,favoriteCategory,sessionMinutes,cultureHype,profileId);

@override
String toString() {
  return 'EngagementStats(turnCount: $turnCount, mood: $mood, rapport: $rapport, factsTold: $factsTold, riddlesTold: $riddlesTold, favoriteCategory: $favoriteCategory, sessionMinutes: $sessionMinutes, cultureHype: $cultureHype, profileId: $profileId)';
}


}

/// @nodoc
abstract mixin class _$EngagementStatsCopyWith<$Res> implements $EngagementStatsCopyWith<$Res> {
  factory _$EngagementStatsCopyWith(_EngagementStats value, $Res Function(_EngagementStats) _then) = __$EngagementStatsCopyWithImpl;
@override @useResult
$Res call({
 int turnCount, String? mood, String? rapport, int factsTold, int riddlesTold, String? favoriteCategory, double sessionMinutes, double cultureHype, String? profileId
});




}
/// @nodoc
class __$EngagementStatsCopyWithImpl<$Res>
    implements _$EngagementStatsCopyWith<$Res> {
  __$EngagementStatsCopyWithImpl(this._self, this._then);

  final _EngagementStats _self;
  final $Res Function(_EngagementStats) _then;

/// Create a copy of EngagementStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? turnCount = null,Object? mood = freezed,Object? rapport = freezed,Object? factsTold = null,Object? riddlesTold = null,Object? favoriteCategory = freezed,Object? sessionMinutes = null,Object? cultureHype = null,Object? profileId = freezed,}) {
  return _then(_EngagementStats(
turnCount: null == turnCount ? _self.turnCount : turnCount // ignore: cast_nullable_to_non_nullable
as int,mood: freezed == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String?,rapport: freezed == rapport ? _self.rapport : rapport // ignore: cast_nullable_to_non_nullable
as String?,factsTold: null == factsTold ? _self.factsTold : factsTold // ignore: cast_nullable_to_non_nullable
as int,riddlesTold: null == riddlesTold ? _self.riddlesTold : riddlesTold // ignore: cast_nullable_to_non_nullable
as int,favoriteCategory: freezed == favoriteCategory ? _self.favoriteCategory : favoriteCategory // ignore: cast_nullable_to_non_nullable
as String?,sessionMinutes: null == sessionMinutes ? _self.sessionMinutes : sessionMinutes // ignore: cast_nullable_to_non_nullable
as double,cultureHype: null == cultureHype ? _self.cultureHype : cultureHype // ignore: cast_nullable_to_non_nullable
as double,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AiConversation {

 String get id; String get sessionId; String get messageType; String get content; String? get audioUrl; DateTime? get createdAt;
/// Create a copy of AiConversation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiConversationCopyWith<AiConversation> get copyWith => _$AiConversationCopyWithImpl<AiConversation>(this as AiConversation, _$identity);

  /// Serializes this AiConversation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiConversation&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.content, content) || other.content == content)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,messageType,content,audioUrl,createdAt);

@override
String toString() {
  return 'AiConversation(id: $id, sessionId: $sessionId, messageType: $messageType, content: $content, audioUrl: $audioUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AiConversationCopyWith<$Res>  {
  factory $AiConversationCopyWith(AiConversation value, $Res Function(AiConversation) _then) = _$AiConversationCopyWithImpl;
@useResult
$Res call({
 String id, String sessionId, String messageType, String content, String? audioUrl, DateTime? createdAt
});




}
/// @nodoc
class _$AiConversationCopyWithImpl<$Res>
    implements $AiConversationCopyWith<$Res> {
  _$AiConversationCopyWithImpl(this._self, this._then);

  final AiConversation _self;
  final $Res Function(AiConversation) _then;

/// Create a copy of AiConversation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = null,Object? messageType = null,Object? content = null,Object? audioUrl = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiConversation].
extension AiConversationPatterns on AiConversation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiConversation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiConversation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiConversation value)  $default,){
final _that = this;
switch (_that) {
case _AiConversation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiConversation value)?  $default,){
final _that = this;
switch (_that) {
case _AiConversation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sessionId,  String messageType,  String content,  String? audioUrl,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiConversation() when $default != null:
return $default(_that.id,_that.sessionId,_that.messageType,_that.content,_that.audioUrl,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sessionId,  String messageType,  String content,  String? audioUrl,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _AiConversation():
return $default(_that.id,_that.sessionId,_that.messageType,_that.content,_that.audioUrl,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sessionId,  String messageType,  String content,  String? audioUrl,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AiConversation() when $default != null:
return $default(_that.id,_that.sessionId,_that.messageType,_that.content,_that.audioUrl,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiConversation implements AiConversation {
  const _AiConversation({required this.id, required this.sessionId, required this.messageType, required this.content, this.audioUrl, this.createdAt});
  factory _AiConversation.fromJson(Map<String, dynamic> json) => _$AiConversationFromJson(json);

@override final  String id;
@override final  String sessionId;
@override final  String messageType;
@override final  String content;
@override final  String? audioUrl;
@override final  DateTime? createdAt;

/// Create a copy of AiConversation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiConversationCopyWith<_AiConversation> get copyWith => __$AiConversationCopyWithImpl<_AiConversation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiConversationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiConversation&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.content, content) || other.content == content)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,messageType,content,audioUrl,createdAt);

@override
String toString() {
  return 'AiConversation(id: $id, sessionId: $sessionId, messageType: $messageType, content: $content, audioUrl: $audioUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AiConversationCopyWith<$Res> implements $AiConversationCopyWith<$Res> {
  factory _$AiConversationCopyWith(_AiConversation value, $Res Function(_AiConversation) _then) = __$AiConversationCopyWithImpl;
@override @useResult
$Res call({
 String id, String sessionId, String messageType, String content, String? audioUrl, DateTime? createdAt
});




}
/// @nodoc
class __$AiConversationCopyWithImpl<$Res>
    implements _$AiConversationCopyWith<$Res> {
  __$AiConversationCopyWithImpl(this._self, this._then);

  final _AiConversation _self;
  final $Res Function(_AiConversation) _then;

/// Create a copy of AiConversation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? messageType = null,Object? content = null,Object? audioUrl = freezed,Object? createdAt = freezed,}) {
  return _then(_AiConversation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$VoiceMetrics {

 int get totalSessions; int get activeSessions; int get totalConversations; double get averageSessionDuration; int get totalTokensUsed; double get totalCost;
/// Create a copy of VoiceMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceMetricsCopyWith<VoiceMetrics> get copyWith => _$VoiceMetricsCopyWithImpl<VoiceMetrics>(this as VoiceMetrics, _$identity);

  /// Serializes this VoiceMetrics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceMetrics&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.activeSessions, activeSessions) || other.activeSessions == activeSessions)&&(identical(other.totalConversations, totalConversations) || other.totalConversations == totalConversations)&&(identical(other.averageSessionDuration, averageSessionDuration) || other.averageSessionDuration == averageSessionDuration)&&(identical(other.totalTokensUsed, totalTokensUsed) || other.totalTokensUsed == totalTokensUsed)&&(identical(other.totalCost, totalCost) || other.totalCost == totalCost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalSessions,activeSessions,totalConversations,averageSessionDuration,totalTokensUsed,totalCost);

@override
String toString() {
  return 'VoiceMetrics(totalSessions: $totalSessions, activeSessions: $activeSessions, totalConversations: $totalConversations, averageSessionDuration: $averageSessionDuration, totalTokensUsed: $totalTokensUsed, totalCost: $totalCost)';
}


}

/// @nodoc
abstract mixin class $VoiceMetricsCopyWith<$Res>  {
  factory $VoiceMetricsCopyWith(VoiceMetrics value, $Res Function(VoiceMetrics) _then) = _$VoiceMetricsCopyWithImpl;
@useResult
$Res call({
 int totalSessions, int activeSessions, int totalConversations, double averageSessionDuration, int totalTokensUsed, double totalCost
});




}
/// @nodoc
class _$VoiceMetricsCopyWithImpl<$Res>
    implements $VoiceMetricsCopyWith<$Res> {
  _$VoiceMetricsCopyWithImpl(this._self, this._then);

  final VoiceMetrics _self;
  final $Res Function(VoiceMetrics) _then;

/// Create a copy of VoiceMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalSessions = null,Object? activeSessions = null,Object? totalConversations = null,Object? averageSessionDuration = null,Object? totalTokensUsed = null,Object? totalCost = null,}) {
  return _then(_self.copyWith(
totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,activeSessions: null == activeSessions ? _self.activeSessions : activeSessions // ignore: cast_nullable_to_non_nullable
as int,totalConversations: null == totalConversations ? _self.totalConversations : totalConversations // ignore: cast_nullable_to_non_nullable
as int,averageSessionDuration: null == averageSessionDuration ? _self.averageSessionDuration : averageSessionDuration // ignore: cast_nullable_to_non_nullable
as double,totalTokensUsed: null == totalTokensUsed ? _self.totalTokensUsed : totalTokensUsed // ignore: cast_nullable_to_non_nullable
as int,totalCost: null == totalCost ? _self.totalCost : totalCost // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceMetrics].
extension VoiceMetricsPatterns on VoiceMetrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceMetrics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceMetrics value)  $default,){
final _that = this;
switch (_that) {
case _VoiceMetrics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceMetrics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalSessions,  int activeSessions,  int totalConversations,  double averageSessionDuration,  int totalTokensUsed,  double totalCost)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceMetrics() when $default != null:
return $default(_that.totalSessions,_that.activeSessions,_that.totalConversations,_that.averageSessionDuration,_that.totalTokensUsed,_that.totalCost);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalSessions,  int activeSessions,  int totalConversations,  double averageSessionDuration,  int totalTokensUsed,  double totalCost)  $default,) {final _that = this;
switch (_that) {
case _VoiceMetrics():
return $default(_that.totalSessions,_that.activeSessions,_that.totalConversations,_that.averageSessionDuration,_that.totalTokensUsed,_that.totalCost);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalSessions,  int activeSessions,  int totalConversations,  double averageSessionDuration,  int totalTokensUsed,  double totalCost)?  $default,) {final _that = this;
switch (_that) {
case _VoiceMetrics() when $default != null:
return $default(_that.totalSessions,_that.activeSessions,_that.totalConversations,_that.averageSessionDuration,_that.totalTokensUsed,_that.totalCost);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceMetrics implements VoiceMetrics {
  const _VoiceMetrics({this.totalSessions = 0, this.activeSessions = 0, this.totalConversations = 0, this.averageSessionDuration = 0, this.totalTokensUsed = 0, this.totalCost = 0});
  factory _VoiceMetrics.fromJson(Map<String, dynamic> json) => _$VoiceMetricsFromJson(json);

@override@JsonKey() final  int totalSessions;
@override@JsonKey() final  int activeSessions;
@override@JsonKey() final  int totalConversations;
@override@JsonKey() final  double averageSessionDuration;
@override@JsonKey() final  int totalTokensUsed;
@override@JsonKey() final  double totalCost;

/// Create a copy of VoiceMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceMetricsCopyWith<_VoiceMetrics> get copyWith => __$VoiceMetricsCopyWithImpl<_VoiceMetrics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceMetricsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceMetrics&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.activeSessions, activeSessions) || other.activeSessions == activeSessions)&&(identical(other.totalConversations, totalConversations) || other.totalConversations == totalConversations)&&(identical(other.averageSessionDuration, averageSessionDuration) || other.averageSessionDuration == averageSessionDuration)&&(identical(other.totalTokensUsed, totalTokensUsed) || other.totalTokensUsed == totalTokensUsed)&&(identical(other.totalCost, totalCost) || other.totalCost == totalCost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalSessions,activeSessions,totalConversations,averageSessionDuration,totalTokensUsed,totalCost);

@override
String toString() {
  return 'VoiceMetrics(totalSessions: $totalSessions, activeSessions: $activeSessions, totalConversations: $totalConversations, averageSessionDuration: $averageSessionDuration, totalTokensUsed: $totalTokensUsed, totalCost: $totalCost)';
}


}

/// @nodoc
abstract mixin class _$VoiceMetricsCopyWith<$Res> implements $VoiceMetricsCopyWith<$Res> {
  factory _$VoiceMetricsCopyWith(_VoiceMetrics value, $Res Function(_VoiceMetrics) _then) = __$VoiceMetricsCopyWithImpl;
@override @useResult
$Res call({
 int totalSessions, int activeSessions, int totalConversations, double averageSessionDuration, int totalTokensUsed, double totalCost
});




}
/// @nodoc
class __$VoiceMetricsCopyWithImpl<$Res>
    implements _$VoiceMetricsCopyWith<$Res> {
  __$VoiceMetricsCopyWithImpl(this._self, this._then);

  final _VoiceMetrics _self;
  final $Res Function(_VoiceMetrics) _then;

/// Create a copy of VoiceMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalSessions = null,Object? activeSessions = null,Object? totalConversations = null,Object? averageSessionDuration = null,Object? totalTokensUsed = null,Object? totalCost = null,}) {
  return _then(_VoiceMetrics(
totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,activeSessions: null == activeSessions ? _self.activeSessions : activeSessions // ignore: cast_nullable_to_non_nullable
as int,totalConversations: null == totalConversations ? _self.totalConversations : totalConversations // ignore: cast_nullable_to_non_nullable
as int,averageSessionDuration: null == averageSessionDuration ? _self.averageSessionDuration : averageSessionDuration // ignore: cast_nullable_to_non_nullable
as double,totalTokensUsed: null == totalTokensUsed ? _self.totalTokensUsed : totalTokensUsed // ignore: cast_nullable_to_non_nullable
as int,totalCost: null == totalCost ? _self.totalCost : totalCost // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$UserLimits {

 VoiceLimits get voice; SessionLimits get session; PaymentLimits get payments;
/// Create a copy of UserLimits
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserLimitsCopyWith<UserLimits> get copyWith => _$UserLimitsCopyWithImpl<UserLimits>(this as UserLimits, _$identity);

  /// Serializes this UserLimits to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserLimits&&(identical(other.voice, voice) || other.voice == voice)&&(identical(other.session, session) || other.session == session)&&(identical(other.payments, payments) || other.payments == payments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,voice,session,payments);

@override
String toString() {
  return 'UserLimits(voice: $voice, session: $session, payments: $payments)';
}


}

/// @nodoc
abstract mixin class $UserLimitsCopyWith<$Res>  {
  factory $UserLimitsCopyWith(UserLimits value, $Res Function(UserLimits) _then) = _$UserLimitsCopyWithImpl;
@useResult
$Res call({
 VoiceLimits voice, SessionLimits session, PaymentLimits payments
});


$VoiceLimitsCopyWith<$Res> get voice;$SessionLimitsCopyWith<$Res> get session;$PaymentLimitsCopyWith<$Res> get payments;

}
/// @nodoc
class _$UserLimitsCopyWithImpl<$Res>
    implements $UserLimitsCopyWith<$Res> {
  _$UserLimitsCopyWithImpl(this._self, this._then);

  final UserLimits _self;
  final $Res Function(UserLimits) _then;

/// Create a copy of UserLimits
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? voice = null,Object? session = null,Object? payments = null,}) {
  return _then(_self.copyWith(
voice: null == voice ? _self.voice : voice // ignore: cast_nullable_to_non_nullable
as VoiceLimits,session: null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as SessionLimits,payments: null == payments ? _self.payments : payments // ignore: cast_nullable_to_non_nullable
as PaymentLimits,
  ));
}
/// Create a copy of UserLimits
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoiceLimitsCopyWith<$Res> get voice {
  
  return $VoiceLimitsCopyWith<$Res>(_self.voice, (value) {
    return _then(_self.copyWith(voice: value));
  });
}/// Create a copy of UserLimits
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionLimitsCopyWith<$Res> get session {
  
  return $SessionLimitsCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}/// Create a copy of UserLimits
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentLimitsCopyWith<$Res> get payments {
  
  return $PaymentLimitsCopyWith<$Res>(_self.payments, (value) {
    return _then(_self.copyWith(payments: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserLimits].
extension UserLimitsPatterns on UserLimits {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserLimits value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserLimits() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserLimits value)  $default,){
final _that = this;
switch (_that) {
case _UserLimits():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserLimits value)?  $default,){
final _that = this;
switch (_that) {
case _UserLimits() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VoiceLimits voice,  SessionLimits session,  PaymentLimits payments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserLimits() when $default != null:
return $default(_that.voice,_that.session,_that.payments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VoiceLimits voice,  SessionLimits session,  PaymentLimits payments)  $default,) {final _that = this;
switch (_that) {
case _UserLimits():
return $default(_that.voice,_that.session,_that.payments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VoiceLimits voice,  SessionLimits session,  PaymentLimits payments)?  $default,) {final _that = this;
switch (_that) {
case _UserLimits() when $default != null:
return $default(_that.voice,_that.session,_that.payments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserLimits implements UserLimits {
  const _UserLimits({this.voice = const VoiceLimits(), this.session = const SessionLimits(), this.payments = const PaymentLimits()});
  factory _UserLimits.fromJson(Map<String, dynamic> json) => _$UserLimitsFromJson(json);

@override@JsonKey() final  VoiceLimits voice;
@override@JsonKey() final  SessionLimits session;
@override@JsonKey() final  PaymentLimits payments;

/// Create a copy of UserLimits
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserLimitsCopyWith<_UserLimits> get copyWith => __$UserLimitsCopyWithImpl<_UserLimits>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserLimitsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserLimits&&(identical(other.voice, voice) || other.voice == voice)&&(identical(other.session, session) || other.session == session)&&(identical(other.payments, payments) || other.payments == payments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,voice,session,payments);

@override
String toString() {
  return 'UserLimits(voice: $voice, session: $session, payments: $payments)';
}


}

/// @nodoc
abstract mixin class _$UserLimitsCopyWith<$Res> implements $UserLimitsCopyWith<$Res> {
  factory _$UserLimitsCopyWith(_UserLimits value, $Res Function(_UserLimits) _then) = __$UserLimitsCopyWithImpl;
@override @useResult
$Res call({
 VoiceLimits voice, SessionLimits session, PaymentLimits payments
});


@override $VoiceLimitsCopyWith<$Res> get voice;@override $SessionLimitsCopyWith<$Res> get session;@override $PaymentLimitsCopyWith<$Res> get payments;

}
/// @nodoc
class __$UserLimitsCopyWithImpl<$Res>
    implements _$UserLimitsCopyWith<$Res> {
  __$UserLimitsCopyWithImpl(this._self, this._then);

  final _UserLimits _self;
  final $Res Function(_UserLimits) _then;

/// Create a copy of UserLimits
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? voice = null,Object? session = null,Object? payments = null,}) {
  return _then(_UserLimits(
voice: null == voice ? _self.voice : voice // ignore: cast_nullable_to_non_nullable
as VoiceLimits,session: null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as SessionLimits,payments: null == payments ? _self.payments : payments // ignore: cast_nullable_to_non_nullable
as PaymentLimits,
  ));
}

/// Create a copy of UserLimits
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoiceLimitsCopyWith<$Res> get voice {
  
  return $VoiceLimitsCopyWith<$Res>(_self.voice, (value) {
    return _then(_self.copyWith(voice: value));
  });
}/// Create a copy of UserLimits
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionLimitsCopyWith<$Res> get session {
  
  return $SessionLimitsCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}/// Create a copy of UserLimits
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentLimitsCopyWith<$Res> get payments {
  
  return $PaymentLimitsCopyWith<$Res>(_self.payments, (value) {
    return _then(_self.copyWith(payments: value));
  });
}
}


/// @nodoc
mixin _$VoiceLimits {

 double get dailyMinutesUsed; double get dailyMinutesLimit; double get monthlyMinutesUsed; double get monthlyMinutesLimit; int get maxSessionMinutes; int get toyCount;
/// Create a copy of VoiceLimits
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceLimitsCopyWith<VoiceLimits> get copyWith => _$VoiceLimitsCopyWithImpl<VoiceLimits>(this as VoiceLimits, _$identity);

  /// Serializes this VoiceLimits to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceLimits&&(identical(other.dailyMinutesUsed, dailyMinutesUsed) || other.dailyMinutesUsed == dailyMinutesUsed)&&(identical(other.dailyMinutesLimit, dailyMinutesLimit) || other.dailyMinutesLimit == dailyMinutesLimit)&&(identical(other.monthlyMinutesUsed, monthlyMinutesUsed) || other.monthlyMinutesUsed == monthlyMinutesUsed)&&(identical(other.monthlyMinutesLimit, monthlyMinutesLimit) || other.monthlyMinutesLimit == monthlyMinutesLimit)&&(identical(other.maxSessionMinutes, maxSessionMinutes) || other.maxSessionMinutes == maxSessionMinutes)&&(identical(other.toyCount, toyCount) || other.toyCount == toyCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dailyMinutesUsed,dailyMinutesLimit,monthlyMinutesUsed,monthlyMinutesLimit,maxSessionMinutes,toyCount);

@override
String toString() {
  return 'VoiceLimits(dailyMinutesUsed: $dailyMinutesUsed, dailyMinutesLimit: $dailyMinutesLimit, monthlyMinutesUsed: $monthlyMinutesUsed, monthlyMinutesLimit: $monthlyMinutesLimit, maxSessionMinutes: $maxSessionMinutes, toyCount: $toyCount)';
}


}

/// @nodoc
abstract mixin class $VoiceLimitsCopyWith<$Res>  {
  factory $VoiceLimitsCopyWith(VoiceLimits value, $Res Function(VoiceLimits) _then) = _$VoiceLimitsCopyWithImpl;
@useResult
$Res call({
 double dailyMinutesUsed, double dailyMinutesLimit, double monthlyMinutesUsed, double monthlyMinutesLimit, int maxSessionMinutes, int toyCount
});




}
/// @nodoc
class _$VoiceLimitsCopyWithImpl<$Res>
    implements $VoiceLimitsCopyWith<$Res> {
  _$VoiceLimitsCopyWithImpl(this._self, this._then);

  final VoiceLimits _self;
  final $Res Function(VoiceLimits) _then;

/// Create a copy of VoiceLimits
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dailyMinutesUsed = null,Object? dailyMinutesLimit = null,Object? monthlyMinutesUsed = null,Object? monthlyMinutesLimit = null,Object? maxSessionMinutes = null,Object? toyCount = null,}) {
  return _then(_self.copyWith(
dailyMinutesUsed: null == dailyMinutesUsed ? _self.dailyMinutesUsed : dailyMinutesUsed // ignore: cast_nullable_to_non_nullable
as double,dailyMinutesLimit: null == dailyMinutesLimit ? _self.dailyMinutesLimit : dailyMinutesLimit // ignore: cast_nullable_to_non_nullable
as double,monthlyMinutesUsed: null == monthlyMinutesUsed ? _self.monthlyMinutesUsed : monthlyMinutesUsed // ignore: cast_nullable_to_non_nullable
as double,monthlyMinutesLimit: null == monthlyMinutesLimit ? _self.monthlyMinutesLimit : monthlyMinutesLimit // ignore: cast_nullable_to_non_nullable
as double,maxSessionMinutes: null == maxSessionMinutes ? _self.maxSessionMinutes : maxSessionMinutes // ignore: cast_nullable_to_non_nullable
as int,toyCount: null == toyCount ? _self.toyCount : toyCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceLimits].
extension VoiceLimitsPatterns on VoiceLimits {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceLimits value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceLimits() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceLimits value)  $default,){
final _that = this;
switch (_that) {
case _VoiceLimits():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceLimits value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceLimits() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double dailyMinutesUsed,  double dailyMinutesLimit,  double monthlyMinutesUsed,  double monthlyMinutesLimit,  int maxSessionMinutes,  int toyCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceLimits() when $default != null:
return $default(_that.dailyMinutesUsed,_that.dailyMinutesLimit,_that.monthlyMinutesUsed,_that.monthlyMinutesLimit,_that.maxSessionMinutes,_that.toyCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double dailyMinutesUsed,  double dailyMinutesLimit,  double monthlyMinutesUsed,  double monthlyMinutesLimit,  int maxSessionMinutes,  int toyCount)  $default,) {final _that = this;
switch (_that) {
case _VoiceLimits():
return $default(_that.dailyMinutesUsed,_that.dailyMinutesLimit,_that.monthlyMinutesUsed,_that.monthlyMinutesLimit,_that.maxSessionMinutes,_that.toyCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double dailyMinutesUsed,  double dailyMinutesLimit,  double monthlyMinutesUsed,  double monthlyMinutesLimit,  int maxSessionMinutes,  int toyCount)?  $default,) {final _that = this;
switch (_that) {
case _VoiceLimits() when $default != null:
return $default(_that.dailyMinutesUsed,_that.dailyMinutesLimit,_that.monthlyMinutesUsed,_that.monthlyMinutesLimit,_that.maxSessionMinutes,_that.toyCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceLimits implements VoiceLimits {
  const _VoiceLimits({this.dailyMinutesUsed = 0, this.dailyMinutesLimit = 60, this.monthlyMinutesUsed = 0, this.monthlyMinutesLimit = 300, this.maxSessionMinutes = 15, this.toyCount = 0});
  factory _VoiceLimits.fromJson(Map<String, dynamic> json) => _$VoiceLimitsFromJson(json);

@override@JsonKey() final  double dailyMinutesUsed;
@override@JsonKey() final  double dailyMinutesLimit;
@override@JsonKey() final  double monthlyMinutesUsed;
@override@JsonKey() final  double monthlyMinutesLimit;
@override@JsonKey() final  int maxSessionMinutes;
@override@JsonKey() final  int toyCount;

/// Create a copy of VoiceLimits
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceLimitsCopyWith<_VoiceLimits> get copyWith => __$VoiceLimitsCopyWithImpl<_VoiceLimits>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceLimitsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceLimits&&(identical(other.dailyMinutesUsed, dailyMinutesUsed) || other.dailyMinutesUsed == dailyMinutesUsed)&&(identical(other.dailyMinutesLimit, dailyMinutesLimit) || other.dailyMinutesLimit == dailyMinutesLimit)&&(identical(other.monthlyMinutesUsed, monthlyMinutesUsed) || other.monthlyMinutesUsed == monthlyMinutesUsed)&&(identical(other.monthlyMinutesLimit, monthlyMinutesLimit) || other.monthlyMinutesLimit == monthlyMinutesLimit)&&(identical(other.maxSessionMinutes, maxSessionMinutes) || other.maxSessionMinutes == maxSessionMinutes)&&(identical(other.toyCount, toyCount) || other.toyCount == toyCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dailyMinutesUsed,dailyMinutesLimit,monthlyMinutesUsed,monthlyMinutesLimit,maxSessionMinutes,toyCount);

@override
String toString() {
  return 'VoiceLimits(dailyMinutesUsed: $dailyMinutesUsed, dailyMinutesLimit: $dailyMinutesLimit, monthlyMinutesUsed: $monthlyMinutesUsed, monthlyMinutesLimit: $monthlyMinutesLimit, maxSessionMinutes: $maxSessionMinutes, toyCount: $toyCount)';
}


}

/// @nodoc
abstract mixin class _$VoiceLimitsCopyWith<$Res> implements $VoiceLimitsCopyWith<$Res> {
  factory _$VoiceLimitsCopyWith(_VoiceLimits value, $Res Function(_VoiceLimits) _then) = __$VoiceLimitsCopyWithImpl;
@override @useResult
$Res call({
 double dailyMinutesUsed, double dailyMinutesLimit, double monthlyMinutesUsed, double monthlyMinutesLimit, int maxSessionMinutes, int toyCount
});




}
/// @nodoc
class __$VoiceLimitsCopyWithImpl<$Res>
    implements _$VoiceLimitsCopyWith<$Res> {
  __$VoiceLimitsCopyWithImpl(this._self, this._then);

  final _VoiceLimits _self;
  final $Res Function(_VoiceLimits) _then;

/// Create a copy of VoiceLimits
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dailyMinutesUsed = null,Object? dailyMinutesLimit = null,Object? monthlyMinutesUsed = null,Object? monthlyMinutesLimit = null,Object? maxSessionMinutes = null,Object? toyCount = null,}) {
  return _then(_VoiceLimits(
dailyMinutesUsed: null == dailyMinutesUsed ? _self.dailyMinutesUsed : dailyMinutesUsed // ignore: cast_nullable_to_non_nullable
as double,dailyMinutesLimit: null == dailyMinutesLimit ? _self.dailyMinutesLimit : dailyMinutesLimit // ignore: cast_nullable_to_non_nullable
as double,monthlyMinutesUsed: null == monthlyMinutesUsed ? _self.monthlyMinutesUsed : monthlyMinutesUsed // ignore: cast_nullable_to_non_nullable
as double,monthlyMinutesLimit: null == monthlyMinutesLimit ? _self.monthlyMinutesLimit : monthlyMinutesLimit // ignore: cast_nullable_to_non_nullable
as double,maxSessionMinutes: null == maxSessionMinutes ? _self.maxSessionMinutes : maxSessionMinutes // ignore: cast_nullable_to_non_nullable
as int,toyCount: null == toyCount ? _self.toyCount : toyCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SessionLimits {

 int get maxConcurrentSessions; String get sessionTimeout;
/// Create a copy of SessionLimits
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionLimitsCopyWith<SessionLimits> get copyWith => _$SessionLimitsCopyWithImpl<SessionLimits>(this as SessionLimits, _$identity);

  /// Serializes this SessionLimits to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionLimits&&(identical(other.maxConcurrentSessions, maxConcurrentSessions) || other.maxConcurrentSessions == maxConcurrentSessions)&&(identical(other.sessionTimeout, sessionTimeout) || other.sessionTimeout == sessionTimeout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maxConcurrentSessions,sessionTimeout);

@override
String toString() {
  return 'SessionLimits(maxConcurrentSessions: $maxConcurrentSessions, sessionTimeout: $sessionTimeout)';
}


}

/// @nodoc
abstract mixin class $SessionLimitsCopyWith<$Res>  {
  factory $SessionLimitsCopyWith(SessionLimits value, $Res Function(SessionLimits) _then) = _$SessionLimitsCopyWithImpl;
@useResult
$Res call({
 int maxConcurrentSessions, String sessionTimeout
});




}
/// @nodoc
class _$SessionLimitsCopyWithImpl<$Res>
    implements $SessionLimitsCopyWith<$Res> {
  _$SessionLimitsCopyWithImpl(this._self, this._then);

  final SessionLimits _self;
  final $Res Function(SessionLimits) _then;

/// Create a copy of SessionLimits
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maxConcurrentSessions = null,Object? sessionTimeout = null,}) {
  return _then(_self.copyWith(
maxConcurrentSessions: null == maxConcurrentSessions ? _self.maxConcurrentSessions : maxConcurrentSessions // ignore: cast_nullable_to_non_nullable
as int,sessionTimeout: null == sessionTimeout ? _self.sessionTimeout : sessionTimeout // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionLimits].
extension SessionLimitsPatterns on SessionLimits {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionLimits value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionLimits() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionLimits value)  $default,){
final _that = this;
switch (_that) {
case _SessionLimits():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionLimits value)?  $default,){
final _that = this;
switch (_that) {
case _SessionLimits() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int maxConcurrentSessions,  String sessionTimeout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionLimits() when $default != null:
return $default(_that.maxConcurrentSessions,_that.sessionTimeout);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int maxConcurrentSessions,  String sessionTimeout)  $default,) {final _that = this;
switch (_that) {
case _SessionLimits():
return $default(_that.maxConcurrentSessions,_that.sessionTimeout);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int maxConcurrentSessions,  String sessionTimeout)?  $default,) {final _that = this;
switch (_that) {
case _SessionLimits() when $default != null:
return $default(_that.maxConcurrentSessions,_that.sessionTimeout);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionLimits implements SessionLimits {
  const _SessionLimits({this.maxConcurrentSessions = 3, this.sessionTimeout = '30m'});
  factory _SessionLimits.fromJson(Map<String, dynamic> json) => _$SessionLimitsFromJson(json);

@override@JsonKey() final  int maxConcurrentSessions;
@override@JsonKey() final  String sessionTimeout;

/// Create a copy of SessionLimits
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionLimitsCopyWith<_SessionLimits> get copyWith => __$SessionLimitsCopyWithImpl<_SessionLimits>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionLimitsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionLimits&&(identical(other.maxConcurrentSessions, maxConcurrentSessions) || other.maxConcurrentSessions == maxConcurrentSessions)&&(identical(other.sessionTimeout, sessionTimeout) || other.sessionTimeout == sessionTimeout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maxConcurrentSessions,sessionTimeout);

@override
String toString() {
  return 'SessionLimits(maxConcurrentSessions: $maxConcurrentSessions, sessionTimeout: $sessionTimeout)';
}


}

/// @nodoc
abstract mixin class _$SessionLimitsCopyWith<$Res> implements $SessionLimitsCopyWith<$Res> {
  factory _$SessionLimitsCopyWith(_SessionLimits value, $Res Function(_SessionLimits) _then) = __$SessionLimitsCopyWithImpl;
@override @useResult
$Res call({
 int maxConcurrentSessions, String sessionTimeout
});




}
/// @nodoc
class __$SessionLimitsCopyWithImpl<$Res>
    implements _$SessionLimitsCopyWith<$Res> {
  __$SessionLimitsCopyWithImpl(this._self, this._then);

  final _SessionLimits _self;
  final $Res Function(_SessionLimits) _then;

/// Create a copy of SessionLimits
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maxConcurrentSessions = null,Object? sessionTimeout = null,}) {
  return _then(_SessionLimits(
maxConcurrentSessions: null == maxConcurrentSessions ? _self.maxConcurrentSessions : maxConcurrentSessions // ignore: cast_nullable_to_non_nullable
as int,sessionTimeout: null == sessionTimeout ? _self.sessionTimeout : sessionTimeout // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PaymentLimits {

 int get minPurchaseAmount; int get maxPurchaseAmount; String get currency;
/// Create a copy of PaymentLimits
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentLimitsCopyWith<PaymentLimits> get copyWith => _$PaymentLimitsCopyWithImpl<PaymentLimits>(this as PaymentLimits, _$identity);

  /// Serializes this PaymentLimits to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentLimits&&(identical(other.minPurchaseAmount, minPurchaseAmount) || other.minPurchaseAmount == minPurchaseAmount)&&(identical(other.maxPurchaseAmount, maxPurchaseAmount) || other.maxPurchaseAmount == maxPurchaseAmount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minPurchaseAmount,maxPurchaseAmount,currency);

@override
String toString() {
  return 'PaymentLimits(minPurchaseAmount: $minPurchaseAmount, maxPurchaseAmount: $maxPurchaseAmount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $PaymentLimitsCopyWith<$Res>  {
  factory $PaymentLimitsCopyWith(PaymentLimits value, $Res Function(PaymentLimits) _then) = _$PaymentLimitsCopyWithImpl;
@useResult
$Res call({
 int minPurchaseAmount, int maxPurchaseAmount, String currency
});




}
/// @nodoc
class _$PaymentLimitsCopyWithImpl<$Res>
    implements $PaymentLimitsCopyWith<$Res> {
  _$PaymentLimitsCopyWithImpl(this._self, this._then);

  final PaymentLimits _self;
  final $Res Function(PaymentLimits) _then;

/// Create a copy of PaymentLimits
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minPurchaseAmount = null,Object? maxPurchaseAmount = null,Object? currency = null,}) {
  return _then(_self.copyWith(
minPurchaseAmount: null == minPurchaseAmount ? _self.minPurchaseAmount : minPurchaseAmount // ignore: cast_nullable_to_non_nullable
as int,maxPurchaseAmount: null == maxPurchaseAmount ? _self.maxPurchaseAmount : maxPurchaseAmount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentLimits].
extension PaymentLimitsPatterns on PaymentLimits {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentLimits value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentLimits() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentLimits value)  $default,){
final _that = this;
switch (_that) {
case _PaymentLimits():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentLimits value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentLimits() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int minPurchaseAmount,  int maxPurchaseAmount,  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentLimits() when $default != null:
return $default(_that.minPurchaseAmount,_that.maxPurchaseAmount,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int minPurchaseAmount,  int maxPurchaseAmount,  String currency)  $default,) {final _that = this;
switch (_that) {
case _PaymentLimits():
return $default(_that.minPurchaseAmount,_that.maxPurchaseAmount,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int minPurchaseAmount,  int maxPurchaseAmount,  String currency)?  $default,) {final _that = this;
switch (_that) {
case _PaymentLimits() when $default != null:
return $default(_that.minPurchaseAmount,_that.maxPurchaseAmount,_that.currency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentLimits implements PaymentLimits {
  const _PaymentLimits({this.minPurchaseAmount = 5, this.maxPurchaseAmount = 10000, this.currency = 'USD'});
  factory _PaymentLimits.fromJson(Map<String, dynamic> json) => _$PaymentLimitsFromJson(json);

@override@JsonKey() final  int minPurchaseAmount;
@override@JsonKey() final  int maxPurchaseAmount;
@override@JsonKey() final  String currency;

/// Create a copy of PaymentLimits
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentLimitsCopyWith<_PaymentLimits> get copyWith => __$PaymentLimitsCopyWithImpl<_PaymentLimits>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentLimitsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentLimits&&(identical(other.minPurchaseAmount, minPurchaseAmount) || other.minPurchaseAmount == minPurchaseAmount)&&(identical(other.maxPurchaseAmount, maxPurchaseAmount) || other.maxPurchaseAmount == maxPurchaseAmount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minPurchaseAmount,maxPurchaseAmount,currency);

@override
String toString() {
  return 'PaymentLimits(minPurchaseAmount: $minPurchaseAmount, maxPurchaseAmount: $maxPurchaseAmount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$PaymentLimitsCopyWith<$Res> implements $PaymentLimitsCopyWith<$Res> {
  factory _$PaymentLimitsCopyWith(_PaymentLimits value, $Res Function(_PaymentLimits) _then) = __$PaymentLimitsCopyWithImpl;
@override @useResult
$Res call({
 int minPurchaseAmount, int maxPurchaseAmount, String currency
});




}
/// @nodoc
class __$PaymentLimitsCopyWithImpl<$Res>
    implements _$PaymentLimitsCopyWith<$Res> {
  __$PaymentLimitsCopyWithImpl(this._self, this._then);

  final _PaymentLimits _self;
  final $Res Function(_PaymentLimits) _then;

/// Create a copy of PaymentLimits
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minPurchaseAmount = null,Object? maxPurchaseAmount = null,Object? currency = null,}) {
  return _then(_PaymentLimits(
minPurchaseAmount: null == minPurchaseAmount ? _self.minPurchaseAmount : minPurchaseAmount // ignore: cast_nullable_to_non_nullable
as int,maxPurchaseAmount: null == maxPurchaseAmount ? _self.maxPurchaseAmount : maxPurchaseAmount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$KnowledgeEntry {

 String get id; String get content; double? get relevance; Map<String, dynamic> get metadata;
/// Create a copy of KnowledgeEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KnowledgeEntryCopyWith<KnowledgeEntry> get copyWith => _$KnowledgeEntryCopyWithImpl<KnowledgeEntry>(this as KnowledgeEntry, _$identity);

  /// Serializes this KnowledgeEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KnowledgeEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.relevance, relevance) || other.relevance == relevance)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,relevance,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'KnowledgeEntry(id: $id, content: $content, relevance: $relevance, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $KnowledgeEntryCopyWith<$Res>  {
  factory $KnowledgeEntryCopyWith(KnowledgeEntry value, $Res Function(KnowledgeEntry) _then) = _$KnowledgeEntryCopyWithImpl;
@useResult
$Res call({
 String id, String content, double? relevance, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$KnowledgeEntryCopyWithImpl<$Res>
    implements $KnowledgeEntryCopyWith<$Res> {
  _$KnowledgeEntryCopyWithImpl(this._self, this._then);

  final KnowledgeEntry _self;
  final $Res Function(KnowledgeEntry) _then;

/// Create a copy of KnowledgeEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? relevance = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,relevance: freezed == relevance ? _self.relevance : relevance // ignore: cast_nullable_to_non_nullable
as double?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [KnowledgeEntry].
extension KnowledgeEntryPatterns on KnowledgeEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KnowledgeEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KnowledgeEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KnowledgeEntry value)  $default,){
final _that = this;
switch (_that) {
case _KnowledgeEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KnowledgeEntry value)?  $default,){
final _that = this;
switch (_that) {
case _KnowledgeEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String content,  double? relevance,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KnowledgeEntry() when $default != null:
return $default(_that.id,_that.content,_that.relevance,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String content,  double? relevance,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _KnowledgeEntry():
return $default(_that.id,_that.content,_that.relevance,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String content,  double? relevance,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _KnowledgeEntry() when $default != null:
return $default(_that.id,_that.content,_that.relevance,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KnowledgeEntry implements KnowledgeEntry {
  const _KnowledgeEntry({required this.id, required this.content, this.relevance, final  Map<String, dynamic> metadata = const {}}): _metadata = metadata;
  factory _KnowledgeEntry.fromJson(Map<String, dynamic> json) => _$KnowledgeEntryFromJson(json);

@override final  String id;
@override final  String content;
@override final  double? relevance;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of KnowledgeEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KnowledgeEntryCopyWith<_KnowledgeEntry> get copyWith => __$KnowledgeEntryCopyWithImpl<_KnowledgeEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KnowledgeEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KnowledgeEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.relevance, relevance) || other.relevance == relevance)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,relevance,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'KnowledgeEntry(id: $id, content: $content, relevance: $relevance, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$KnowledgeEntryCopyWith<$Res> implements $KnowledgeEntryCopyWith<$Res> {
  factory _$KnowledgeEntryCopyWith(_KnowledgeEntry value, $Res Function(_KnowledgeEntry) _then) = __$KnowledgeEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String content, double? relevance, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$KnowledgeEntryCopyWithImpl<$Res>
    implements _$KnowledgeEntryCopyWith<$Res> {
  __$KnowledgeEntryCopyWithImpl(this._self, this._then);

  final _KnowledgeEntry _self;
  final $Res Function(_KnowledgeEntry) _then;

/// Create a copy of KnowledgeEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? relevance = freezed,Object? metadata = null,}) {
  return _then(_KnowledgeEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,relevance: freezed == relevance ? _self.relevance : relevance // ignore: cast_nullable_to_non_nullable
as double?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
