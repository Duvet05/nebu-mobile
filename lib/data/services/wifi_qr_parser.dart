/// Parses WiFi credentials from QR code data.
///
/// Standard format: `WIFI:S:<SSID>;T:<TYPE>;P:<PASSWORD>;H:<HIDDEN>;;`
///
/// Handles escaped characters per the spec: `\;` `\:` `\\` `\,`
class WiFiQrParser {
  WiFiQrParser._();

  /// Returns `(ssid, password)` if the QR data is a valid WiFi QR code,
  /// or `null` if the format is not recognized.
  static ({String ssid, String password})? parse(String qrData) {
    if (!qrData.startsWith('WIFI:')) {
      return null;
    }

    final ssid = _extractField(qrData, 'S');
    if (ssid == null) {
      return null;
    }

    final password = _extractField(qrData, 'P') ?? '';

    return (ssid: ssid, password: password);
  }

  /// Extracts a field value, respecting backslash-escaped semicolons.
  static String? _extractField(String data, String key) {
    final prefix = '$key:';
    final startIndex = data.indexOf(prefix);
    if (startIndex == -1) {
      return null;
    }

    final valueStart = startIndex + prefix.length;
    final buffer = StringBuffer();

    for (var i = valueStart; i < data.length; i++) {
      final char = data[i];
      if (char == r'\' && i + 1 < data.length) {
        // Escaped character — consume the next char literally
        buffer.write(data[i + 1]);
        i++;
      } else if (char == ';') {
        // Unescaped semicolon — end of field
        return buffer.toString();
      } else {
        buffer.write(char);
      }
    }

    // Reached end of string without finding unescaped `;`
    return buffer.isEmpty ? null : buffer.toString();
  }
}
