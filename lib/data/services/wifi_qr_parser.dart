/// Parses WiFi credentials from QR code data.
///
/// Standard format: `WIFI:S:<SSID>;T:<TYPE>;P:<PASSWORD>;H:<HIDDEN>;;`
class WiFiQrParser {
  WiFiQrParser._();

  /// Returns `(ssid, password)` if the QR data is a valid WiFi QR code,
  /// or `null` if the format is not recognized.
  static ({String ssid, String password})? parse(String qrData) {
    if (!qrData.startsWith('WIFI:')) {
      return null;
    }

    final ssidMatch = RegExp('S:(.*?);').firstMatch(qrData);
    if (ssidMatch == null) {
      return null;
    }

    final ssid = ssidMatch.group(1) ?? '';
    final passwordMatch = RegExp('P:(.*?);').firstMatch(qrData);
    final password = passwordMatch?.group(1) ?? '';

    return (ssid: ssid, password: password);
  }
}
