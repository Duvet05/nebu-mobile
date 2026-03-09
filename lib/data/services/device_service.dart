import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:logger/logger.dart';

import '../../core/constants/ble_constants.dart';
import 'bluetooth_service.dart';

/// Servicio para interactuar con características estándar del dispositivo (ej. Batería)
class DeviceService {
  DeviceService({
    required BluetoothService bluetoothService,
    required Logger logger,
  }) : _bluetoothService = bluetoothService,
       _logger = logger;

  final BluetoothService _bluetoothService;
  final Logger _logger;

  /// Lee el nivel de batería de un dispositivo Bluetooth específico.
  ///
  /// Busca el servicio de batería estándar (0x180F) y lee la característica
  /// de nivel de batería (0x2A19).
  ///
  /// Devuelve un entero entre 0 y 100, o -1 si no se puede leer.
  Future<int> getBatteryLevel(fbp.BluetoothDevice device) async {
    // Asegurarse de que el dispositivo esté conectado
    final isConnected = await _bluetoothService.getConnectedDevices().then(
      (devices) => devices.any((d) => d.remoteId == device.remoteId),
    );

    if (!isConnected) {
      _logger.w(
        'Cannot get battery level, device ${device.platformName} is not connected.',
      );
      return -1;
    }

    try {
      _logger.i('Reading battery level for ${device.platformName}...');

      // 1. Descubrir servicios (usando el método optimizado con caché)
      final services = await _bluetoothService.discoverServicesForDevice(
        device,
      );

      // 2. Encontrar el servicio de batería
      final batteryService = services.firstWhere(
        (s) =>
            s.uuid.toString().toLowerCase() ==
            BleConstants.batteryServiceUuid.toLowerCase(),
        orElse: () => throw Exception('Battery service not found'),
      );

      _logger.d('Found battery service: ${batteryService.uuid}');

      // 3. Encontrar la característica de nivel de batería
      final batteryLevelChar = batteryService.characteristics.firstWhere(
        (c) =>
            c.uuid.toString().toLowerCase() ==
            BleConstants.batteryLevelCharUuid.toLowerCase(),
        orElse: () => throw Exception('Battery level characteristic not found'),
      );

      _logger.d('Found battery level characteristic: ${batteryLevelChar.uuid}');

      // 4. Leer el valor
      if (!batteryLevelChar.properties.read) {
        _logger.w('Battery level characteristic does not support read.');
        return -1;
      }

      final value = await batteryLevelChar.read();

      if (value.isEmpty) {
        _logger.w('Battery level characteristic returned empty value.');
        return -1;
      }

      final batteryLevel = value[0];
      _logger.i('${device.platformName} battery level is $batteryLevel%');

      return batteryLevel;
    } on Exception catch (e, st) {
      _logger.e('Failed to get battery level for ${device.platformName}: $e', error: e, stackTrace: st);
      rethrow;
    }
  }
}
