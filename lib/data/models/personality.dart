import 'package:freezed_annotation/freezed_annotation.dart';

part 'personality.freezed.dart';
part 'personality.g.dart';

@freezed
abstract class PersonalitySettings with _$PersonalitySettings {
  const factory PersonalitySettings({
    String? voice,
    double? speed,
    String? language,
    String? style,
  }) = _PersonalitySettings;

  factory PersonalitySettings.fromJson(Map<String, dynamic> json) =>
      _$PersonalitySettingsFromJson(json);
}

@freezed
abstract class Personality with _$Personality {
  const factory Personality({
    required String id,
    @JsonKey(name: 'display_name') required String name,
    required String description,
    String? prompt,
    String? greeting,
    String? category,
    PersonalitySettings? settings,
    String? imageUrl,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Personality;

  factory Personality.fromJson(Map<String, dynamic> json) =>
      _$PersonalityFromJson(json);
}

abstract final class PersonalityCategories {
  static const all = 'all';
  static const educativo = 'educativo';
  static const entretenimiento = 'entretenimiento';
  static const companero = 'companero';
  static const creativo = 'creativo';
  static const aventura = 'aventura';
  static const bienestar = 'bienestar';
  static const values = [
    all,
    educativo,
    entretenimiento,
    companero,
    creativo,
    aventura,
    bienestar,
  ];
}
