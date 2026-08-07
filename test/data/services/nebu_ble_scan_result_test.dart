import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_test/flutter_test.dart';
import 'package:nebu_mobile_flutter/core/constants/ble_constants.dart';
import 'package:nebu_mobile_flutter/data/services/nebu_ble_scan_result.dart';

void main() {
  group('NebuBleScanResult', () {
    test('matches the advertised provisioning service without a name', () {
      final result = _scanResult(
        serviceUuids: [fbp.Guid(BleConstants.esp32WifiServiceUuid)],
      );

      expect(result.isNebuProvisioningDevice, isTrue);
      expect(result.nebuDisplayName, 'Nebu');
    });

    test('matches legacy firmware by advertised ESP32 name', () {
      final result = _scanResult(advName: 'ESP32-WiFi-Config');

      expect(result.isNebuProvisioningDevice, isTrue);
      expect(result.nebuDisplayName, 'ESP32-WiFi-Config');
    });

    test('prefers the advertised name for display', () {
      final result = _scanResult(advName: 'Nebu-Setup');

      expect(result.nebuDisplayName, 'Nebu-Setup');
    });

    test('rejects unrelated BLE advertisements', () {
      final result = _scanResult(
        advName: 'Wireless Speaker',
        serviceUuids: [fbp.Guid('0000180f-0000-1000-8000-00805f9b34fb')],
      );

      expect(result.isNebuProvisioningDevice, isFalse);
    });
  });
}

fbp.ScanResult _scanResult({
  String advName = '',
  List<fbp.Guid> serviceUuids = const [],
}) => fbp.ScanResult(
  device: fbp.BluetoothDevice.fromId('00000000-0000-0000-0000-000000000001'),
  advertisementData: fbp.AdvertisementData(
    advName: advName,
    txPowerLevel: null,
    appearance: null,
    connectable: true,
    manufacturerData: const {},
    serviceData: const {},
    serviceUuids: serviceUuids,
  ),
  rssi: -48,
  timeStamp: DateTime(2026, 8, 5),
);
