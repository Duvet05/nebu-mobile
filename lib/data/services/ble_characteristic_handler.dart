import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:logger/logger.dart';

import 'bluetooth_service.dart';

/// Generic handler for a single BLE characteristic.
/// Encapsulates discover → subscribe → read → write lifecycle.
class BleCharacteristicHandler {
  BleCharacteristicHandler({
    required this.uuid,
    required this.tag,
    required BluetoothService bluetoothService,
    required Logger logger,
    this.optional = false,
  }) : _bluetoothService = bluetoothService,
       _logger = logger;

  final String uuid;
  final String tag;
  final bool optional;
  final BluetoothService _bluetoothService;
  final Logger _logger;

  fbp.BluetoothCharacteristic? _characteristic;
  StreamSubscription<List<int>>? _subscription;

  bool get isAvailable => _characteristic != null;
  bool get supportsNotify => _characteristic?.properties.notify ?? false;
  bool get supportsRead => _characteristic?.properties.read ?? false;
  bool get supportsWrite =>
      _characteristic?.properties.write == true ||
      _characteristic?.properties.writeWithoutResponse == true;

  /// Discover this characteristic from a BLE service.
  /// Throws if not found and [optional] is false.
  void discover(fbp.BluetoothService service) {
    final matches = service.characteristics.where(
      (c) => c.uuid.toString().toLowerCase() == uuid.toLowerCase(),
    );

    if (matches.isEmpty) {
      if (!optional) {
        throw Exception('$tag characteristic not found');
      }
      _logger.d('[$tag] Characteristic not found (optional)');
      return;
    }

    _characteristic = matches.first;
    _logger.d('[$tag] Found characteristic');
  }

  /// Subscribe to notifications. Calls [onData] with raw bytes.
  Future<void> subscribe(void Function(List<int> value) onData) async {
    if (_characteristic == null || !supportsNotify) return;

    await _characteristic!.setNotifyValue(true);
    _subscription = _characteristic!.lastValueStream.listen(
      onData,
      onError: (Object e) => _logger.e('[$tag] Notification error: $e'),
    );
    _logger.d('[$tag] Subscribed to notifications');
  }

  /// Read raw bytes from the characteristic.
  Future<List<int>> readBytes() async {
    if (_characteristic == null || !supportsRead) return [];

    return _bluetoothService.readCharacteristic(_characteristic!);
  }

  /// Read and decode as UTF-8 string.
  Future<String?> readString() async {
    final bytes = await readBytes();
    if (bytes.isEmpty) return null;
    return utf8.decode(bytes, allowMalformed: true).trim();
  }

  /// Read a single uint8 value.
  Future<int?> readUint8() async {
    final bytes = await readBytes();
    if (bytes.isEmpty) return null;
    return bytes[0];
  }

  /// Write raw bytes to the characteristic.
  Future<void> writeBytes(List<int> value) async {
    if (_characteristic == null) {
      throw Exception('[$tag] Characteristic not ready');
    }

    await _bluetoothService.writeCharacteristic(
      _characteristic!,
      value,
      withoutResponse: _characteristic!.properties.writeWithoutResponse,
    );
  }

  /// Write a UTF-8 string.
  Future<void> writeString(String value) async {
    await writeBytes(utf8.encode(value));
  }

  /// Write a single uint8 value.
  Future<void> writeUint8(int value) async {
    await writeBytes([value]);
  }

  /// Cancel subscription and clear state.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _characteristic = null;
  }
}
