import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

import '../../core/constants/ble_constants.dart';

/// Nebu-specific interpretation of a BLE advertisement.
///
/// CoreBluetooth may expose the advertised local name before it populates the
/// platform device name. Matching both names and the provisioning service UUID
/// keeps discovery reliable on iOS while remaining compatible with older Nebu
/// firmware that advertised only `ESP32-WiFi-Config`.
extension NebuBleScanResult on fbp.ScanResult {
  bool get isNebuProvisioningDevice {
    final expectedService = BleConstants.esp32WifiServiceUuid.toLowerCase();
    final advertisesProvisioningService = advertisementData.serviceUuids.any(
      (uuid) => uuid.toString().toLowerCase() == expectedService,
    );
    if (advertisesProvisioningService) {
      return true;
    }

    return _isKnownNebuName(advertisementData.advName) ||
        _isKnownNebuName(device.platformName);
  }

  String get nebuDisplayName {
    final advertisedName = advertisementData.advName.trim();
    if (advertisedName.isNotEmpty) {
      return advertisedName;
    }

    final platformName = device.platformName.trim();
    if (platformName.isNotEmpty) {
      return platformName;
    }

    return 'Nebu';
  }
}

bool _isKnownNebuName(String name) {
  final normalized = name.trim().toLowerCase();
  return normalized.contains('nebu') || normalized.contains('esp32');
}
