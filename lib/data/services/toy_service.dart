import 'package:logger/logger.dart';

import '../../core/errors/app_exception.dart';
import '../models/toy.dart';
import 'api_service.dart';

class ToyService {
  ToyService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  /// Registrar un nuevo juguete
  /// Backend identifies device by [deviceId] (preferred) or [macAddress] (legacy).
  /// User is auto-injected from JWT — do NOT send userId.
  Future<Toy> createToy({
    required String name,
    String? deviceId,
    String? macAddress,
    String? model,
    String? manufacturer,
    ToyStatus? status,
    String? firmwareVersion,
    Map<String, dynamic>? capabilities,
    Map<String, dynamic>? settings,
    String? notes,
    String? prompt,
    String? personalityProfile,
    String? greeting,
  }) async {
    _logger.d('Creating toy: $name');
    final response = await _apiService.post<Map<String, dynamic>>(
      '/toys',
      data: {
        'name': name,
        'deviceId': ?deviceId,
        'macAddress': ?macAddress,
        'model': ?model,
        'manufacturer': ?manufacturer,
        if (status != null) 'status': status.name,
        'firmwareVersion': ?firmwareVersion,
        'capabilities': ?capabilities,
        'settings': ?settings,
        'notes': ?notes,
        'prompt': ?prompt,
        'personalityProfile': ?personalityProfile,
        'greeting': ?greeting,
      },
    );
    _logger.d('Toy created successfully: ${response['id']}');
    return Toy.fromJson(response);
  }

  /// Obtener juguetes del usuario actual
  Future<List<Toy>> getMyToys() async {
    _logger.d('Fetching my toys from /toys/my-toys');

    List<dynamic> response;
    try {
      response = await _apiService.get<List<dynamic>>('/toys/my-toys');
    } on NotFoundException {
      // 404 means no toys found — valid empty state
      _logger.i('No toys found (404), returning empty list');
      return [];
    }

    if (response.isEmpty) {
      _logger.i('No toys found, returning empty list');
      return [];
    }

    final toys = <Toy>[];
    for (var i = 0; i < response.length; i++) {
      try {
        final json = response[i] as Map<String, dynamic>;
        toys.add(Toy.fromJson(json));
      } on Exception catch (e, stack) {
        _logger
          ..e('Error parsing toy $i: $e')
          ..e('Stack trace: $stack')
          ..e('Raw data: ${response[i]}');
        // Continue parsing other toys instead of failing completely
      }
    }

    _logger.i('Successfully parsed ${toys.length} toys');
    return toys;
  }

  /// Asignar un juguete existente a la cuenta del usuario
  Future<AssignToyResponse> assignToy({
    required String userId,
    String? deviceId,
    String? macAddress,
    String? toyName,
  }) async {
    _logger.d('Assigning toy with deviceId: $deviceId, MAC: $macAddress');
    final response = await _apiService.post<Map<String, dynamic>>(
      '/toys/assign',
      data: {
        'userId': userId,
        'deviceId': ?deviceId,
        'macAddress': ?macAddress,
        'toyName': ?toyName,
      },
    );
    _logger.d('Toy assigned successfully');
    return AssignToyResponse.fromJson(response);
  }

  /// Actualizar el estado de conexión del juguete
  Future<Toy> updateToyConnectionStatus({
    required String deviceId,
    required ToyStatus status,
    String? batteryLevel,
    String? signalStrength,
  }) async {
    _logger.d('Updating toy connection status: $deviceId');
    final response = await _apiService.patch<Map<String, dynamic>>(
      '/toys/connection/$deviceId',
      data: {
        'status': status.name,
        'batteryLevel': ?batteryLevel,
        'signalStrength': ?signalStrength,
      },
    );
    _logger.d('Toy status updated successfully');
    return Toy.fromJson(response);
  }

  /// Obtener un juguete por su ID
  Future<Toy> getToyById(String id) async {
    _logger.d('Fetching toy by ID: $id');
    final response = await _apiService.get<Map<String, dynamic>>('/toys/$id');
    _logger.d('Toy fetched successfully');
    return Toy.fromJson(response);
  }

  /// Actualizar información de un juguete
  Future<Toy> updateToy({
    required String id,
    String? name,
    String? ownerId,
    String? model,
    String? manufacturer,
    ToyStatus? status,
    String? firmwareVersion,
    Map<String, dynamic>? capabilities,
    Map<String, dynamic>? settings,
    String? notes,
    String? prompt,
    String? personalityProfile,
    String? greeting,
  }) async {
    _logger.d('Updating toy: $id');
    final response = await _apiService.patch<Map<String, dynamic>>(
      '/toys/$id',
      data: {
        'name': ?name,
        'ownerId': ?ownerId,
        'model': ?model,
        'manufacturer': ?manufacturer,
        if (status != null) 'status': status.name,
        'firmwareVersion': ?firmwareVersion,
        'capabilities': ?capabilities,
        'settings': ?settings,
        'notes': ?notes,
        'prompt': ?prompt,
        'personalityProfile': ?personalityProfile,
        'greeting': ?greeting,
      },
    );
    _logger.d('Toy updated successfully');
    return Toy.fromJson(response);
  }

  /// Liberar un juguete (desasignar del usuario sin eliminarlo)
  Future<AssignToyResponse> unassignToy(String id) async {
    _logger.d('Unassigning toy: $id');
    final response = await _apiService.post<Map<String, dynamic>>(
      '/toys/$id/unassign',
    );
    _logger.d('Toy unassigned successfully');
    return AssignToyResponse.fromJson(response);
  }

  /// Eliminar un juguete
  Future<void> deleteToy(String id) async {
    _logger.d('Deleting toy: $id');
    await _apiService.delete<void>('/toys/$id');
    _logger.d('Toy deleted successfully');
  }
}
