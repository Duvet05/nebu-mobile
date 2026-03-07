// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'personality.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PersonalitySettings {

 String? get voice; double? get speed; String? get language; String? get style;
/// Create a copy of PersonalitySettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonalitySettingsCopyWith<PersonalitySettings> get copyWith => _$PersonalitySettingsCopyWithImpl<PersonalitySettings>(this as PersonalitySettings, _$identity);

  /// Serializes this PersonalitySettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonalitySettings&&(identical(other.voice, voice) || other.voice == voice)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.language, language) || other.language == language)&&(identical(other.style, style) || other.style == style));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,voice,speed,language,style);

@override
String toString() {
  return 'PersonalitySettings(voice: $voice, speed: $speed, language: $language, style: $style)';
}


}

/// @nodoc
abstract mixin class $PersonalitySettingsCopyWith<$Res>  {
  factory $PersonalitySettingsCopyWith(PersonalitySettings value, $Res Function(PersonalitySettings) _then) = _$PersonalitySettingsCopyWithImpl;
@useResult
$Res call({
 String? voice, double? speed, String? language, String? style
});




}
/// @nodoc
class _$PersonalitySettingsCopyWithImpl<$Res>
    implements $PersonalitySettingsCopyWith<$Res> {
  _$PersonalitySettingsCopyWithImpl(this._self, this._then);

  final PersonalitySettings _self;
  final $Res Function(PersonalitySettings) _then;

/// Create a copy of PersonalitySettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? voice = freezed,Object? speed = freezed,Object? language = freezed,Object? style = freezed,}) {
  return _then(_self.copyWith(
voice: freezed == voice ? _self.voice : voice // ignore: cast_nullable_to_non_nullable
as String?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonalitySettings].
extension PersonalitySettingsPatterns on PersonalitySettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonalitySettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonalitySettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonalitySettings value)  $default,){
final _that = this;
switch (_that) {
case _PersonalitySettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonalitySettings value)?  $default,){
final _that = this;
switch (_that) {
case _PersonalitySettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? voice,  double? speed,  String? language,  String? style)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonalitySettings() when $default != null:
return $default(_that.voice,_that.speed,_that.language,_that.style);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? voice,  double? speed,  String? language,  String? style)  $default,) {final _that = this;
switch (_that) {
case _PersonalitySettings():
return $default(_that.voice,_that.speed,_that.language,_that.style);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? voice,  double? speed,  String? language,  String? style)?  $default,) {final _that = this;
switch (_that) {
case _PersonalitySettings() when $default != null:
return $default(_that.voice,_that.speed,_that.language,_that.style);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PersonalitySettings implements PersonalitySettings {
  const _PersonalitySettings({this.voice, this.speed, this.language, this.style});
  factory _PersonalitySettings.fromJson(Map<String, dynamic> json) => _$PersonalitySettingsFromJson(json);

@override final  String? voice;
@override final  double? speed;
@override final  String? language;
@override final  String? style;

/// Create a copy of PersonalitySettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonalitySettingsCopyWith<_PersonalitySettings> get copyWith => __$PersonalitySettingsCopyWithImpl<_PersonalitySettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonalitySettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonalitySettings&&(identical(other.voice, voice) || other.voice == voice)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.language, language) || other.language == language)&&(identical(other.style, style) || other.style == style));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,voice,speed,language,style);

@override
String toString() {
  return 'PersonalitySettings(voice: $voice, speed: $speed, language: $language, style: $style)';
}


}

/// @nodoc
abstract mixin class _$PersonalitySettingsCopyWith<$Res> implements $PersonalitySettingsCopyWith<$Res> {
  factory _$PersonalitySettingsCopyWith(_PersonalitySettings value, $Res Function(_PersonalitySettings) _then) = __$PersonalitySettingsCopyWithImpl;
@override @useResult
$Res call({
 String? voice, double? speed, String? language, String? style
});




}
/// @nodoc
class __$PersonalitySettingsCopyWithImpl<$Res>
    implements _$PersonalitySettingsCopyWith<$Res> {
  __$PersonalitySettingsCopyWithImpl(this._self, this._then);

  final _PersonalitySettings _self;
  final $Res Function(_PersonalitySettings) _then;

/// Create a copy of PersonalitySettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? voice = freezed,Object? speed = freezed,Object? language = freezed,Object? style = freezed,}) {
  return _then(_PersonalitySettings(
voice: freezed == voice ? _self.voice : voice // ignore: cast_nullable_to_non_nullable
as String?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Personality {

 String get id; String get name; String get description; String? get prompt; String? get greeting; String? get category; PersonalitySettings? get settings; String? get imageUrl; bool get isActive; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Personality
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonalityCopyWith<Personality> get copyWith => _$PersonalityCopyWithImpl<Personality>(this as Personality, _$identity);

  /// Serializes this Personality to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Personality&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.greeting, greeting) || other.greeting == greeting)&&(identical(other.category, category) || other.category == category)&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,prompt,greeting,category,settings,imageUrl,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'Personality(id: $id, name: $name, description: $description, prompt: $prompt, greeting: $greeting, category: $category, settings: $settings, imageUrl: $imageUrl, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PersonalityCopyWith<$Res>  {
  factory $PersonalityCopyWith(Personality value, $Res Function(Personality) _then) = _$PersonalityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String? prompt, String? greeting, String? category, PersonalitySettings? settings, String? imageUrl, bool isActive, DateTime? createdAt, DateTime? updatedAt
});


$PersonalitySettingsCopyWith<$Res>? get settings;

}
/// @nodoc
class _$PersonalityCopyWithImpl<$Res>
    implements $PersonalityCopyWith<$Res> {
  _$PersonalityCopyWithImpl(this._self, this._then);

  final Personality _self;
  final $Res Function(Personality) _then;

/// Create a copy of Personality
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? prompt = freezed,Object? greeting = freezed,Object? category = freezed,Object? settings = freezed,Object? imageUrl = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,prompt: freezed == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String?,greeting: freezed == greeting ? _self.greeting : greeting // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as PersonalitySettings?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Personality
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonalitySettingsCopyWith<$Res>? get settings {
    if (_self.settings == null) {
    return null;
  }

  return $PersonalitySettingsCopyWith<$Res>(_self.settings!, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// Adds pattern-matching-related methods to [Personality].
extension PersonalityPatterns on Personality {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Personality value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Personality() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Personality value)  $default,){
final _that = this;
switch (_that) {
case _Personality():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Personality value)?  $default,){
final _that = this;
switch (_that) {
case _Personality() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String? prompt,  String? greeting,  String? category,  PersonalitySettings? settings,  String? imageUrl,  bool isActive,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Personality() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.prompt,_that.greeting,_that.category,_that.settings,_that.imageUrl,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String? prompt,  String? greeting,  String? category,  PersonalitySettings? settings,  String? imageUrl,  bool isActive,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Personality():
return $default(_that.id,_that.name,_that.description,_that.prompt,_that.greeting,_that.category,_that.settings,_that.imageUrl,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String? prompt,  String? greeting,  String? category,  PersonalitySettings? settings,  String? imageUrl,  bool isActive,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Personality() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.prompt,_that.greeting,_that.category,_that.settings,_that.imageUrl,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Personality implements Personality {
  const _Personality({required this.id, required this.name, required this.description, this.prompt, this.greeting, this.category, this.settings, this.imageUrl, this.isActive = true, this.createdAt, this.updatedAt});
  factory _Personality.fromJson(Map<String, dynamic> json) => _$PersonalityFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String? prompt;
@override final  String? greeting;
@override final  String? category;
@override final  PersonalitySettings? settings;
@override final  String? imageUrl;
@override@JsonKey() final  bool isActive;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Personality
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonalityCopyWith<_Personality> get copyWith => __$PersonalityCopyWithImpl<_Personality>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonalityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Personality&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.greeting, greeting) || other.greeting == greeting)&&(identical(other.category, category) || other.category == category)&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,prompt,greeting,category,settings,imageUrl,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'Personality(id: $id, name: $name, description: $description, prompt: $prompt, greeting: $greeting, category: $category, settings: $settings, imageUrl: $imageUrl, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PersonalityCopyWith<$Res> implements $PersonalityCopyWith<$Res> {
  factory _$PersonalityCopyWith(_Personality value, $Res Function(_Personality) _then) = __$PersonalityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String? prompt, String? greeting, String? category, PersonalitySettings? settings, String? imageUrl, bool isActive, DateTime? createdAt, DateTime? updatedAt
});


@override $PersonalitySettingsCopyWith<$Res>? get settings;

}
/// @nodoc
class __$PersonalityCopyWithImpl<$Res>
    implements _$PersonalityCopyWith<$Res> {
  __$PersonalityCopyWithImpl(this._self, this._then);

  final _Personality _self;
  final $Res Function(_Personality) _then;

/// Create a copy of Personality
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? prompt = freezed,Object? greeting = freezed,Object? category = freezed,Object? settings = freezed,Object? imageUrl = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Personality(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,prompt: freezed == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String?,greeting: freezed == greeting ? _self.greeting : greeting // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as PersonalitySettings?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Personality
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonalitySettingsCopyWith<$Res>? get settings {
    if (_self.settings == null) {
    return null;
  }

  return $PersonalitySettingsCopyWith<$Res>(_self.settings!, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}

// dart format on
