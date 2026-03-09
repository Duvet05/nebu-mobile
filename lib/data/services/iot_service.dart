import 'package:logger/logger.dart';

import '../models/iot_device.dart';
import 'api_service.dart';

class IoTService {
  IoTService({
    required ApiService apiService,
    required Logger logger,
  })  : _apiService = apiService,
        _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  /// Get all IoT devices
  Future<List<IoTDevice>> getAllDevices({
    String? userId,
    DeviceStatus? status,
    DeviceType? deviceType,
    String? location,
  }) async {
    _logger.i('Fetching all IoT devices...');

    final queryParameters = <String, dynamic>{};
    if (userId != null) {
      queryParameters['userId'] = userId;
    }
    if (status != null) {
      queryParameters['status'] = status.name;
    }
    if (deviceType != null) {
      queryParameters['deviceType'] = deviceType.name;
    }
    if (location != null) {
      queryParameters['location'] = location;
    }

    final response = await _apiService.get<List<dynamic>>(
      '/iot/devices',
      queryParameters: queryParameters,
    );

    final devices = response
        .map((json) => IoTDevice.fromJson(json as Map<String, dynamic>))
        .toList();

    _logger.i('Fetched ${devices.length} devices');
    return devices;
  }

  /// Get devices by user ID
  Future<List<IoTDevice>> getDevicesByUser(String userId) async {
    _logger.i('Fetching devices for user: $userId');

    final response = await _apiService.get<List<dynamic>>(
      '/iot/devices/user/$userId',
    );

    final devices = response
        .map((json) => IoTDevice.fromJson(json as Map<String, dynamic>))
        .toList();

    _logger.i('Fetched ${devices.length} devices for user $userId');
    return devices;
  }

  /// Get online devices
  Future<List<IoTDevice>> getOnlineDevices() async {
    _logger.i('Fetching online devices...');

    final response = await _apiService.get<List<dynamic>>(
      '/iot/devices/online',
    );

    final devices = response
        .map((json) => IoTDevice.fromJson(json as Map<String, dynamic>))
        .toList();

    _logger.i('Fetched ${devices.length} online devices');
    return devices;
  }

  /// Get a specific device by ID
  Future<IoTDevice> getDevice(String deviceId) async {
    _logger.i('Fetching device: $deviceId');

    final response = await _apiService.get<Map<String, dynamic>>(
      '/iot/devices/$deviceId',
    );

    final device = IoTDevice.fromJson(response);
    _logger.i('Fetched device: ${device.name}');
    return device;
  }

  /// Get device metrics
  Future<IoTMetrics> getMetrics() async {
    _logger.i('Fetching device metrics...');

    final response = await _apiService.get<Map<String, dynamic>>(
      '/iot/devices/metrics',
    );

    final metrics = IoTMetrics.fromJson(response);
    _logger.i('Fetched device metrics');
    return metrics;
  }

  /// Create a new IoT device
  Future<IoTDevice> createDevice(CreateIoTDeviceDto deviceDto) async {
    _logger.i('Creating new device: ${deviceDto.name}');

    final response = await _apiService.post<Map<String, dynamic>>(
      '/iot/devices',
      data: deviceDto.toJson(),
    );

    final device = IoTDevice.fromJson(response);
    _logger.i('Created device: ${device.id}');
    return device;
  }

  /// Update an existing device
  Future<IoTDevice> updateDevice(
    String deviceId,
    UpdateIoTDeviceDto updateDto,
  ) async {
    _logger.i('Updating device: $deviceId');

    final response = await _apiService.patch<Map<String, dynamic>>(
      '/iot/devices/$deviceId',
      data: updateDto.toJson(),
    );

    final device = IoTDevice.fromJson(response);
    _logger.i('Updated device: ${device.id}');
    return device;
  }

  /// Update device status
  Future<IoTDevice> updateDeviceStatus(
    String deviceId,
    DeviceStatus status,
  ) async {
    _logger.i('Updating device status: $deviceId -> ${status.name}');

    final response = await _apiService.patch<Map<String, dynamic>>(
      '/iot/devices/$deviceId/status',
      data: {'status': status.name},
    );

    final device = IoTDevice.fromJson(response);
    _logger.i('Updated device status: ${device.id}');
    return device;
  }

  /// Update sensor data
  Future<IoTDevice> updateSensorData(
    String deviceId, {
    double? temperature,
    double? humidity,
    int? batteryLevel,
    int? signalStrength,
  }) async {
    _logger.i('Updating sensor data for device: $deviceId');

    final data = <String, dynamic>{};
    if (temperature != null) {
      data['temperature'] = temperature;
    }
    if (humidity != null) {
      data['humidity'] = humidity;
    }
    if (batteryLevel != null) {
      data['batteryLevel'] = batteryLevel;
    }
    if (signalStrength != null) {
      data['signalStrength'] = signalStrength;
    }

    final response = await _apiService.patch<Map<String, dynamic>>(
      '/iot/devices/$deviceId/sensor-data',
      data: data,
    );

    final device = IoTDevice.fromJson(response);
    _logger.i('Updated sensor data for device: ${device.id}');
    return device;
  }

  /// Delete a device
  Future<void> deleteDevice(String deviceId) async {
    _logger.i('Deleting device: $deviceId');
    await _apiService.delete<void>('/iot/devices/$deviceId');
    _logger.i('Deleted device: $deviceId');
  }

  /// Generate LiveKit token for device
  Future<Map<String, dynamic>> generateLiveKitToken(String deviceId) async {
    _logger.i('Generating LiveKit token for device: $deviceId');

    final response = await _apiService.post<Map<String, dynamic>>(
      '/iot/devices/$deviceId/livekit-token',
    );

    _logger.i('Generated LiveKit token for device: $deviceId');
    return response;
  }
}
