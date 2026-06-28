import 'esp32_wifi_config_service.dart';

class WebWifiConfigSession {
  WebWifiConfigSession(Object? _);

  bool get isAvailable => false;

  Stream<ESP32WifiStatus> get statusStream =>
      const Stream<ESP32WifiStatus>.empty();

  Future<void> initialize() async {}

  Future<void> sendWifiCredentials({
    required String ssid,
    required String password,
  }) async {
    throw UnsupportedError('Web Bluetooth is only available on web builds');
  }

  Future<String?> readDeviceId() async => null;

  Future<void> dispose() async {}
}
