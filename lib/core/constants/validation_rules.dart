import '../utils/content_filter.dart';

/// Centralized validation rules for the app.
/// Use these instead of hardcoding validation values in screens/services.
abstract final class ValidationRules {
  ValidationRules._();

  // --- Password ---
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 128;

  /// Backend requires at least one lowercase, one uppercase, and one digit.
  static final RegExp passwordPattern = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
  );

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

  // --- Name (first / last) ---
  static const int nameMinLength = 2;
  static const int nameMaxLength = 50;

  /// Only letters, spaces, hyphens, apostrophes (covers accented chars).
  static final RegExp namePattern = RegExp(r"^[\p{L}\s'\-]+$", unicode: true);

  /// Returns null if valid, or an i18n error key if invalid.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'profile.name_required';
    }
    if (value.trim().length < nameMinLength) {
      return 'profile.name_short';
    }
    if (value.trim().length > nameMaxLength) {
      return 'profile.name_long';
    }
    if (!namePattern.hasMatch(value.trim())) {
      return 'profile.name_invalid_chars';
    }
    return null;
  }

  // --- Toy ---
  static const int toyNameMinLength = 2;
  static const int toyNameMaxLength = 50;

  /// Returns null if valid, or an i18n error key if invalid.
  static String? validateToyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'setup.toy_name.validation_empty';
    }
    if (value.trim().length < toyNameMinLength) {
      return 'setup.toy_name.validation_short';
    }
    if (value.trim().length > toyNameMaxLength) {
      return 'setup.toy_name.validation_long';
    }
    if (ContentFilter.containsProfanity(value)) {
      return 'setup.toy_name.validation_inappropriate';
    }
    return null;
  }
}
