/// Centralized validation rules for the app.
/// Use these instead of hardcoding validation values in screens/services.
abstract final class ValidationRules {
  ValidationRules._();

  // --- Password ---
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 128;

  /// Backend requires at least one lowercase, one uppercase, and one digit.
  static final RegExp passwordPattern = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)');

  /// Returns null if valid, or an i18n error key if invalid.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'auth.password_required';
    }
    if (value.length < passwordMinLength) {
      return 'auth.password_short';
    }
    if (value.length > passwordMaxLength) {
      return 'auth.password_too_long';
    }
    if (!passwordPattern.hasMatch(value)) {
      return 'auth.password_weak';
    }
    return null;
  }

  // --- WiFi (WPA2 standards) ---
  static const int wifiSsidMaxBytes = 32;
  static const int wifiPasswordMinLength = 8;
  static const int wifiPasswordMaxLength = 63;

  // --- Toy ---
  static const int toyNameMinLength = 2;
  static const int toyNameMaxLength = 50;
}
