/// Centralized validation rules for the app.
/// Use these instead of hardcoding validation values in screens/services.
abstract final class ValidationRules {
  ValidationRules._();

  // --- Password ---
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 128;

  // --- WiFi (WPA2 standards) ---
  static const int wifiSsidMaxBytes = 32;
  static const int wifiPasswordMinLength = 8;
  static const int wifiPasswordMaxLength = 63;

  // --- Toy ---
  static const int toyNameMinLength = 2;
  static const int toyNameMaxLength = 50;
}
