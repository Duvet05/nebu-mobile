import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/services/health_service.dart';
import '../providers/api_provider.dart';
import '../widgets/custom_button.dart';

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
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(title: Text('health_check.title'.tr())),
      body: Padding(
        padding: EdgeInsets.all(context.spacing.alertPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomButton(
              text: _isLoading
                  ? 'health_check.checking'.tr()
                  : 'health_check.check_button'.tr(),
              onPressed: _isLoading ? null : _checkHealth,
              icon: _isLoading ? null : Icons.refresh,
              isLoading: _isLoading,
              isFullWidth: true,
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
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.error,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.spacing.titleBottomMarginSm),
                      Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.colors.error,
                        ),
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
                          _buildStatusHeader(theme),
                          const Divider(height: 32),
                          _buildInfoSection(theme),
                          const Divider(height: 32),
                          _buildMemorySection(theme),
                          const Divider(height: 32),
                          _buildHealthChecksSection(theme),
                          const Divider(height: 32),
                          _buildPerformanceSection(theme),
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
  }

  Widget _buildStatusHeader(ThemeData theme) {
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
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Status: ${status.status.toUpperCase()}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isHealthy
                      ? context.colors.success
                      : context.colors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(ThemeData theme) {
    final status = _healthStatus!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'health_check.information'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.spacing.titleBottomMarginSm),
        _buildInfoRow(theme, 'Version', status.version),
        _buildInfoRow(theme, 'Environment', status.environment),
        _buildInfoRow(theme, 'Uptime', _formatUptime(status.uptime)),
        _buildInfoRow(theme, 'Timestamp', status.timestamp),
      ],
    );
  }

  Widget _buildMemorySection(ThemeData theme) {
    final memory = _healthStatus!.memory;
    if (memory == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'health_check.memory_usage'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.spacing.titleBottomMarginSm),
        _buildInfoRow(
          theme,
          'Heap Used',
          '${memory.heapUsed.toStringAsFixed(2)} MB',
        ),
        _buildInfoRow(
          theme,
          'Heap Total',
          '${memory.heapTotal.toStringAsFixed(2)} MB',
        ),
        _buildProgressRow(theme, 'Usage', memory.heapUsedPercent),
      ],
    );
  }

  Widget _buildHealthChecksSection(ThemeData theme) {
    final checks = _healthStatus!.checks;
    if (checks == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'health_check.health_checks'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.spacing.titleBottomMarginSm),
        _buildCheckRow(theme, 'Database', checks.database),
        _buildCheckRow(theme, 'Redis', checks.redis),
        _buildCheckRow(theme, 'Configuration', checks.configuration),
      ],
    );
  }

  Widget _buildPerformanceSection(ThemeData theme) {
    final performance = _healthStatus!.performance;
    if (performance == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'health_check.performance'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.spacing.titleBottomMarginSm),
        _buildInfoRow(theme, 'Response Time', '${performance.responseTime}ms'),
        _buildInfoRow(theme, 'Process ID', '${performance.pid}'),
        _buildInfoRow(theme, 'Platform', performance.platform),
        _buildInfoRow(theme, 'Node Version', performance.nodeVersion),
      ],
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
      ],
    ),
  );

  Widget _buildProgressRow(ThemeData theme, String label, int percent) =>
      Padding(
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
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text('$percent%', style: theme.textTheme.bodyMedium),
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

  Widget _buildCheckRow(ThemeData theme, String label, CheckStatus check) {
    final isHealthy = check.status == 'ok';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
            style: theme.textTheme.bodyMedium?.copyWith(
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
