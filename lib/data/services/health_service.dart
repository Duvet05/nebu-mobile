import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../core/config/config.dart';

/// Service for checking backend health and connectivity.
/// Uses Dio directly (not ApiService) because health does not require auth.
class HealthService {
  HealthService({required Logger logger}) : _logger = logger;

  final Logger _logger;

  /// Check backend health status
  /// Hits GET /health at server root (NOT under /api/v1)
  Future<Map<String, dynamic>> checkHealth() async {
    final healthUrl = Config.apiBaseUrl.replaceAll('/api/v1', '');
    _logger.i('Checking backend health at $healthUrl/health');
    final dio = Dio(
      BaseOptions(
        connectTimeout: Config.healthTimeout,
        receiveTimeout: Config.healthTimeout,
        sendTimeout: Config.healthTimeout,
      ),
    );
    final response = await dio.get<Map<String, dynamic>>('$healthUrl/health');
    final data = response.data!;
    _logger.i('Backend health check successful: ${data['status']}');
    return data;
  }

  /// Check if backend is ready
  /// Returns true if backend is ready, false otherwise
  Future<bool> isBackendReady() async {
    try {
      final response = await checkHealth();
      return response['status'] == 'ok';
    } on Exception catch (e) {
      _logger.e('Backend readiness check failed: $e');
      return false;
    }
  }

  /// Get detailed health status with all checks
  Future<HealthStatus> getDetailedHealthStatus() async {
    try {
      final response = await checkHealth();
      return HealthStatus.fromJson(response);
    } on Exception catch (e) {
      _logger.e('Failed to get detailed health status: $e');
      rethrow;
    }
  }
}

/// Detailed health status model
class HealthStatus {
  HealthStatus({
    required this.status,
    required this.timestamp,
    required this.service,
    required this.version,
    required this.environment,
    required this.uptime,
    this.memory,
    this.checks,
    this.performance,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> json) => HealthStatus(
    status: json['status'] as String,
    timestamp: json['timestamp'] as String,
    service: json['service'] as String,
    version: json['version'] as String,
    environment: json['environment'] as String,
    uptime: json['uptime'] as int,
    memory: json['memory'] != null
        ? MemoryMetrics.fromJson(json['memory'] as Map<String, dynamic>)
        : null,
    checks: json['checks'] != null
        ? HealthChecks.fromJson(json['checks'] as Map<String, dynamic>)
        : null,
    performance: json['performance'] != null
        ? PerformanceMetrics.fromJson(
            json['performance'] as Map<String, dynamic>,
          )
        : null,
  );

  final String status;
  final String timestamp;
  final String service;
  final String version;
  final String environment;
  final int uptime;
  final MemoryMetrics? memory;
  final HealthChecks? checks;
  final PerformanceMetrics? performance;

  Map<String, dynamic> toJson() => {
    'status': status,
    'timestamp': timestamp,
    'service': service,
    'version': version,
    'environment': environment,
    'uptime': uptime,
    if (memory != null) 'memory': memory!.toJson(),
    if (checks != null) 'checks': checks!.toJson(),
    if (performance != null) 'performance': performance!.toJson(),
  };
}

class MemoryMetrics {
  MemoryMetrics({
    required this.heapUsed,
    required this.heapTotal,
    required this.heapUsedPercent,
  });

  factory MemoryMetrics.fromJson(Map<String, dynamic> json) => MemoryMetrics(
    heapUsed: (json['heapUsed'] as num).toDouble(),
    heapTotal: (json['heapTotal'] as num).toDouble(),
    heapUsedPercent: json['heapUsedPercent'] as int,
  );

  final double heapUsed;
  final double heapTotal;
  final int heapUsedPercent;

  Map<String, dynamic> toJson() => {
    'heapUsed': heapUsed,
    'heapTotal': heapTotal,
    'heapUsedPercent': heapUsedPercent,
  };
}

class HealthChecks {
  HealthChecks({
    required this.database,
    required this.redis,
    required this.configuration,
  });

  factory HealthChecks.fromJson(Map<String, dynamic> json) => HealthChecks(
    database: CheckStatus.fromJson(json['database'] as Map<String, dynamic>),
    redis: CheckStatus.fromJson(json['redis'] as Map<String, dynamic>),
    configuration: CheckStatus.fromJson(
      json['configuration'] as Map<String, dynamic>,
    ),
  );

  final CheckStatus database;
  final CheckStatus redis;
  final CheckStatus configuration;

  Map<String, dynamic> toJson() => {
    'database': database.toJson(),
    'redis': redis.toJson(),
    'configuration': configuration.toJson(),
  };
}

class CheckStatus {
  CheckStatus({required this.status, required this.connected});

  factory CheckStatus.fromJson(Map<String, dynamic> json) => CheckStatus(
    status: json['status'] as String,
    connected: json['connected'] as bool,
  );

  final String status;
  final bool connected;

  Map<String, dynamic> toJson() => {'status': status, 'connected': connected};
}

class PerformanceMetrics {
  PerformanceMetrics({
    required this.responseTime,
    required this.pid,
    required this.platform,
    required this.nodeVersion,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) =>
      PerformanceMetrics(
        responseTime: json['responseTime'] as int,
        pid: json['pid'] as int,
        platform: json['platform'] as String,
        nodeVersion: json['nodeVersion'] as String,
      );

  final int responseTime;
  final int pid;
  final String platform;
  final String nodeVersion;

  Map<String, dynamic> toJson() => {
    'responseTime': responseTime,
    'pid': pid,
    'platform': platform,
    'nodeVersion': nodeVersion,
  };
}
