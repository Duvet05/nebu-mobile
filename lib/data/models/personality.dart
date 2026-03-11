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

extension PersonalityListX on List<Personality> {
  /// Extracts unique categories from the personality list, sorted.
  List<String> get uniqueCategories =>
      map((p) => p.category?.toLowerCase()).whereType<String>().toSet().toList()
        ..sort();
}
