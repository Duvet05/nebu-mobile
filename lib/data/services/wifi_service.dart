import 'dart:async';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'esp32_wifi_config_service.dart';

/// Red WiFi
class WiFiNetwork {
  const WiFiNetwork({
    required this.ssid,
    required this.rssi,
    required this.security,
    required this.frequency,
    this.isConnected = false,
  });

  factory WiFiNetwork.fromJson(Map<String, dynamic> json) => WiFiNetwork(
    ssid: json['ssid'] as String,
    rssi: json['rssi'] as int,
    security: json['security'] as String,
    frequency: json['frequency'] as int,
    isConnected: json['isConnected'] as bool? ?? false,
  );
  final String ssid;
  final int rssi;
  final String security; // 'Open' | 'WPA' | 'WPA2' | 'WPA3' | 'WEP'
  final int frequency;
  final bool isConnected;

  Map<String, dynamic> toJson() => {
    'ssid': ssid,
    'rssi': rssi,
    'security': security,
    'frequency': frequency,
    'isConnected': isConnected,
  };
}

/// Credenciales WiFi
class WiFiCredentials {
  const WiFiCredentials({required this.ssid, required this.password});

  factory WiFiCredentials.fromJson(Map<String, dynamic> json) =>
      WiFiCredentials(
        ssid: json['ssid'] as String,
        password: json['password'] as String,
      );
  final String ssid;
  final String password;

  Map<String, dynamic> toJson() => {'ssid': ssid, 'password': password};
}

/// Resultado de conexión WiFi
class WiFiConnectionResult {
  const WiFiConnectionResult({
    required this.success,
    required this.message,
    this.connectedNetwork,
  });

  factory WiFiConnectionResult.fromJson(Map<String, dynamic> json) =>
      WiFiConnectionResult(
        success: json['success'] as bool,
        message: json['message'] as String,
        connectedNetwork: json['connectedNetwork'] != null
            ? WiFiNetwork.fromJson(
                json['connectedNetwork'] as Map<String, dynamic>,
              )
            : null,
      );
  final bool success;
  final String message;
  final WiFiNetwork? connectedNetwork;

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'connectedNetwork': connectedNetwork?.toJson(),
  };
}

/// Servicio WiFi
class WiFiService {
  WiFiService({
    required Logger logger,
    required ESP32WifiConfigService esp32WifiConfigService,
  }) : _logger = logger,
       _esp32WifiConfigService = esp32WifiConfigService;
  final Logger _logger;
  final ESP32WifiConfigService _esp32WifiConfigService;

  bool _isScanning = false;
  WiFiNetwork? _currentNetwork;

  // Streams para notificaciones
  final StreamController<List<WiFiNetwork>> _networksController =
      StreamController<List<WiFiNetwork>>.broadcast();
  final StreamController<WiFiConnectionResult> _connectionController =
      StreamController<WiFiConnectionResult>.broadcast();

  /// Escanear redes WiFi disponibles
  Future<List<WiFiNetwork>> scanNetworks() async {
    if (_isScanning) {
      _logger.w('WiFi scan already in progress');
      return [];
    }

    try {
      _isScanning = true;

      // Solicitar permisos de ubicación (necesario para escanear WiFi en Android)
      final locationPermission = await Permission.location.request();
      if (!locationPermission.isGranted) {
        throw Exception('Location permission required for WiFi scanning');
      }

      final wifiScan = WiFiScan.instance;

      // Verificar si el escaneo esta soportado
      final canStartScan = await wifiScan.canStartScan();
      if (canStartScan != CanStartScan.yes) {
        _logger.w('WiFi scan not supported: $canStartScan');
        throw Exception('WiFi scanning is not supported on this device');
      }

      // Iniciar escaneo
      final startResult = await wifiScan.startScan();
      if (!startResult) {
        _logger.w('WiFi scan failed to start');
        throw Exception('Failed to start WiFi scan');
      }

      // Esperar a que el OS complete el escaneo
      await Future<void>.delayed(const Duration(seconds: 3));

      // Obtener resultados
      final canGetResults = await wifiScan.canGetScannedResults();
      if (canGetResults != CanGetScannedResults.yes) {
        _logger.w('Cannot get scan results: $canGetResults');
        throw Exception('Cannot retrieve WiFi scan results');
      }

      final accessPoints = await wifiScan.getScannedResults();

      // Mapear a WiFiNetwork, filtrar SSIDs vacios, 5GHz y deduplicar
      final networkMap = <String, WiFiNetwork>{};
      for (final ap in accessPoints) {
        if (ap.ssid.isEmpty) {
          continue;
        }
        // ESP32 solo soporta 2.4GHz (frecuencias < 3000 MHz)
        if (ap.frequency >= 3000) {
          continue;
        }
        final existing = networkMap[ap.ssid];
        if (existing == null || ap.level > existing.rssi) {
          networkMap[ap.ssid] = WiFiNetwork(
            ssid: ap.ssid,
            rssi: ap.level,
            security: ap.capabilities.contains('WPA3')
                ? 'WPA3'
                : ap.capabilities.contains('WPA2')
                ? 'WPA2'
                : ap.capabilities.contains('WPA')
                ? 'WPA'
                : ap.capabilities.contains('WEP')
                ? 'WEP'
                : 'Open',
            frequency: ap.frequency,
          );
        }
      }

      final networks = networkMap.values.toList()
        ..sort((a, b) => b.rssi.compareTo(a.rssi));

      _logger.i('Found ${networks.length} WiFi networks');
      _networksController.add(networks);
      return networks;
    } catch (e) {
      _logger.e('Error scanning WiFi networks: $e');
      rethrow;
    } finally {
      _isScanning = false;
    }
  }

  /// Enviar credenciales WiFi al ESP32 via BLE para que se conecte a la red
  Future<WiFiConnectionResult> connectToNetwork(
    WiFiCredentials credentials,
  ) async {
    try {
      _logger.i('Sending WiFi credentials to ESP32: ${credentials.ssid}');

      final configResult = await _esp32WifiConfigService.sendWifiCredentials(
        ssid: credentials.ssid,
        password: credentials.password,
      );

      if (!configResult.success) {
        final result = WiFiConnectionResult(
          success: false,
          message: configResult.message,
        );
        _connectionController.add(result);
        return result;
      }

      // Esperar a que el ESP32 reporte su estado de conexión
      final status = await _esp32WifiConfigService.statusStream
          .where(
            (s) =>
                s == ESP32WifiStatus.connected || s == ESP32WifiStatus.failed,
          )
          .first
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              _logger.w('Timeout waiting for ESP32 WiFi connection status');
              return ESP32WifiStatus.failed;
            },
          );

      final success = status == ESP32WifiStatus.connected;

      final result = WiFiConnectionResult(
        success: success,
        message: success
            ? 'ESP32 connected to ${credentials.ssid}'
            : 'ESP32 failed to connect to ${credentials.ssid}',
        connectedNetwork: success
            ? WiFiNetwork(
                ssid: credentials.ssid,
                rssi: 0,
                security: 'WPA2',
                frequency: 2400,
                isConnected: true,
              )
            : null,
      );

      if (success) {
        _currentNetwork = result.connectedNetwork;
      }

      _connectionController.add(result);
      return result;
    } on Exception catch (e) {
      _logger.e('Error sending WiFi credentials to ESP32: $e');
      final result = WiFiConnectionResult(
        success: false,
        message: 'Failed to configure ESP32 WiFi: $e',
      );
      _connectionController.add(result);
      return result;
    }
  }

  /// Obtener red actual conectada
  WiFiNetwork? get currentNetwork => _currentNetwork;

  /// Verificar si está conectado
  bool get isConnected => _currentNetwork != null;

  /// Verificar si está escaneando
  bool get isScanning => _isScanning;

  /// Obtener información de la red actual
  Map<String, dynamic>? get currentNetworkInfo {
    if (_currentNetwork == null) {
      return null;
    }

    return {
      'ssid': _currentNetwork!.ssid,
      'rssi': _currentNetwork!.rssi,
      'security': _currentNetwork!.security,
      'frequency': _currentNetwork!.frequency,
      'signalStrength': _getSignalStrength(_currentNetwork!.rssi),
      'isConnected': true,
    };
  }

  /// Calcular fuerza de señal basada en RSSI
  String _getSignalStrength(int rssi) {
    if (rssi >= -30) {
      return 'excellent';
    }
    if (rssi >= -50) {
      return 'good';
    }
    if (rssi >= -70) {
      return 'fair';
    }
    if (rssi >= -80) {
      return 'weak';
    }
    return 'very_weak';
  }

  /// Stream de redes encontradas
  Stream<List<WiFiNetwork>> get networksStream => _networksController.stream;

  /// Stream de resultados de conexión
  Stream<WiFiConnectionResult> get connectionStream =>
      _connectionController.stream;

  /// Solicitar permisos necesarios
  Future<bool> requestPermissions() async {
    try {
      final locationStatus = await Permission.location.request();

      if (!locationStatus.isGranted) {
        _logger.w('Location permission was not granted');
      }

      return locationStatus.isGranted;
    } on Exception catch (e) {
      _logger.e('Error requesting permissions: $e');
      return false;
    }
  }

  /// Cerrar servicio
  Future<void> dispose() async {
    await _networksController.close();
    await _connectionController.close();
    _logger.i('WiFi Service disposed');
  }
}
