import 'package:flutter_test/flutter_test.dart';
import 'package:nebu_mobile_flutter/data/services/wifi_qr_parser.dart';

void main() {
  test('parses a valid WIFI payload', () {
    final result = WiFiQrParser.parse('WIFI:S:Home;T:WPA;P:secret;;');

    expect(result?.ssid, 'Home');
    expect(result?.password, 'secret');
  });

  test('rejects non-WIFI payloads used by the scanner mode', () {
    expect(WiFiQrParser.parse('AA:BB:CC:11:22:33'), isNull);
    expect(WiFiQrParser.parse('https://example.com'), isNull);
  });
}
