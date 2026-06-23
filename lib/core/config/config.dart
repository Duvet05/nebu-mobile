import 'package:flutter/foundation.dart';

/// Configuración centralizada de la aplicación
/// Úsala en lugar de EnvConfig o AppConfig

/// Configuración única y centralizada
abstract final class Config {
  Config._();

  static const String _defaultEnvironment = kReleaseMode
      ? 'production'
      : 'development';
  static const String _defaultApiBaseUrl =
      'https://api.flow-telligence.com/api/v1';
  static const String _defaultWsBaseUrl =
      'wss://api.flow-telligence.com/api/v1';
  static const String _defaultLivekitUrl = 'wss://livekit.flow-telligence.com';
  static const String _defaultGoogleWebClientId =
      '874117365573-41585jcimi2t77j0bou38e1la0ke8jk6.apps.googleusercontent.com';

  static const String _environment = String.fromEnvironment(
    'ENV',
    defaultValue: _defaultEnvironment,
  );
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: _defaultApiBaseUrl,
  );
  static const String _serverBaseUrl = String.fromEnvironment('SERVER_URL');
  static const String _apiKey = String.fromEnvironment('API_KEY');
  static const String _wsBaseUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: _defaultWsBaseUrl,
  );
  static const String _livekitUrl = String.fromEnvironment(
    'LIVEKIT_URL',
    defaultValue: _defaultLivekitUrl,
  );
  static const String _googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: _defaultGoogleWebClientId,
  );
  static const String _googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '874117365573-426rtdhpadpl4dql8pia22irshjenif8.apps.googleusercontent.com',
  );
  static const String _facebookAppId = String.fromEnvironment(
    'FACEBOOK_APP_ID',
  );
  static const bool _enableDebugLogs = bool.fromEnvironment(
    'ENABLE_DEBUG_LOGS',
    defaultValue: !kReleaseMode,
  );
  static const bool _hasCrashReportingOverride = bool.hasEnvironment(
    'ENABLE_CRASH_REPORTING',
  );
  static const bool _crashReportingOverride = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
  );

  // ============================================
  // Environment
  // ============================================
  static String get environment => _environment;
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';

  // ============================================
  // App Constants
  // ============================================
  static const String appName = 'Nebu Mobile';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration healthTimeout = Duration(seconds: 10);
  static const int maxRetries = 3;
  static const String languageEnglish = 'en';
  static const String languageSpanish = 'es';
  static const List<String> supportedLanguages = ['en', 'es'];
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 500);
  static const String privacyPolicyUrl =
      'https://nebu.flow-telligence.com/privacy';
  static const String deleteAccountUrl =
      'https://nebu.flow-telligence.com/privacy/delete-account';
  static const String deleteDataUrl =
      'https://nebu.flow-telligence.com/privacy/delete-data';

  // ============================================
  // Backend API
  // ============================================
  /// URL del API - Valores por defecto seguros para producción y desarrollo
  static String get apiBaseUrl => _apiBaseUrl;

  /// Server root URL (no /api/v1 prefix) — used by health endpoints.
  static String get serverBaseUrl =>
      _serverBaseUrl.isNotEmpty ? _serverBaseUrl : _originFromUrl(apiBaseUrl);

  static String get apiKey => _apiKey;
  static String get wsUrl => _wsBaseUrl;

  /// URL del WebSocket en producción
  static String get wsBaseUrl => _wsBaseUrl;

  // ============================================
  // LiveKit
  // ============================================
  static String get livekitUrl => _livekitUrl;
  static String get livekitApiKey => '';
  static String get livekitApiSecret => '';

  // ============================================
  // Social Auth
  // ============================================
  static String get googleWebClientId => _googleWebClientId;
  static String get googleIosClientId => _googleIosClientId;
  static String get facebookAppId => _facebookAppId;

  // ============================================
  // Debug & Logging
  // ============================================
  static bool get enableDebugLogs => _enableDebugLogs;
  static bool get enableCrashReporting =>
      _hasCrashReportingOverride ? _crashReportingOverride : kReleaseMode;

  // ============================================
  // Validation
  // ============================================
  /// Validar que la configuración esencial está presente
  static void validate() {
    final errors = <String>[];

    if (apiBaseUrl.isEmpty) {
      errors.add('API_URL not configured');
    }

    if (livekitUrl.isEmpty) {
      errors.add('LIVEKIT_URL not configured');
    }

    if (errors.isNotEmpty) {
      throw Exception(
        'Invalid configuration:\n${errors.join('\n')}\n\n'
        'Development: Use --dart-define overrides when needed\n'
        'Production: Configure GitHub Variables/Secrets and --dart-define',
      );
    }
  }

  /// Información de debug para logs
  static String getDebugInfo() => '''
[Nebu] env=$environment | api=$apiBaseUrl | debug=$enableDebugLogs''';

  static String _originFromUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme.isEmpty || uri.authority.isEmpty) {
      return value;
    }

    return '${uri.scheme}://${uri.authority}';
  }
}
