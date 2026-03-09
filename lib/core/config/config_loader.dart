import 'package:logger/logger.dart';

import 'config.dart';

final _logger = Logger();

/// Helper para cargar configuración
abstract final class ConfigLoader {
  ConfigLoader._();

  /// Inicializar configuración
  /// - En desarrollo: Usa valores por defecto locales (localhost:3000)
  /// - En producción: Usa URL de producción
  static Future<void> initialize() async {
    // Validar configuración
    Config.validate();

    // Mostrar info de debug en desarrollo
    if (Config.enableDebugLogs) {
      _logger.d(Config.getDebugInfo());
    }
  }
}
