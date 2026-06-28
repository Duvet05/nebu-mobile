class WebBluetoothConnectionResult {
  const WebBluetoothConnectionResult({
    required this.deviceName,
    required this.bleService,
  });

  final String deviceName;
  final Object bleService;
}

Future<WebBluetoothConnectionResult> connectToNebuWifiService() {
  throw UnsupportedError('Web Bluetooth is only available on web builds');
}

bool isWebBluetoothCancellation(Object error) {
  final message = error.toString().toLowerCase();
  return message.contains('cancel') ||
      message.contains('notfounderror') ||
      message.contains('user cancelled') ||
      message.contains('user canceled');
}
