import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import '../../core/constants/ble_constants.dart';
import 'esp32_wifi_config_service.dart';

class WebWifiConfigSession {
  WebWifiConfigSession(Object? bleService)
    : _service = _castService(bleService);

  final JSObject? _service;
  final StreamController<ESP32WifiStatus> _statusController =
      StreamController<ESP32WifiStatus>.broadcast();
  late final JSFunction _statusChangedListener = _handleStatusChanged.toJS;

  JSObject? _ssidCharacteristic;
  JSObject? _passwordCharacteristic;
  JSObject? _statusCharacteristic;
  Timer? _statusPollTimer;
  bool _initialized = false;
  bool _isReadingStatus = false;
  bool _isListeningForStatus = false;

  bool get isAvailable => _service != null;

  Stream<ESP32WifiStatus> get statusStream => _statusController.stream;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final service = _service;
    if (service == null) {
      throw Exception('Web Bluetooth service is not available');
    }

    _ssidCharacteristic = await _getCharacteristic(
      service,
      BleConstants.esp32SsidCharUuid,
    );
    _passwordCharacteristic = await _getCharacteristic(
      service,
      BleConstants.esp32PasswordCharUuid,
    );
    _statusCharacteristic = await _tryGetCharacteristic(
      service,
      BleConstants.esp32StatusCharUuid,
    );
    await _subscribeToStatusNotifications();
    _initialized = true;
  }

  Future<void> sendWifiCredentials({
    required String ssid,
    required String password,
  }) async {
    await initialize();

    final ssidCharacteristic = _ssidCharacteristic;
    final passwordCharacteristic = _passwordCharacteristic;
    if (ssidCharacteristic == null || passwordCharacteristic == null) {
      throw Exception('Web Bluetooth characteristics are not ready');
    }

    await _writeString(ssidCharacteristic, ssid);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await _writeString(passwordCharacteristic, password);

    unawaited(_readAndEmitStatus());
    _startStatusPolling();
  }

  Future<void> dispose() async {
    _statusPollTimer?.cancel();
    _removeStatusNotificationListener();
    await _statusController.close();
  }

  static JSObject? _castService(Object? service) {
    if (service == null) {
      return null;
    }

    try {
      return service as JSObject;
    } catch (_) {
      return null;
    }
  }

  Future<JSObject> _getCharacteristic(JSObject service, String uuid) async {
    final promise = service.callMethodVarArgs<JSPromise>(
      'getCharacteristic'.toJS,
      [uuid.toJS],
    );
    return (await promise.toDart) as JSObject;
  }

  Future<JSObject?> _tryGetCharacteristic(JSObject service, String uuid) async {
    try {
      return await _getCharacteristic(service, uuid);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeString(JSObject characteristic, String value) async {
    final bytes = Uint8List.fromList(utf8.encode(value)).toJS;

    if (characteristic.has('writeValueWithResponse')) {
      try {
        final promise = characteristic.callMethodVarArgs<JSPromise>(
          'writeValueWithResponse'.toJS,
          [bytes],
        );
        await promise.toDart;
        return;
      } catch (_) {
        // Fall through to the legacy Web Bluetooth write method.
      }
    }

    final promise = characteristic.callMethodVarArgs<JSPromise>(
      'writeValue'.toJS,
      [bytes],
    );
    await promise.toDart;
  }

  void _startStatusPolling() {
    if (_statusCharacteristic == null) {
      return;
    }

    _statusPollTimer?.cancel();
    _statusPollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      unawaited(_readAndEmitStatus());
    });
  }

  Future<void> _subscribeToStatusNotifications() async {
    final statusCharacteristic = _statusCharacteristic;
    if (statusCharacteristic == null ||
        !statusCharacteristic.has('startNotifications') ||
        !statusCharacteristic.has('addEventListener')) {
      return;
    }

    try {
      final promise = statusCharacteristic.callMethodVarArgs<JSPromise>(
        'startNotifications'.toJS,
        [],
      );
      await promise.toDart;
      statusCharacteristic.callMethodVarArgs<JSAny?>('addEventListener'.toJS, [
        'characteristicvaluechanged'.toJS,
        _statusChangedListener,
      ]);
      _isListeningForStatus = true;
    } catch (_) {
      // Some firmwares expose STATUS as read-only. Polling remains the fallback.
    }
  }

  void _removeStatusNotificationListener() {
    final statusCharacteristic = _statusCharacteristic;
    if (!_isListeningForStatus ||
        statusCharacteristic == null ||
        !statusCharacteristic.has('removeEventListener')) {
      return;
    }

    statusCharacteristic.callMethodVarArgs<JSAny?>('removeEventListener'.toJS, [
      'characteristicvaluechanged'.toJS,
      _statusChangedListener,
    ]);
    _isListeningForStatus = false;
  }

  void _handleStatusChanged(JSObject event) {
    final target = event['target'] as JSObject?;
    final value = target?['value'] as JSObject?;
    if (value == null) {
      return;
    }
    _emitStatusFromDataView(value);
  }

  Future<ESP32WifiStatus?> _readAndEmitStatus() async {
    if (_isReadingStatus) {
      return null;
    }

    final statusCharacteristic = _statusCharacteristic;
    if (statusCharacteristic == null ||
        !statusCharacteristic.has('readValue')) {
      return null;
    }

    _isReadingStatus = true;
    try {
      final promise = statusCharacteristic.callMethodVarArgs<JSPromise>(
        'readValue'.toJS,
        [],
      );
      final dataView = (await promise.toDart) as JSObject;
      return _emitStatusFromDataView(dataView);
    } catch (_) {
      return null;
    } finally {
      _isReadingStatus = false;
    }
  }

  ESP32WifiStatus? _emitStatusFromDataView(JSObject dataView) {
    final rawStatus = _decodeDataView(dataView).trim();
    if (rawStatus.isEmpty) {
      return null;
    }

    final status = ESP32WifiStatus.fromString(rawStatus);
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
    if (status == ESP32WifiStatus.connected ||
        status == ESP32WifiStatus.failed) {
      _statusPollTimer?.cancel();
    }
    return status;
  }

  String _decodeDataView(JSObject dataView) {
    final byteLength = (dataView['byteLength'] as JSNumber).toDartInt;
    final bytes = <int>[];
    for (var i = 0; i < byteLength; i += 1) {
      final byte = dataView.callMethodVarArgs<JSNumber>('getUint8'.toJS, [
        i.toJS,
      ]);
      bytes.add(byte.toDartInt);
    }
    return utf8.decode(bytes, allowMalformed: true);
  }
}
