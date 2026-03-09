import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/bluetooth_provider.dart';
import '../providers/device_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final user = ref.watch(authProvider).value;
    final greeting = user?.name != null
        ? 'home.greeting_name'.tr(args: [user!.name!])
        : 'home.greeting_default'.tr();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.spacing.alertPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting + settings
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () =>
                        context.push(AppRoutes.settings.path),
                  ),
                ],
              ),

              SizedBox(height: context.spacing.panelPadding),

              // Hero gradient card
              _buildHeroCard(context, ref, theme),

              SizedBox(height: context.spacing.panelPadding),

              // My Toys Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'home.my_active_toys'.tr(),
                    style: theme.textTheme.titleLarge,
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.connectionSetup.path),
                    icon: const Icon(Icons.add),
                    label: Text('home.add_toy'.tr()),
                  ),
                ],
              ),

              SizedBox(height: context.spacing.sectionTitleBottomMargin),

              // Active Toys List
              _buildActiveToysList(context, ref),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, WidgetRef ref, ThemeData theme) {
    final connectedDevices = ref.watch(connectedDevicesProvider);
    final deviceCount = connectedDevices.when(
      data: (devices) => devices.length,
      loading: () => 0,
      error: (_, _) => 0,
    );

    final hasDevices = deviceCount > 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.spacing.panelPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.primary, context.colors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: context.radius.panel,
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasDevices
                      ? 'home.toys_connected'
                          .tr(args: [deviceCount.toString()])
                      : 'home.no_toys_hero'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: context.colors.textOnFilled,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasDevices
                      ? 'home.all_good'.tr()
                      : 'home.no_toys_hero_hint'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.colors.textOnFilled.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.smart_toy,
            size: 48,
            color: context.colors.textOnFilled.withValues(alpha: 0.85),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveToysList(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final connectedDevices = ref.watch(connectedDevicesProvider);

    return connectedDevices.when(
      data: (devices) {
        if (devices.isEmpty) {
          return _buildNoToysPlaceholder(context, theme);
        }

        return Column(
          children: devices
              .map((device) => _DeviceBatteryCard(device: device))
              .toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _buildErrorBanner(
        context,
        theme,
        'home.devices_error'.tr(),
      ),
    );
  }

  Widget _buildErrorBanner(
          BuildContext context, ThemeData theme, String message) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: context.radius.tile,
          border: Border.all(
            color: theme.colorScheme.error.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 32,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget _buildNoToysPlaceholder(BuildContext context, ThemeData theme) =>
      SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.primary.withValues(alpha: 0.04),
                context.colors.secondary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: context.radius.panel,
          ),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary.withValues(alpha: 0.08),
                      context.colors.secondary.withValues(alpha: 0.08),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.smart_toy_outlined,
                  size: 40,
                  color: context.colors.primary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'home.no_toys'.tr(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'home.no_toys_hint'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
            ],
          ),
        ),
      );
}

class _DeviceBatteryCard extends ConsumerWidget {
  const _DeviceBatteryCard({required this.device});

  final fbp.BluetoothDevice device;

  IconData _batteryIcon(int level) {
    if (level > 80) {
      return Icons.battery_full;
    }
    if (level > 50) {
      return Icons.battery_5_bar;
    }
    if (level > 20) {
      return Icons.battery_3_bar;
    }
    return Icons.battery_alert;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final batteryLevel = ref.watch(batteryLevelProvider(device));

    return Container(
      margin:
          EdgeInsets.only(bottom: context.spacing.paragraphBottomMarginSm),
      padding: EdgeInsets.all(context.spacing.alertPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: context.radius.panel,
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: context.radius.tile,
            ),
            child: Icon(
              Icons.bluetooth_connected,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(width: 12),
          // Name + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.platformName.isNotEmpty
                      ? device.platformName
                      : 'home.unknown_device'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: context.colors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'home.connected'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.colors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Battery
          batteryLevel.when(
            data: (level) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _batteryIcon(level),
                  size: 20,
                  color: level > 20
                      ? context.colors.success
                      : context.colors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  '$level%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            error: (error, stack) =>
                Icon(Icons.error_outline, color: context.colors.error),
          ),
        ],
      ),
    );
  }
}

