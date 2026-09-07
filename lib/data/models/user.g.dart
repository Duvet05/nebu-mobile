// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  username: json['username'] as String?,
  avatar: json['avatar'] as String?,
  role: json['role'] as String?,
  status: json['status'] as String?,
  emailVerified: json['emailVerified'] as bool?,
  requiresPasswordForDeletion:
      json['requiresPasswordForDeletion'] as bool? ?? true,
  preferredLanguage: json['preferredLanguage'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  fullName: json['fullName'] as String?,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'username': instance.username,
  'avatar': instance.avatar,
  'role': instance.role,
  'status': instance.status,
  'emailVerified': instance.emailVerified,
  'requiresPasswordForDeletion': instance.requiresPasswordForDeletion,
  'preferredLanguage': instance.preferredLanguage,
  'createdAt': instance.createdAt?.toIso8601String(),
  'fullName': instance.fullName,
};

_AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) => _AuthTokens(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
);

Map<String, dynamic> _$AuthTokensToJson(_AuthTokens instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };

_AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) =>
    _AuthResponse(
      success: json['success'] as bool,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      tokens: json['tokens'] == null
          ? null
          : AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
      error: json['error'] as String?,
      expiresIn: (json['expiresIn'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AuthResponseToJson(_AuthResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'user': instance.user,
      'tokens': instance.tokens,
      'error': instance.error,
      'expiresIn': instance.expiresIn,
    };

_SocialAuthResult _$SocialAuthResultFromJson(Map<String, dynamic> json) =>
    _SocialAuthResult(
      success: json['success'] as bool,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      tokens: json['tokens'] == null
          ? null
          : AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
      error: json['error'] as String?,
      appleCredential: json['appleCredential'],
    );

Map<String, dynamic> _$SocialAuthResultToJson(_SocialAuthResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'user': instance.user,
      'tokens': instance.tokens,
      'error': instance.error,
      'appleCredential': instance.appleCredential,
    };
