import 'package:flutter/foundation.dart';

/// Configuración centralizada de la aplicación
/// Úsala en lugar de EnvConfig o AppConfig

/// Configuración única y centralizada
abstract final class Config {
  Config._();

  // ============================================
  // Environment
  // ============================================
  static String get environment => kDebugMode ? 'development' : 'production';
  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => !kDebugMode;
  static bool get isStaging => false;

  // ============================================
  // App Constants
  // ============================================
  static const String appName = 'Nebu Mobile';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const String languageEnglish = 'en';
  static const String languageSpanish = 'es';
  static const List<String> supportedLanguages = ['en', 'es'];
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 500);
  static const String privacyPolicyUrl = 'https://flow-telligence.com/privacy';
  static const String deleteAccountUrl =
      'https://flow-telligence.com/privacy/delete-account';
  static const String deleteDataUrl =
      'https://flow-telligence.com/privacy/delete-data';

  // ============================================
  // Backend API
  // ============================================
  /// URL del API - Valores por defecto seguros para producción y desarrollo
  static String get apiBaseUrl => isProduction
      ? 'https://api.flow-telligence.com/api/v1' // URL de producción
      : 'http://localhost:3001/api/v1'; // URL de desarrollo local

  static String get apiKey => '';
  static String get wsUrl => '';

  /// URL del WebSocket en producción
  static String get wsBaseUrl => isProduction
      ? 'wss://api.flow-telligence.com/api/v1'
      : 'ws://localhost:3001/api/v1';

  // ============================================
  // LiveKit
  // ============================================
  static String get livekitUrl => isDevelopment
      ? 'ws://localhost:7880'
      : 'wss://livekit-demo.livekit.cloud';
  static String get livekitApiKey => '';
  static String get livekitApiSecret => '';

  // ============================================
  // Social Auth
  // ============================================
  static String get googleWebClientId => '';
  static String get googleIosClientId => '';
  static String get facebookAppId => '';

  // ============================================
  // Debug & Logging
  // ============================================
  static bool get enableDebugLogs => !isProduction;
  static bool get enableCrashReporting => false;

  // ============================================
  // Validation
  // ============================================
  /// Validar que la configuración esencial está presente
  static void validate() {
    final errors = <String>[];

    if (apiBaseUrl.isEmpty) {
      errors.add('❌ API_URL no configurada');
    }

    if (errors.isNotEmpty) {
      throw Exception(
        'Configuración inválida:\n${errors.join('\n')}\n\n'
        'En desarrollo: Verifica tu archivo .env\n'
        'En producción: Usa --dart-define en el build',
      );
    }
  }

  /// Información de debug para logs
  static String getDebugInfo() => '''
[Nebu] env=$environment | api=$apiBaseUrl | debug=$enableDebugLogs''';
}
