import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/ble_constants.dart';
import '../../core/constants/storage_keys.dart';
import 'ble_characteristic_handler.dart';
import 'bluetooth_service.dart';

/// WiFi connection status reported by the ESP32.
enum ESP32WifiStatus {
  idle('IDLE'),
  connecting('CONNECTING'),
  connected('CONNECTED'),
  reconnecting('RECONNECTING'),
  failed('FAILED');

  const ESP32WifiStatus(this.value);
  final String value;

  static ESP32WifiStatus fromString(String value) =>
      ESP32WifiStatus.values.firstWhere(
        (s) => s.value == value.toUpperCase(),
        orElse: () => ESP32WifiStatus.idle,
      );
}

/// Result of a WiFi configuration attempt.
class ESP32WifiConfigResult {
  const ESP32WifiConfigResult({
    required this.success,
    required this.message,
    this.status,
  });

  final bool success;
  final String message;
  final ESP32WifiStatus? status;
}

/// Configures WiFi, reads device identity, and controls audio on ESP32 via BLE.
class ESP32WifiConfigService {
  ESP32WifiConfigService({
    required BluetoothService bluetoothService,
    required Logger logger,
    required SharedPreferences prefs,
  }) : _bluetoothService = bluetoothService,
       _logger = logger,
       _prefs = prefs,
       _statusController = StreamController<ESP32WifiStatus>.broadcast(),
       _deviceIdController = StreamController<String>.broadcast(),
       _ssid = BleCharacteristicHandler(
         uuid: BleConstants.esp32SsidCharUuid,
         tag: 'SSID',
         bluetoothService: bluetoothService,
         logger: logger,
       ),
       _password = BleCharacteristicHandler(
         uuid: BleConstants.esp32PasswordCharUuid,
         tag: 'PASSWORD',
         bluetoothService: bluetoothService,
         logger: logger,
       ),
       _status = BleCharacteristicHandler(
         uuid: BleConstants.esp32StatusCharUuid,
         tag: 'STATUS',
         bluetoothService: bluetoothService,
         logger: logger,
         optional: true,
       ),
       _deviceIdChar = BleCharacteristicHandler(
         uuid: BleConstants.esp32DeviceIdCharUuid,
         tag: 'DEVICE_ID',
         bluetoothService: bluetoothService,
         logger: logger,
         optional: true,
       ),
       _volumeChar = BleCharacteristicHandler(
         uuid: BleConstants.esp32VolumeCharUuid,
         tag: 'VOLUME',
         bluetoothService: bluetoothService,
         logger: logger,
         optional: true,
       ),
       _muteChar = BleCharacteristicHandler(
         uuid: BleConstants.esp32MuteCharUuid,
         tag: 'MUTE',
         bluetoothService: bluetoothService,
         logger: logger,
         optional: true,
       );

  final BluetoothService _bluetoothService;
  final Logger _logger;
  final SharedPreferences _prefs;
  final StreamController<ESP32WifiStatus> _statusController;
  final StreamController<String> _deviceIdController;

  // BLE characteristic handlers
  final BleCharacteristicHandler _ssid;
  final BleCharacteristicHandler _password;
  final BleCharacteristicHandler _status;
  final BleCharacteristicHandler _deviceIdChar;
  final BleCharacteristicHandler _volumeChar;
  final BleCharacteristicHandler _muteChar;

  // Cached state
  String? _currentDeviceId;
  int? _currentVolume;
  bool? _currentMute;

  // Public API — streams & getters
  Stream<ESP32WifiStatus> get statusStream => _statusController.stream;
  Stream<String> get deviceIdStream => _deviceIdController.stream;
  String? get deviceId => _currentDeviceId;
  int? get volume => _currentVolume;
  bool? get isMuted => _currentMute;

  /// Connect to an ESP32 and discover all characteristics.
  Future<void> connectToESP32(fbp.BluetoothDevice device) async {
    _logger.i('[ESP32] Connecting to: ${device.platformName}');

    // Connect if not already connected
    if (!_bluetoothService.isConnected ||
        _bluetoothService.connectedDevice?.remoteId != device.remoteId) {
      await _bluetoothService.connect(device);
    }

    // Let ESP32 prepare its services
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final services = await _bluetoothService.discoverServicesForDevice(
      device,
      forceRefresh: true,
    );

    // Find WiFi service
    final wifiService = services.firstWhere(
      (s) =>
          s.uuid.toString().toLowerCase() ==
          BleConstants.esp32WifiServiceUuid.toLowerCase(),
      orElse: () => throw Exception('WiFi configuration service not found'),
    );

    // Discover all characteristics
    for (final handler in _allHandlers) {
      handler.discover(wifiService);
    }

    // Subscribe to notifications
    await _status.subscribe(_onStatusNotification);
    await _deviceIdChar.subscribe(_onDeviceIdNotification);
    await _volumeChar.subscribe(_onVolumeNotification);
    await _muteChar.subscribe(_onMuteNotification);

    // Read initial values
    await readDeviceId();
    await readVolume();
    await readMute();

    _logger.i('[ESP32] Connected and ready');
  }

  /// Send WiFi credentials to the ESP32.
  Future<ESP32WifiConfigResult> sendWifiCredentials({
    required String ssid,
    required String password,
  }) async {
    if (!_ssid.isAvailable || !_password.isAvailable) {
      return const ESP32WifiConfigResult(
        success: false,
        message: 'Characteristics not ready. Was connectToESP32 called?',
      );
    }

    try {
      _logger.i('[WIFI] Sending credentials (SSID: "$ssid")');

      await _ssid.writeString(ssid);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await _password.writeString(password);

      _logger.i('[WIFI] Credentials sent');

      // Read initial status if available
      if (_status.supportsRead) {
        await readWifiStatus();
      }

      return const ESP32WifiConfigResult(
        success: true,
        message: 'WiFi credentials sent to ESP32',
      );
    } on Exception catch (e) {
      _logger.e('[WIFI] Error sending credentials: $e');
      return ESP32WifiConfigResult(
        success: false,
        message: 'Failed to send credentials: $e',
      );
    }
  }

  /// Read current WiFi connection status.
  Future<ESP32WifiStatus> readWifiStatus() async {
    final raw = await _status.readString();
    if (raw == null) return ESP32WifiStatus.idle;

    final status = ESP32WifiStatus.fromString(raw);
    _logger.d('[STATUS] WiFi status: $status');
    return status;
  }

  /// Read the device ID from the ESP32.
  Future<String?> readDeviceId() async {
    final id = await _deviceIdChar.readString();
    if (id == null) return null;

    _currentDeviceId = id;
    await _prefs.setString(StorageKeys.currentDeviceId, id);
    _deviceIdController.add(id);
    _logger.d('[DEVICE_ID] Read: "$id"');
    return id;
  }

  /// Get locally saved device ID.
  String? getSavedDeviceId() =>
      _prefs.getString(StorageKeys.currentDeviceId);

  /// Clear saved device ID.
  Future<void> clearSavedDeviceId() async {
    await _prefs.remove(StorageKeys.currentDeviceId);
    _currentDeviceId = null;
  }

  /// Set ESP32 volume (0-100).
  Future<bool> setVolume(int value) async {
    if (!_volumeChar.isAvailable || value < 0 || value > 100) return false;

    try {
      await _volumeChar.writeUint8(value);
      _currentVolume = value;
      _logger.d('[VOLUME] Set to $value');
      return true;
    } on Exception catch (e) {
      _logger.e('[VOLUME] Error setting: $e');
      return false;
    }
  }

  /// Read current volume from ESP32.
  Future<int?> readVolume() async {
    final value = await _volumeChar.readUint8();
    if (value != null) _currentVolume = value;
    return value;
  }

  /// Set ESP32 mute state.
  Future<bool> setMute({required bool mute}) async {
    if (!_muteChar.isAvailable) return false;

    try {
      await _muteChar.writeUint8(mute ? 1 : 0);
      _currentMute = mute;
      _logger.d('[MUTE] Set to $mute');
      return true;
    } on Exception catch (e) {
      _logger.e('[MUTE] Error setting: $e');
      return false;
    }
  }

  /// Read current mute state from ESP32.
  Future<bool?> readMute() async {
    final value = await _muteChar.readUint8();
    if (value != null) _currentMute = value != 0;
    return _currentMute;
  }

  /// Disconnect from the ESP32 and clean up.
  Future<void> disconnect() async {
    for (final handler in _allHandlers) {
      await handler.dispose();
    }
    _currentDeviceId = null;
    _currentVolume = null;
    _currentMute = null;
    await _bluetoothService.disconnect();
    _logger.i('[ESP32] Disconnected');
  }

  /// Release all resources.
  void dispose() {
    for (final handler in _allHandlers) {
      handler.dispose();
    }
    _statusController.close();
    _deviceIdController.close();
  }

  // -- Private helpers --

  List<BleCharacteristicHandler> get _allHandlers =>
      [_ssid, _password, _status, _deviceIdChar, _volumeChar, _muteChar];

  void _onStatusNotification(List<int> value) {
    if (value.isEmpty) return;
    final status = ESP32WifiStatus.fromString(
      utf8.decode(value, allowMalformed: true).trim(),
    );
    _logger.d('[STATUS] Notification: $status');
    _statusController.add(status);
  }

  void _onDeviceIdNotification(List<int> value) {
    if (value.isEmpty) return;
    final id = utf8.decode(value, allowMalformed: true).trim();
    _currentDeviceId = id;
    _prefs.setString(StorageKeys.currentDeviceId, id);
    _deviceIdController.add(id);
  }

  void _onVolumeNotification(List<int> value) {
    if (value.isEmpty) return;
    _currentVolume = value[0];
  }

  void _onMuteNotification(List<int> value) {
    if (value.isEmpty) return;
    _currentMute = value[0] != 0;
  }
}
