import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? firstName,
    String? lastName,
    String? username,
    String? avatar,
    String? role,
    String? status,
    bool? emailVerified,
    String? preferredLanguage,
    DateTime? createdAt,
    String? fullName,
  }) = _User;
  const User._();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // Getter para compatibilidad con código existente
  String? get name {
    // Try username first
    if (username != null && username!.isNotEmpty) {
      return username;
    }

    // Try fullName (skip if it's "Unknown")
    if (fullName != null && fullName!.isNotEmpty && fullName != 'Unknown') {
      return fullName;
    }

    // Try firstName + lastName
    if (firstName != null || lastName != null) {
      final combined = '${firstName ?? ''} ${lastName ?? ''}'.trim();
      if (combined.isNotEmpty) {
        return combined;
      }
    }

    // Last resort: use email prefix
    if (email.isNotEmpty) {
      return email.split('@').first;
    }

    return null;
  }
}

@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}

@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required bool success,
    User? user,
    AuthTokens? tokens,
    String? error,
    int? expiresIn,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  // Método helper para crear desde respuesta del backend NestJS
  factory AuthResponse.fromBackend(Map<String, dynamic> json) {
    if (json.containsKey('accessToken')) {
      return AuthResponse(
        success: true,
        user: json['user'] != null
            ? User.fromJson(json['user'] as Map<String, dynamic>)
            : null,
        tokens: AuthTokens(
          accessToken: json['accessToken'] as String,
          refreshToken: json['refreshToken'] as String,
        ),
        expiresIn: json['expiresIn'] as int?,
      );
    }
    return AuthResponse.fromJson(json);
  }
}

@freezed
abstract class SocialAuthResult with _$SocialAuthResult {
  const factory SocialAuthResult({
    required bool success,
    User? user,
    AuthTokens? tokens,
    String? error,
    Object? appleCredential,
  }) = _SocialAuthResult;

  factory SocialAuthResult.fromJson(Map<String, dynamic> json) =>
      _$SocialAuthResultFromJson(json);

  // Método helper para crear desde respuesta del backend NestJS
  factory SocialAuthResult.fromBackend(Map<String, dynamic> json) {
    if (json.containsKey('accessToken')) {
      return SocialAuthResult(
        success: true,
        user: json['user'] != null
            ? User.fromJson(json['user'] as Map<String, dynamic>)
            : null,
        tokens: AuthTokens(
          accessToken: json['accessToken'] as String,
          refreshToken: json['refreshToken'] as String,
        ),
      );
    }
    return SocialAuthResult.fromJson(json);
  }
}
