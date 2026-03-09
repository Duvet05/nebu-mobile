// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personality.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PersonalitySettings _$PersonalitySettingsFromJson(Map<String, dynamic> json) =>
    _PersonalitySettings(
      voice: json['voice'] as String?,
      speed: (json['speed'] as num?)?.toDouble(),
      language: json['language'] as String?,
      style: json['style'] as String?,
    );

Map<String, dynamic> _$PersonalitySettingsToJson(
  _PersonalitySettings instance,
) => <String, dynamic>{
  'voice': instance.voice,
  'speed': instance.speed,
  'language': instance.language,
  'style': instance.style,
};

_Personality _$PersonalityFromJson(Map<String, dynamic> json) => _Personality(
  id: json['id'] as String,
  name: json['display_name'] as String,
  description: json['description'] as String,
  prompt: json['prompt'] as String?,
  greeting: json['greeting'] as String?,
  category: json['category'] as String?,
  settings: json['settings'] == null
      ? null
      : PersonalitySettings.fromJson(json['settings'] as Map<String, dynamic>),
  imageUrl: json['imageUrl'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PersonalityToJson(_Personality instance) =>
    <String, dynamic>{
      'id': instance.id,
      'display_name': instance.name,
      'description': instance.description,
      'prompt': instance.prompt,
      'greeting': instance.greeting,
      'category': instance.category,
      'settings': instance.settings,
      'imageUrl': instance.imageUrl,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
