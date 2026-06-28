import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import '../../core/constants/ble_constants.dart';

class WebBluetoothConnectionResult {
  const WebBluetoothConnectionResult({
    required this.deviceName,
    required this.bleService,
  });

  final String deviceName;
  final Object bleService;
}

Future<WebBluetoothConnectionResult> connectToNebuWifiService() async {
  final nav = web.window.navigator as JSObject;
  if (!nav.has('bluetooth')) {
    throw Exception('Web Bluetooth not supported');
  }
  final bluetooth = _requiredJsObject(nav['bluetooth'], 'navigator.bluetooth');

  final options = {
    'filters': [
      {'namePrefix': 'Nebu'},
      {'namePrefix': 'ESP32'},
      {'namePrefix': 'nebu'},
    ],
    'optionalServices': [BleConstants.esp32WifiServiceUuid],
  }.jsify();

  final devicePromise = bluetooth.callMethodVarArgs<JSPromise>(
    'requestDevice'.toJS,
    [options],
  );
  final device = await _promiseToJsObject(devicePromise, 'Bluetooth device');
  final deviceName = _optionalJsString(device['name']) ?? 'Nebu Device';

  final gatt = _requiredJsObject(device['gatt'], 'Bluetooth GATT server');
  final connectPromise = gatt.callMethodVarArgs<JSPromise>('connect'.toJS, []);
  await connectPromise.toDart;

  final servicePromise = gatt.callMethodVarArgs<JSPromise>(
    'getPrimaryService'.toJS,
    [BleConstants.esp32WifiServiceUuid.toJS],
  );
  final bleService = await _promiseToJsObject(
    servicePromise,
    'Nebu WiFi GATT service',
  );

  return WebBluetoothConnectionResult(
    deviceName: deviceName,
    bleService: bleService,
  );
}

bool isWebBluetoothCancellation(Object error) {
  final message = error.toString().toLowerCase();
  return message.contains('cancel') ||
      message.contains('notfounderror') ||
      message.contains('user cancelled') ||
      message.contains('user canceled');
}

JSObject _requiredJsObject(JSAny? value, String context) {
  if (value == null) {
    throw Exception('$context is not available');
  }
  return value as JSObject;
}

Future<JSObject> _promiseToJsObject(JSPromise promise, String context) async {
  final value = await promise.toDart;
  if (value == null) {
    throw Exception('$context resolved to null');
  }
  return value as JSObject;
}

String? _optionalJsString(JSAny? value) {
  if (value == null) {
    return null;
  }
  return (value as JSString).toDart;
}
