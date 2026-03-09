import 'package:logger/logger.dart';

import '../models/user.dart';
import 'api_service.dart';

class UserService {
  UserService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  /// Crear un nuevo usuario (registro simple sin autenticación)
  Future<User> createUser({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    String? username,
    String? phone,
    String? preferredLanguage,
  }) async {
    _logger.d('Creating user with email: $email');

    final response = await _apiService.post<Map<String, dynamic>>(
      '/users',
      data: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        if (username != null) 'username': username,
        if (phone != null) 'phone': phone,
        if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
      },
    );

    _logger.d('User created successfully: ${response['id']}');
    return User.fromJson(response);
  }

  /// Obtener el perfil del usuario actual
  Future<User> getCurrentUserProfile() async {
    _logger.d('Fetching current user profile');

    final response = await _apiService.get<Map<String, dynamic>>('/users/me');

    _logger.d('User profile fetched successfully');
    return User.fromJson(response);
  }

  /// Actualizar el perfil del usuario actual
  Future<User> updateCurrentUserProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? bio,
    String? phone,
    String? preferredLanguage,
  }) async {
    _logger.d('Updating current user profile');

    final data = <String, dynamic>{};
    if (firstName != null) {
      data['firstName'] = firstName;
    }
    if (lastName != null) {
      data['lastName'] = lastName;
    }
    if (username != null) {
      data['username'] = username;
    }
    if (bio != null) {
      data['bio'] = bio;
    }
    if (phone != null) {
      data['phone'] = phone;
    }
    if (preferredLanguage != null) {
      data['preferredLanguage'] = preferredLanguage;
    }

    final response = await _apiService.patch<Map<String, dynamic>>(
      '/users/me',
      data: data,
    );

    _logger.d('User profile updated successfully');
    return User.fromJson(response);
  }

  /// Actualizar avatar del usuario actual
  Future<User> updateAvatar(String avatarUrl) async {
    _logger.d('Updating user avatar');

    final response = await _apiService.patch<Map<String, dynamic>>(
      '/users/me/avatar',
      data: {'avatarUrl': avatarUrl},
    );

    _logger.d('Avatar updated successfully');
    return User.fromJson(response);
  }

  /// Eliminar cuenta propia (hard delete)
  /// Elimina permanentemente la cuenta y todos los datos asociados
  Future<String> deleteOwnAccount({
    required String password,
    String? reason,
  }) async {
    _logger.d('Deleting own account');

    final response = await _apiService.delete<Map<String, dynamic>>(
      '/users/me',
      data: {
        'password': password,
        if (reason != null) 'reason': reason,
      },
    );

    _logger.d('Account deleted successfully');
    return response['message'] as String? ?? 'Cuenta eliminada exitosamente';
  }

  /// Eliminar datos personales (anonymize)
  /// Anonimiza los datos del usuario pero mantiene la cuenta activa
  Future<String> deleteOwnData({required String password}) async {
    _logger.d('Deleting own data');

    final response = await _apiService.delete<Map<String, dynamic>>(
      '/users/me/data',
      data: {'password': password},
    );

    _logger.d('Personal data deleted successfully');
    return response['message'] as String? ??
        'Datos personales eliminados exitosamente';
  }
}
