import 'package:freezed_annotation/freezed_annotation.dart';

part 'person.freezed.dart';
part 'person.g.dart';

@freezed
abstract class Person with _$Person {
  const factory Person({
    required String id,
    String? givenName,
    String? familyName,
    String? gender,
    DateTime? birthDate,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Person;

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
}
