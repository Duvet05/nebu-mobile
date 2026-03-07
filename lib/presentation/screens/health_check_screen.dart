import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/services/health_service.dart';
import '../providers/api_provider.dart';

/// Screen for testing backend connectivity
class HealthCheckScreen extends ConsumerStatefulWidget {
  const HealthCheckScreen({super.key});

  @override
  ConsumerState<HealthCheckScreen> createState() => _HealthCheckScreenState();
}

class _HealthCheckScreenState extends ConsumerState<HealthCheckScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  HealthStatus? _healthStatus;

  Future<void> _checkHealth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _healthStatus = null;
    });

    try {
      final healthService = ref.read(healthServiceProvider);
      final status = await healthService.getDetailedHealthStatus();
      setState(() {
        _healthStatus = status;
        _isLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('health_check.title'.tr()),
    ),
    body: Padding(
      padding: EdgeInsets.all(context.spacing.alertPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _checkHealth,
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.textOnFilled,
                    ),
                  )
                : const Icon(Icons.refresh),
            label: Text(_isLoading ? 'health_check.checking'.tr() : 'health_check.check_button'.tr()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: context.colors.info,
              foregroundColor: context.colors.textOnFilled,
            ),
          ),
          SizedBox(height: context.spacing.panelPadding),
          if (_errorMessage != null)
            Card(
              color: context.colors.errorBg,
              child: Padding(
                padding: EdgeInsets.all(context.spacing.alertPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error, color: context.colors.error),
                        const SizedBox(width: 8),
                        Text(
                          'health_check.error'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.colors.error,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing.titleBottomMarginSm),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: context.colors.error),
                    ),
                  ],
                ),
              ),
            ),
          if (_healthStatus != null)
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(context.spacing.alertPadding),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusHeader(),
                        const Divider(height: 32),
                        _buildInfoSection(),
                        const Divider(height: 32),
                        _buildMemorySection(),
                        const Divider(height: 32),
                        _buildHealthChecksSection(),
                        const Divider(height: 32),
                        _buildPerformanceSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _buildStatusHeader() {
    final status = _healthStatus!;
    final isHealthy = status.status == 'ok';

    return Row(
      children: [
        Icon(
          isHealthy ? Icons.check_circle : Icons.warning,
          color: isHealthy ? context.colors.success : context.colors.warning,
          size: 32,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.service,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Status: ${status.status.toUpperCase()}',
                style: TextStyle(
                  fontSize: 16,
                  color: isHealthy ? context.colors.success : context.colors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    final status = _healthStatus!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'health_check.information'.tr(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: context.spacing.titleBottomMarginSm),
        _buildInfoRow('Version', status.version),
        _buildInfoRow('Environment', status.environment),
        _buildInfoRow('Uptime', _formatUptime(status.uptime)),
        _buildInfoRow('Timestamp', status.timestamp),
      ],
    );
  }

  Widget _buildMemorySection() {
    final memory = _healthStatus!.memory;
    if (memory == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'health_check.memory_usage'.tr(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: context.spacing.titleBottomMarginSm),
        _buildInfoRow('Heap Used', '${memory.heapUsed.toStringAsFixed(2)} MB'),
        _buildInfoRow(
          'Heap Total',
          '${memory.heapTotal.toStringAsFixed(2)} MB',
        ),
        _buildProgressRow('Usage', memory.heapUsedPercent),
      ],
    );
  }

  Widget _buildHealthChecksSection() {
    final checks = _healthStatus!.checks;
    if (checks == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'health_check.health_checks'.tr(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: context.spacing.titleBottomMarginSm),
        _buildCheckRow('Database', checks.database),
        _buildCheckRow('Redis', checks.redis),
        _buildCheckRow('Configuration', checks.configuration),
      ],
    );
  }

  Widget _buildPerformanceSection() {
    final performance = _healthStatus!.performance;
    if (performance == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'health_check.performance'.tr(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: context.spacing.titleBottomMarginSm),
        _buildInfoRow('Response Time', '${performance.responseTime}ms'),
        _buildInfoRow('Process ID', '${performance.pid}'),
        _buildInfoRow('Platform', performance.platform),
        _buildInfoRow('Node Version', performance.nodeVersion),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );

  Widget _buildProgressRow(String label, int percent) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 140,
              child: Text(
                '$label:',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text('$percent%'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percent / 100,
          backgroundColor: context.colors.grey800,
          valueColor: AlwaysStoppedAnimation<Color>(
            percent > 80 ? context.colors.warning : context.colors.info,
          ),
        ),
      ],
    ),
  );

  Widget _buildCheckRow(String label, CheckStatus check) {
    final isHealthy = check.status == 'ok';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Icon(
            isHealthy ? Icons.check_circle : Icons.error,
            color: isHealthy ? context.colors.success : context.colors.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            check.status.toUpperCase(),
            style: TextStyle(
              color: isHealthy ? context.colors.success : context.colors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatUptime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}
