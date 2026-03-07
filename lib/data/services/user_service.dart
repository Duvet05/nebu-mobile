import 'package:dio/dio.dart';
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
    try {
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
    } on DioException catch (e) {
      _logger.e('Error creating user: ${e.message}');
      if (e.response?.statusCode == 409) {
        throw Exception('El email ya está registrado');
      }
      throw Exception('Error al crear el usuario: ${e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error creating user: $e');
      throw Exception('Error inesperado al crear el usuario');
    }
  }

  /// Obtener el perfil del usuario actual
  Future<User> getCurrentUserProfile() async {
    try {
      _logger.d('Fetching current user profile');

      final response = await _apiService.get<Map<String, dynamic>>('/users/me');

      _logger.d('User profile fetched successfully');
      return User.fromJson(response);
    } on DioException catch (e) {
      _logger.e('Error fetching user profile: ${e.message}');
      throw Exception('Error al obtener el perfil del usuario: ${e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error fetching user profile: $e');
      throw Exception('Error inesperado al obtener el perfil');
    }
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
    try {
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
    } on DioException catch (e) {
      _logger.e('Error updating user profile: ${e.message}');
      throw Exception('Error al actualizar el perfil: ${e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error updating user profile: $e');
      throw Exception('Error inesperado al actualizar el perfil');
    }
  }

  /// Obtener usuario por ID
  Future<User> getUserById(String userId) async {
    try {
      _logger.d('Fetching user by ID: $userId');

      final response = await _apiService.get<Map<String, dynamic>>(
        '/users/$userId',
      );

      _logger.d('User fetched successfully');
      return User.fromJson(response);
    } on DioException catch (e) {
      _logger.e('Error fetching user by ID: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      }
      throw Exception('Error al obtener el usuario: ${e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error fetching user: $e');
      throw Exception('Error inesperado al obtener el usuario');
    }
  }

  /// Eliminar cuenta propia (hard delete)
  /// Elimina permanentemente la cuenta y todos los datos asociados
  Future<String> deleteOwnAccount({required String password, String? reason}) async {
    try {
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
    } on DioException catch (e) {
      _logger.e('Error deleting account: ${e.message}');
      throw Exception('Error al eliminar la cuenta: ${e.response?.data['message'] ?? e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error deleting account: $e');
      throw Exception('Error inesperado al eliminar la cuenta');
    }
  }

  /// Eliminar datos personales (anonymize)
  /// Anonimiza los datos del usuario pero mantiene la cuenta activa
  Future<String> deleteOwnData({required String password}) async {
    try {
      _logger.d('Deleting own data');

      final response = await _apiService.delete<Map<String, dynamic>>(
        '/users/me/data',
        data: {'password': password},
      );

      _logger.d('Personal data deleted successfully');
      return response['message'] as String? ?? 'Datos personales eliminados exitosamente';
    } on DioException catch (e) {
      _logger.e('Error deleting personal data: ${e.message}');
      throw Exception('Error al eliminar los datos: ${e.response?.data['message'] ?? e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error deleting personal data: $e');
      throw Exception('Error inesperado al eliminar los datos');
    }
  }
}
