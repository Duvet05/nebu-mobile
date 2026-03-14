// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'toy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Toy {

 String get id; String get name; ToyStatus get status; String? get iotDeviceId; String? get iotDeviceStatus; String? get userId; String? get ownerId; String? get model; String? get manufacturer; String? get firmwareVersion; Map<String, dynamic>? get capabilities; Map<String, dynamic>? get settings; String? get notes; String? get prompt; String? get personalityProfile; String? get customPersonalityId; String? get greeting; String? get batteryLevel; String? get signalStrength;@JsonKey(name: 'lastSeenAt') DateTime? get lastConnected; DateTime? get activatedAt; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Toy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToyCopyWith<Toy> get copyWith => _$ToyCopyWithImpl<Toy>(this as Toy, _$identity);

  /// Serializes this Toy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Toy&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.iotDeviceId, iotDeviceId) || other.iotDeviceId == iotDeviceId)&&(identical(other.iotDeviceStatus, iotDeviceStatus) || other.iotDeviceStatus == iotDeviceStatus)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.model, model) || other.model == model)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.firmwareVersion, firmwareVersion) || other.firmwareVersion == firmwareVersion)&&const DeepCollectionEquality().equals(other.capabilities, capabilities)&&const DeepCollectionEquality().equals(other.settings, settings)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.personalityProfile, personalityProfile) || other.personalityProfile == personalityProfile)&&(identical(other.customPersonalityId, customPersonalityId) || other.customPersonalityId == customPersonalityId)&&(identical(other.greeting, greeting) || other.greeting == greeting)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.signalStrength, signalStrength) || other.signalStrength == signalStrength)&&(identical(other.lastConnected, lastConnected) || other.lastConnected == lastConnected)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,status,iotDeviceId,iotDeviceStatus,userId,ownerId,model,manufacturer,firmwareVersion,const DeepCollectionEquality().hash(capabilities),const DeepCollectionEquality().hash(settings),notes,prompt,personalityProfile,customPersonalityId,greeting,batteryLevel,signalStrength,lastConnected,activatedAt,createdAt,updatedAt]);

@override
String toString() {
  return 'Toy(id: $id, name: $name, status: $status, iotDeviceId: $iotDeviceId, iotDeviceStatus: $iotDeviceStatus, userId: $userId, ownerId: $ownerId, model: $model, manufacturer: $manufacturer, firmwareVersion: $firmwareVersion, capabilities: $capabilities, settings: $settings, notes: $notes, prompt: $prompt, personalityProfile: $personalityProfile, customPersonalityId: $customPersonalityId, greeting: $greeting, batteryLevel: $batteryLevel, signalStrength: $signalStrength, lastConnected: $lastConnected, activatedAt: $activatedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ToyCopyWith<$Res>  {
  factory $ToyCopyWith(Toy value, $Res Function(Toy) _then) = _$ToyCopyWithImpl;
@useResult
$Res call({
 String id, String name, ToyStatus status, String? iotDeviceId, String? iotDeviceStatus, String? userId, String? ownerId, String? model, String? manufacturer, String? firmwareVersion, Map<String, dynamic>? capabilities, Map<String, dynamic>? settings, String? notes, String? prompt, String? personalityProfile, String? customPersonalityId, String? greeting, String? batteryLevel, String? signalStrength,@JsonKey(name: 'lastSeenAt') DateTime? lastConnected, DateTime? activatedAt, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ToyCopyWithImpl<$Res>
    implements $ToyCopyWith<$Res> {
  _$ToyCopyWithImpl(this._self, this._then);

  final Toy _self;
  final $Res Function(Toy) _then;

/// Create a copy of Toy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? status = null,Object? iotDeviceId = freezed,Object? iotDeviceStatus = freezed,Object? userId = freezed,Object? ownerId = freezed,Object? model = freezed,Object? manufacturer = freezed,Object? firmwareVersion = freezed,Object? capabilities = freezed,Object? settings = freezed,Object? notes = freezed,Object? prompt = freezed,Object? personalityProfile = freezed,Object? customPersonalityId = freezed,Object? greeting = freezed,Object? batteryLevel = freezed,Object? signalStrength = freezed,Object? lastConnected = freezed,Object? activatedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ToyStatus,iotDeviceId: freezed == iotDeviceId ? _self.iotDeviceId : iotDeviceId // ignore: cast_nullable_to_non_nullable
as String?,iotDeviceStatus: freezed == iotDeviceStatus ? _self.iotDeviceStatus : iotDeviceStatus // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,firmwareVersion: freezed == firmwareVersion ? _self.firmwareVersion : firmwareVersion // ignore: cast_nullable_to_non_nullable
as String?,capabilities: freezed == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,prompt: freezed == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String?,personalityProfile: freezed == personalityProfile ? _self.personalityProfile : personalityProfile // ignore: cast_nullable_to_non_nullable
as String?,customPersonalityId: freezed == customPersonalityId ? _self.customPersonalityId : customPersonalityId // ignore: cast_nullable_to_non_nullable
as String?,greeting: freezed == greeting ? _self.greeting : greeting // ignore: cast_nullable_to_non_nullable
as String?,batteryLevel: freezed == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as String?,signalStrength: freezed == signalStrength ? _self.signalStrength : signalStrength // ignore: cast_nullable_to_non_nullable
as String?,lastConnected: freezed == lastConnected ? _self.lastConnected : lastConnected // ignore: cast_nullable_to_non_nullable
as DateTime?,activatedAt: freezed == activatedAt ? _self.activatedAt : activatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Toy].
extension ToyPatterns on Toy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Toy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Toy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Toy value)  $default,){
final _that = this;
switch (_that) {
case _Toy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Toy value)?  $default,){
final _that = this;
switch (_that) {
case _Toy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  ToyStatus status,  String? iotDeviceId,  String? iotDeviceStatus,  String? userId,  String? ownerId,  String? model,  String? manufacturer,  String? firmwareVersion,  Map<String, dynamic>? capabilities,  Map<String, dynamic>? settings,  String? notes,  String? prompt,  String? personalityProfile,  String? customPersonalityId,  String? greeting,  String? batteryLevel,  String? signalStrength, @JsonKey(name: 'lastSeenAt')  DateTime? lastConnected,  DateTime? activatedAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Toy() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.iotDeviceId,_that.iotDeviceStatus,_that.userId,_that.ownerId,_that.model,_that.manufacturer,_that.firmwareVersion,_that.capabilities,_that.settings,_that.notes,_that.prompt,_that.personalityProfile,_that.customPersonalityId,_that.greeting,_that.batteryLevel,_that.signalStrength,_that.lastConnected,_that.activatedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  ToyStatus status,  String? iotDeviceId,  String? iotDeviceStatus,  String? userId,  String? ownerId,  String? model,  String? manufacturer,  String? firmwareVersion,  Map<String, dynamic>? capabilities,  Map<String, dynamic>? settings,  String? notes,  String? prompt,  String? personalityProfile,  String? customPersonalityId,  String? greeting,  String? batteryLevel,  String? signalStrength, @JsonKey(name: 'lastSeenAt')  DateTime? lastConnected,  DateTime? activatedAt,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Toy():
return $default(_that.id,_that.name,_that.status,_that.iotDeviceId,_that.iotDeviceStatus,_that.userId,_that.ownerId,_that.model,_that.manufacturer,_that.firmwareVersion,_that.capabilities,_that.settings,_that.notes,_that.prompt,_that.personalityProfile,_that.customPersonalityId,_that.greeting,_that.batteryLevel,_that.signalStrength,_that.lastConnected,_that.activatedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  ToyStatus status,  String? iotDeviceId,  String? iotDeviceStatus,  String? userId,  String? ownerId,  String? model,  String? manufacturer,  String? firmwareVersion,  Map<String, dynamic>? capabilities,  Map<String, dynamic>? settings,  String? notes,  String? prompt,  String? personalityProfile,  String? customPersonalityId,  String? greeting,  String? batteryLevel,  String? signalStrength, @JsonKey(name: 'lastSeenAt')  DateTime? lastConnected,  DateTime? activatedAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Toy() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.iotDeviceId,_that.iotDeviceStatus,_that.userId,_that.ownerId,_that.model,_that.manufacturer,_that.firmwareVersion,_that.capabilities,_that.settings,_that.notes,_that.prompt,_that.personalityProfile,_that.customPersonalityId,_that.greeting,_that.batteryLevel,_that.signalStrength,_that.lastConnected,_that.activatedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Toy implements Toy {
  const _Toy({required this.id, required this.name, required this.status, this.iotDeviceId, this.iotDeviceStatus, this.userId, this.ownerId, this.model, this.manufacturer, this.firmwareVersion, final  Map<String, dynamic>? capabilities, final  Map<String, dynamic>? settings, this.notes, this.prompt, this.personalityProfile, this.customPersonalityId, this.greeting, this.batteryLevel, this.signalStrength, @JsonKey(name: 'lastSeenAt') this.lastConnected, this.activatedAt, this.createdAt, this.updatedAt}): _capabilities = capabilities,_settings = settings;
  factory _Toy.fromJson(Map<String, dynamic> json) => _$ToyFromJson(json);

@override final  String id;
@override final  String name;
@override final  ToyStatus status;
@override final  String? iotDeviceId;
@override final  String? iotDeviceStatus;
@override final  String? userId;
@override final  String? ownerId;
@override final  String? model;
@override final  String? manufacturer;
@override final  String? firmwareVersion;
 final  Map<String, dynamic>? _capabilities;
@override Map<String, dynamic>? get capabilities {
  final value = _capabilities;
  if (value == null) return null;
  if (_capabilities is EqualUnmodifiableMapView) return _capabilities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _settings;
@override Map<String, dynamic>? get settings {
  final value = _settings;
  if (value == null) return null;
  if (_settings is EqualUnmodifiableMapView) return _settings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? notes;
@override final  String? prompt;
@override final  String? personalityProfile;
@override final  String? customPersonalityId;
@override final  String? greeting;
@override final  String? batteryLevel;
@override final  String? signalStrength;
@override@JsonKey(name: 'lastSeenAt') final  DateTime? lastConnected;
@override final  DateTime? activatedAt;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Toy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToyCopyWith<_Toy> get copyWith => __$ToyCopyWithImpl<_Toy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ToyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Toy&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.iotDeviceId, iotDeviceId) || other.iotDeviceId == iotDeviceId)&&(identical(other.iotDeviceStatus, iotDeviceStatus) || other.iotDeviceStatus == iotDeviceStatus)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.model, model) || other.model == model)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.firmwareVersion, firmwareVersion) || other.firmwareVersion == firmwareVersion)&&const DeepCollectionEquality().equals(other._capabilities, _capabilities)&&const DeepCollectionEquality().equals(other._settings, _settings)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.personalityProfile, personalityProfile) || other.personalityProfile == personalityProfile)&&(identical(other.customPersonalityId, customPersonalityId) || other.customPersonalityId == customPersonalityId)&&(identical(other.greeting, greeting) || other.greeting == greeting)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.signalStrength, signalStrength) || other.signalStrength == signalStrength)&&(identical(other.lastConnected, lastConnected) || other.lastConnected == lastConnected)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,status,iotDeviceId,iotDeviceStatus,userId,ownerId,model,manufacturer,firmwareVersion,const DeepCollectionEquality().hash(_capabilities),const DeepCollectionEquality().hash(_settings),notes,prompt,personalityProfile,customPersonalityId,greeting,batteryLevel,signalStrength,lastConnected,activatedAt,createdAt,updatedAt]);

@override
String toString() {
  return 'Toy(id: $id, name: $name, status: $status, iotDeviceId: $iotDeviceId, iotDeviceStatus: $iotDeviceStatus, userId: $userId, ownerId: $ownerId, model: $model, manufacturer: $manufacturer, firmwareVersion: $firmwareVersion, capabilities: $capabilities, settings: $settings, notes: $notes, prompt: $prompt, personalityProfile: $personalityProfile, customPersonalityId: $customPersonalityId, greeting: $greeting, batteryLevel: $batteryLevel, signalStrength: $signalStrength, lastConnected: $lastConnected, activatedAt: $activatedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ToyCopyWith<$Res> implements $ToyCopyWith<$Res> {
  factory _$ToyCopyWith(_Toy value, $Res Function(_Toy) _then) = __$ToyCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, ToyStatus status, String? iotDeviceId, String? iotDeviceStatus, String? userId, String? ownerId, String? model, String? manufacturer, String? firmwareVersion, Map<String, dynamic>? capabilities, Map<String, dynamic>? settings, String? notes, String? prompt, String? personalityProfile, String? customPersonalityId, String? greeting, String? batteryLevel, String? signalStrength,@JsonKey(name: 'lastSeenAt') DateTime? lastConnected, DateTime? activatedAt, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ToyCopyWithImpl<$Res>
    implements _$ToyCopyWith<$Res> {
  __$ToyCopyWithImpl(this._self, this._then);

  final _Toy _self;
  final $Res Function(_Toy) _then;

/// Create a copy of Toy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? status = null,Object? iotDeviceId = freezed,Object? iotDeviceStatus = freezed,Object? userId = freezed,Object? ownerId = freezed,Object? model = freezed,Object? manufacturer = freezed,Object? firmwareVersion = freezed,Object? capabilities = freezed,Object? settings = freezed,Object? notes = freezed,Object? prompt = freezed,Object? personalityProfile = freezed,Object? customPersonalityId = freezed,Object? greeting = freezed,Object? batteryLevel = freezed,Object? signalStrength = freezed,Object? lastConnected = freezed,Object? activatedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Toy(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ToyStatus,iotDeviceId: freezed == iotDeviceId ? _self.iotDeviceId : iotDeviceId // ignore: cast_nullable_to_non_nullable
as String?,iotDeviceStatus: freezed == iotDeviceStatus ? _self.iotDeviceStatus : iotDeviceStatus // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,firmwareVersion: freezed == firmwareVersion ? _self.firmwareVersion : firmwareVersion // ignore: cast_nullable_to_non_nullable
as String?,capabilities: freezed == capabilities ? _self._capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,settings: freezed == settings ? _self._settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,prompt: freezed == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String?,personalityProfile: freezed == personalityProfile ? _self.personalityProfile : personalityProfile // ignore: cast_nullable_to_non_nullable
as String?,customPersonalityId: freezed == customPersonalityId ? _self.customPersonalityId : customPersonalityId // ignore: cast_nullable_to_non_nullable
as String?,greeting: freezed == greeting ? _self.greeting : greeting // ignore: cast_nullable_to_non_nullable
as String?,batteryLevel: freezed == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as String?,signalStrength: freezed == signalStrength ? _self.signalStrength : signalStrength // ignore: cast_nullable_to_non_nullable
as String?,lastConnected: freezed == lastConnected ? _self.lastConnected : lastConnected // ignore: cast_nullable_to_non_nullable
as DateTime?,activatedAt: freezed == activatedAt ? _self.activatedAt : activatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CreateToyRequest {

 String get name; String? get deviceId; String? get macAddress; String? get model; String? get manufacturer; ToyStatus? get status; String? get firmwareVersion; Map<String, dynamic>? get capabilities; Map<String, dynamic>? get settings; String? get notes; String? get prompt; String? get personalityProfile; String? get customPersonalityId; String? get greeting;
/// Create a copy of CreateToyRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateToyRequestCopyWith<CreateToyRequest> get copyWith => _$CreateToyRequestCopyWithImpl<CreateToyRequest>(this as CreateToyRequest, _$identity);

  /// Serializes this CreateToyRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateToyRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.macAddress, macAddress) || other.macAddress == macAddress)&&(identical(other.model, model) || other.model == model)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.status, status) || other.status == status)&&(identical(other.firmwareVersion, firmwareVersion) || other.firmwareVersion == firmwareVersion)&&const DeepCollectionEquality().equals(other.capabilities, capabilities)&&const DeepCollectionEquality().equals(other.settings, settings)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.personalityProfile, personalityProfile) || other.personalityProfile == personalityProfile)&&(identical(other.customPersonalityId, customPersonalityId) || other.customPersonalityId == customPersonalityId)&&(identical(other.greeting, greeting) || other.greeting == greeting));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,deviceId,macAddress,model,manufacturer,status,firmwareVersion,const DeepCollectionEquality().hash(capabilities),const DeepCollectionEquality().hash(settings),notes,prompt,personalityProfile,customPersonalityId,greeting);

@override
String toString() {
  return 'CreateToyRequest(name: $name, deviceId: $deviceId, macAddress: $macAddress, model: $model, manufacturer: $manufacturer, status: $status, firmwareVersion: $firmwareVersion, capabilities: $capabilities, settings: $settings, notes: $notes, prompt: $prompt, personalityProfile: $personalityProfile, customPersonalityId: $customPersonalityId, greeting: $greeting)';
}


}

/// @nodoc
abstract mixin class $CreateToyRequestCopyWith<$Res>  {
  factory $CreateToyRequestCopyWith(CreateToyRequest value, $Res Function(CreateToyRequest) _then) = _$CreateToyRequestCopyWithImpl;
@useResult
$Res call({
 String name, String? deviceId, String? macAddress, String? model, String? manufacturer, ToyStatus? status, String? firmwareVersion, Map<String, dynamic>? capabilities, Map<String, dynamic>? settings, String? notes, String? prompt, String? personalityProfile, String? customPersonalityId, String? greeting
});




}
/// @nodoc
class _$CreateToyRequestCopyWithImpl<$Res>
    implements $CreateToyRequestCopyWith<$Res> {
  _$CreateToyRequestCopyWithImpl(this._self, this._then);

  final CreateToyRequest _self;
  final $Res Function(CreateToyRequest) _then;

/// Create a copy of CreateToyRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? deviceId = freezed,Object? macAddress = freezed,Object? model = freezed,Object? manufacturer = freezed,Object? status = freezed,Object? firmwareVersion = freezed,Object? capabilities = freezed,Object? settings = freezed,Object? notes = freezed,Object? prompt = freezed,Object? personalityProfile = freezed,Object? customPersonalityId = freezed,Object? greeting = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,macAddress: freezed == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ToyStatus?,firmwareVersion: freezed == firmwareVersion ? _self.firmwareVersion : firmwareVersion // ignore: cast_nullable_to_non_nullable
as String?,capabilities: freezed == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,prompt: freezed == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String?,personalityProfile: freezed == personalityProfile ? _self.personalityProfile : personalityProfile // ignore: cast_nullable_to_non_nullable
as String?,customPersonalityId: freezed == customPersonalityId ? _self.customPersonalityId : customPersonalityId // ignore: cast_nullable_to_non_nullable
as String?,greeting: freezed == greeting ? _self.greeting : greeting // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateToyRequest].
extension CreateToyRequestPatterns on CreateToyRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateToyRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateToyRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateToyRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateToyRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateToyRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateToyRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? deviceId,  String? macAddress,  String? model,  String? manufacturer,  ToyStatus? status,  String? firmwareVersion,  Map<String, dynamic>? capabilities,  Map<String, dynamic>? settings,  String? notes,  String? prompt,  String? personalityProfile,  String? customPersonalityId,  String? greeting)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateToyRequest() when $default != null:
return $default(_that.name,_that.deviceId,_that.macAddress,_that.model,_that.manufacturer,_that.status,_that.firmwareVersion,_that.capabilities,_that.settings,_that.notes,_that.prompt,_that.personalityProfile,_that.customPersonalityId,_that.greeting);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? deviceId,  String? macAddress,  String? model,  String? manufacturer,  ToyStatus? status,  String? firmwareVersion,  Map<String, dynamic>? capabilities,  Map<String, dynamic>? settings,  String? notes,  String? prompt,  String? personalityProfile,  String? customPersonalityId,  String? greeting)  $default,) {final _that = this;
switch (_that) {
case _CreateToyRequest():
return $default(_that.name,_that.deviceId,_that.macAddress,_that.model,_that.manufacturer,_that.status,_that.firmwareVersion,_that.capabilities,_that.settings,_that.notes,_that.prompt,_that.personalityProfile,_that.customPersonalityId,_that.greeting);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? deviceId,  String? macAddress,  String? model,  String? manufacturer,  ToyStatus? status,  String? firmwareVersion,  Map<String, dynamic>? capabilities,  Map<String, dynamic>? settings,  String? notes,  String? prompt,  String? personalityProfile,  String? customPersonalityId,  String? greeting)?  $default,) {final _that = this;
switch (_that) {
case _CreateToyRequest() when $default != null:
return $default(_that.name,_that.deviceId,_that.macAddress,_that.model,_that.manufacturer,_that.status,_that.firmwareVersion,_that.capabilities,_that.settings,_that.notes,_that.prompt,_that.personalityProfile,_that.customPersonalityId,_that.greeting);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateToyRequest implements CreateToyRequest {
  const _CreateToyRequest({required this.name, this.deviceId, this.macAddress, this.model, this.manufacturer, this.status, this.firmwareVersion, final  Map<String, dynamic>? capabilities, final  Map<String, dynamic>? settings, this.notes, this.prompt, this.personalityProfile, this.customPersonalityId, this.greeting}): _capabilities = capabilities,_settings = settings;
  factory _CreateToyRequest.fromJson(Map<String, dynamic> json) => _$CreateToyRequestFromJson(json);

@override final  String name;
@override final  String? deviceId;
@override final  String? macAddress;
@override final  String? model;
@override final  String? manufacturer;
@override final  ToyStatus? status;
@override final  String? firmwareVersion;
 final  Map<String, dynamic>? _capabilities;
@override Map<String, dynamic>? get capabilities {
  final value = _capabilities;
  if (value == null) return null;
  if (_capabilities is EqualUnmodifiableMapView) return _capabilities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _settings;
@override Map<String, dynamic>? get settings {
  final value = _settings;
  if (value == null) return null;
  if (_settings is EqualUnmodifiableMapView) return _settings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? notes;
@override final  String? prompt;
@override final  String? personalityProfile;
@override final  String? customPersonalityId;
@override final  String? greeting;

/// Create a copy of CreateToyRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateToyRequestCopyWith<_CreateToyRequest> get copyWith => __$CreateToyRequestCopyWithImpl<_CreateToyRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateToyRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateToyRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.macAddress, macAddress) || other.macAddress == macAddress)&&(identical(other.model, model) || other.model == model)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.status, status) || other.status == status)&&(identical(other.firmwareVersion, firmwareVersion) || other.firmwareVersion == firmwareVersion)&&const DeepCollectionEquality().equals(other._capabilities, _capabilities)&&const DeepCollectionEquality().equals(other._settings, _settings)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.personalityProfile, personalityProfile) || other.personalityProfile == personalityProfile)&&(identical(other.customPersonalityId, customPersonalityId) || other.customPersonalityId == customPersonalityId)&&(identical(other.greeting, greeting) || other.greeting == greeting));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,deviceId,macAddress,model,manufacturer,status,firmwareVersion,const DeepCollectionEquality().hash(_capabilities),const DeepCollectionEquality().hash(_settings),notes,prompt,personalityProfile,customPersonalityId,greeting);

@override
String toString() {
  return 'CreateToyRequest(name: $name, deviceId: $deviceId, macAddress: $macAddress, model: $model, manufacturer: $manufacturer, status: $status, firmwareVersion: $firmwareVersion, capabilities: $capabilities, settings: $settings, notes: $notes, prompt: $prompt, personalityProfile: $personalityProfile, customPersonalityId: $customPersonalityId, greeting: $greeting)';
}


}

/// @nodoc
abstract mixin class _$CreateToyRequestCopyWith<$Res> implements $CreateToyRequestCopyWith<$Res> {
  factory _$CreateToyRequestCopyWith(_CreateToyRequest value, $Res Function(_CreateToyRequest) _then) = __$CreateToyRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, String? deviceId, String? macAddress, String? model, String? manufacturer, ToyStatus? status, String? firmwareVersion, Map<String, dynamic>? capabilities, Map<String, dynamic>? settings, String? notes, String? prompt, String? personalityProfile, String? customPersonalityId, String? greeting
});




}
/// @nodoc
class __$CreateToyRequestCopyWithImpl<$Res>
    implements _$CreateToyRequestCopyWith<$Res> {
  __$CreateToyRequestCopyWithImpl(this._self, this._then);

  final _CreateToyRequest _self;
  final $Res Function(_CreateToyRequest) _then;

/// Create a copy of CreateToyRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? deviceId = freezed,Object? macAddress = freezed,Object? model = freezed,Object? manufacturer = freezed,Object? status = freezed,Object? firmwareVersion = freezed,Object? capabilities = freezed,Object? settings = freezed,Object? notes = freezed,Object? prompt = freezed,Object? personalityProfile = freezed,Object? customPersonalityId = freezed,Object? greeting = freezed,}) {
  return _then(_CreateToyRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,macAddress: freezed == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ToyStatus?,firmwareVersion: freezed == firmwareVersion ? _self.firmwareVersion : firmwareVersion // ignore: cast_nullable_to_non_nullable
as String?,capabilities: freezed == capabilities ? _self._capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,settings: freezed == settings ? _self._settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,prompt: freezed == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String?,personalityProfile: freezed == personalityProfile ? _self.personalityProfile : personalityProfile // ignore: cast_nullable_to_non_nullable
as String?,customPersonalityId: freezed == customPersonalityId ? _self.customPersonalityId : customPersonalityId // ignore: cast_nullable_to_non_nullable
as String?,greeting: freezed == greeting ? _self.greeting : greeting // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AssignToyRequest {

 String get userId; String? get macAddress; String? get deviceId; String? get toyName;
/// Create a copy of AssignToyRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignToyRequestCopyWith<AssignToyRequest> get copyWith => _$AssignToyRequestCopyWithImpl<AssignToyRequest>(this as AssignToyRequest, _$identity);

  /// Serializes this AssignToyRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignToyRequest&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.macAddress, macAddress) || other.macAddress == macAddress)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.toyName, toyName) || other.toyName == toyName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,macAddress,deviceId,toyName);

@override
String toString() {
  return 'AssignToyRequest(userId: $userId, macAddress: $macAddress, deviceId: $deviceId, toyName: $toyName)';
}


}

/// @nodoc
abstract mixin class $AssignToyRequestCopyWith<$Res>  {
  factory $AssignToyRequestCopyWith(AssignToyRequest value, $Res Function(AssignToyRequest) _then) = _$AssignToyRequestCopyWithImpl;
@useResult
$Res call({
 String userId, String? macAddress, String? deviceId, String? toyName
});




}
/// @nodoc
class _$AssignToyRequestCopyWithImpl<$Res>
    implements $AssignToyRequestCopyWith<$Res> {
  _$AssignToyRequestCopyWithImpl(this._self, this._then);

  final AssignToyRequest _self;
  final $Res Function(AssignToyRequest) _then;

/// Create a copy of AssignToyRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? macAddress = freezed,Object? deviceId = freezed,Object? toyName = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,macAddress: freezed == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,toyName: freezed == toyName ? _self.toyName : toyName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssignToyRequest].
extension AssignToyRequestPatterns on AssignToyRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssignToyRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssignToyRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssignToyRequest value)  $default,){
final _that = this;
switch (_that) {
case _AssignToyRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssignToyRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AssignToyRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String? macAddress,  String? deviceId,  String? toyName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssignToyRequest() when $default != null:
return $default(_that.userId,_that.macAddress,_that.deviceId,_that.toyName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String? macAddress,  String? deviceId,  String? toyName)  $default,) {final _that = this;
switch (_that) {
case _AssignToyRequest():
return $default(_that.userId,_that.macAddress,_that.deviceId,_that.toyName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String? macAddress,  String? deviceId,  String? toyName)?  $default,) {final _that = this;
switch (_that) {
case _AssignToyRequest() when $default != null:
return $default(_that.userId,_that.macAddress,_that.deviceId,_that.toyName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssignToyRequest implements AssignToyRequest {
  const _AssignToyRequest({required this.userId, this.macAddress, this.deviceId, this.toyName});
  factory _AssignToyRequest.fromJson(Map<String, dynamic> json) => _$AssignToyRequestFromJson(json);

@override final  String userId;
@override final  String? macAddress;
@override final  String? deviceId;
@override final  String? toyName;

/// Create a copy of AssignToyRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignToyRequestCopyWith<_AssignToyRequest> get copyWith => __$AssignToyRequestCopyWithImpl<_AssignToyRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignToyRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssignToyRequest&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.macAddress, macAddress) || other.macAddress == macAddress)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.toyName, toyName) || other.toyName == toyName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,macAddress,deviceId,toyName);

@override
String toString() {
  return 'AssignToyRequest(userId: $userId, macAddress: $macAddress, deviceId: $deviceId, toyName: $toyName)';
}


}

/// @nodoc
abstract mixin class _$AssignToyRequestCopyWith<$Res> implements $AssignToyRequestCopyWith<$Res> {
  factory _$AssignToyRequestCopyWith(_AssignToyRequest value, $Res Function(_AssignToyRequest) _then) = __$AssignToyRequestCopyWithImpl;
@override @useResult
$Res call({
 String userId, String? macAddress, String? deviceId, String? toyName
});




}
/// @nodoc
class __$AssignToyRequestCopyWithImpl<$Res>
    implements _$AssignToyRequestCopyWith<$Res> {
  __$AssignToyRequestCopyWithImpl(this._self, this._then);

  final _AssignToyRequest _self;
  final $Res Function(_AssignToyRequest) _then;

/// Create a copy of AssignToyRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? macAddress = freezed,Object? deviceId = freezed,Object? toyName = freezed,}) {
  return _then(_AssignToyRequest(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,macAddress: freezed == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,toyName: freezed == toyName ? _self.toyName : toyName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AssignToyResponse {

 bool get success; String? get message; Toy? get toy;
/// Create a copy of AssignToyResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignToyResponseCopyWith<AssignToyResponse> get copyWith => _$AssignToyResponseCopyWithImpl<AssignToyResponse>(this as AssignToyResponse, _$identity);

  /// Serializes this AssignToyResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignToyResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&(identical(other.toy, toy) || other.toy == toy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message,toy);

@override
String toString() {
  return 'AssignToyResponse(success: $success, message: $message, toy: $toy)';
}


}

/// @nodoc
abstract mixin class $AssignToyResponseCopyWith<$Res>  {
  factory $AssignToyResponseCopyWith(AssignToyResponse value, $Res Function(AssignToyResponse) _then) = _$AssignToyResponseCopyWithImpl;
@useResult
$Res call({
 bool success, String? message, Toy? toy
});


$ToyCopyWith<$Res>? get toy;

}
/// @nodoc
class _$AssignToyResponseCopyWithImpl<$Res>
    implements $AssignToyResponseCopyWith<$Res> {
  _$AssignToyResponseCopyWithImpl(this._self, this._then);

  final AssignToyResponse _self;
  final $Res Function(AssignToyResponse) _then;

/// Create a copy of AssignToyResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? message = freezed,Object? toy = freezed,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,toy: freezed == toy ? _self.toy : toy // ignore: cast_nullable_to_non_nullable
as Toy?,
  ));
}
/// Create a copy of AssignToyResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToyCopyWith<$Res>? get toy {
    if (_self.toy == null) {
    return null;
  }

  return $ToyCopyWith<$Res>(_self.toy!, (value) {
    return _then(_self.copyWith(toy: value));
  });
}
}


/// Adds pattern-matching-related methods to [AssignToyResponse].
extension AssignToyResponsePatterns on AssignToyResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssignToyResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssignToyResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssignToyResponse value)  $default,){
final _that = this;
switch (_that) {
case _AssignToyResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssignToyResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AssignToyResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  String? message,  Toy? toy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssignToyResponse() when $default != null:
return $default(_that.success,_that.message,_that.toy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  String? message,  Toy? toy)  $default,) {final _that = this;
switch (_that) {
case _AssignToyResponse():
return $default(_that.success,_that.message,_that.toy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  String? message,  Toy? toy)?  $default,) {final _that = this;
switch (_that) {
case _AssignToyResponse() when $default != null:
return $default(_that.success,_that.message,_that.toy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssignToyResponse implements AssignToyResponse {
  const _AssignToyResponse({required this.success, this.message, this.toy});
  factory _AssignToyResponse.fromJson(Map<String, dynamic> json) => _$AssignToyResponseFromJson(json);

@override final  bool success;
@override final  String? message;
@override final  Toy? toy;

/// Create a copy of AssignToyResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignToyResponseCopyWith<_AssignToyResponse> get copyWith => __$AssignToyResponseCopyWithImpl<_AssignToyResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignToyResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssignToyResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&(identical(other.toy, toy) || other.toy == toy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message,toy);

@override
String toString() {
  return 'AssignToyResponse(success: $success, message: $message, toy: $toy)';
}


}

/// @nodoc
abstract mixin class _$AssignToyResponseCopyWith<$Res> implements $AssignToyResponseCopyWith<$Res> {
  factory _$AssignToyResponseCopyWith(_AssignToyResponse value, $Res Function(_AssignToyResponse) _then) = __$AssignToyResponseCopyWithImpl;
@override @useResult
$Res call({
 bool success, String? message, Toy? toy
});


@override $ToyCopyWith<$Res>? get toy;

}
/// @nodoc
class __$AssignToyResponseCopyWithImpl<$Res>
    implements _$AssignToyResponseCopyWith<$Res> {
  __$AssignToyResponseCopyWithImpl(this._self, this._then);

  final _AssignToyResponse _self;
  final $Res Function(_AssignToyResponse) _then;

/// Create a copy of AssignToyResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? message = freezed,Object? toy = freezed,}) {
  return _then(_AssignToyResponse(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,toy: freezed == toy ? _self.toy : toy // ignore: cast_nullable_to_non_nullable
as Toy?,
  ));
}

/// Create a copy of AssignToyResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToyCopyWith<$Res>? get toy {
    if (_self.toy == null) {
    return null;
  }

  return $ToyCopyWith<$Res>(_self.toy!, (value) {
    return _then(_self.copyWith(toy: value));
  });
}
}


/// @nodoc
mixin _$UpdateToyStatusRequest {

 ToyStatus get status; String? get batteryLevel; String? get signalStrength;
/// Create a copy of UpdateToyStatusRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateToyStatusRequestCopyWith<UpdateToyStatusRequest> get copyWith => _$UpdateToyStatusRequestCopyWithImpl<UpdateToyStatusRequest>(this as UpdateToyStatusRequest, _$identity);

  /// Serializes this UpdateToyStatusRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateToyStatusRequest&&(identical(other.status, status) || other.status == status)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.signalStrength, signalStrength) || other.signalStrength == signalStrength));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,batteryLevel,signalStrength);

@override
String toString() {
  return 'UpdateToyStatusRequest(status: $status, batteryLevel: $batteryLevel, signalStrength: $signalStrength)';
}


}

/// @nodoc
abstract mixin class $UpdateToyStatusRequestCopyWith<$Res>  {
  factory $UpdateToyStatusRequestCopyWith(UpdateToyStatusRequest value, $Res Function(UpdateToyStatusRequest) _then) = _$UpdateToyStatusRequestCopyWithImpl;
@useResult
$Res call({
 ToyStatus status, String? batteryLevel, String? signalStrength
});




}
/// @nodoc
class _$UpdateToyStatusRequestCopyWithImpl<$Res>
    implements $UpdateToyStatusRequestCopyWith<$Res> {
  _$UpdateToyStatusRequestCopyWithImpl(this._self, this._then);

  final UpdateToyStatusRequest _self;
  final $Res Function(UpdateToyStatusRequest) _then;

/// Create a copy of UpdateToyStatusRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? batteryLevel = freezed,Object? signalStrength = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ToyStatus,batteryLevel: freezed == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as String?,signalStrength: freezed == signalStrength ? _self.signalStrength : signalStrength // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateToyStatusRequest].
extension UpdateToyStatusRequestPatterns on UpdateToyStatusRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateToyStatusRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateToyStatusRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateToyStatusRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateToyStatusRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateToyStatusRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateToyStatusRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ToyStatus status,  String? batteryLevel,  String? signalStrength)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateToyStatusRequest() when $default != null:
return $default(_that.status,_that.batteryLevel,_that.signalStrength);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ToyStatus status,  String? batteryLevel,  String? signalStrength)  $default,) {final _that = this;
switch (_that) {
case _UpdateToyStatusRequest():
return $default(_that.status,_that.batteryLevel,_that.signalStrength);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ToyStatus status,  String? batteryLevel,  String? signalStrength)?  $default,) {final _that = this;
switch (_that) {
case _UpdateToyStatusRequest() when $default != null:
return $default(_that.status,_that.batteryLevel,_that.signalStrength);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateToyStatusRequest implements UpdateToyStatusRequest {
  const _UpdateToyStatusRequest({required this.status, this.batteryLevel, this.signalStrength});
  factory _UpdateToyStatusRequest.fromJson(Map<String, dynamic> json) => _$UpdateToyStatusRequestFromJson(json);

@override final  ToyStatus status;
@override final  String? batteryLevel;
@override final  String? signalStrength;

/// Create a copy of UpdateToyStatusRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateToyStatusRequestCopyWith<_UpdateToyStatusRequest> get copyWith => __$UpdateToyStatusRequestCopyWithImpl<_UpdateToyStatusRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateToyStatusRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateToyStatusRequest&&(identical(other.status, status) || other.status == status)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.signalStrength, signalStrength) || other.signalStrength == signalStrength));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,batteryLevel,signalStrength);

@override
String toString() {
  return 'UpdateToyStatusRequest(status: $status, batteryLevel: $batteryLevel, signalStrength: $signalStrength)';
}


}

/// @nodoc
abstract mixin class _$UpdateToyStatusRequestCopyWith<$Res> implements $UpdateToyStatusRequestCopyWith<$Res> {
  factory _$UpdateToyStatusRequestCopyWith(_UpdateToyStatusRequest value, $Res Function(_UpdateToyStatusRequest) _then) = __$UpdateToyStatusRequestCopyWithImpl;
@override @useResult
$Res call({
 ToyStatus status, String? batteryLevel, String? signalStrength
});




}
/// @nodoc
class __$UpdateToyStatusRequestCopyWithImpl<$Res>
    implements _$UpdateToyStatusRequestCopyWith<$Res> {
  __$UpdateToyStatusRequestCopyWithImpl(this._self, this._then);

  final _UpdateToyStatusRequest _self;
  final $Res Function(_UpdateToyStatusRequest) _then;

/// Create a copy of UpdateToyStatusRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? batteryLevel = freezed,Object? signalStrength = freezed,}) {
  return _then(_UpdateToyStatusRequest(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ToyStatus,batteryLevel: freezed == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as String?,signalStrength: freezed == signalStrength ? _self.signalStrength : signalStrength // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
