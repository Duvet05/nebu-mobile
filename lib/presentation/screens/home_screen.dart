import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/config.dart';
import '../../core/config/release_feature_policy.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/bluetooth_provider.dart';
import '../providers/device_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/nebu_dots_loader.dart';

const _homeDinoAsset = 'assets/icons/dino.svg';
const _settingsIconAsset = 'assets/icons/lucide/settings.svg';
const _plusIconAsset = 'assets/icons/lucide/plus.svg';
const _micIconAsset = 'assets/icons/lucide/mic.svg';
const _bookOpenIconAsset = 'assets/icons/lucide/book-open.svg';
const _sparklesIconAsset = 'assets/icons/lucide/sparkles.svg';
const _bluetoothIconAsset = 'assets/icons/lucide/bluetooth-connected.svg';
const _batteryFullIconAsset = 'assets/icons/lucide/battery-full.svg';
const _batteryMediumIconAsset = 'assets/icons/lucide/battery-medium.svg';
const _batteryLowIconAsset = 'assets/icons/lucide/battery-low.svg';
const _batteryWarningIconAsset = 'assets/icons/lucide/battery-warning.svg';
const _alertIconAsset = 'assets/icons/lucide/circle-alert.svg';

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
      backgroundColor: Colors.transparent,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: _HomeSvgIcon(
                      key: const ValueKey('home-settings-icon'),
                      asset: _settingsIconAsset,
                      color: theme.colorScheme.onSurface,
                    ),
                    tooltip: 'nav.settings'.tr(),
                    onPressed: () => context.push(AppRoutes.settings.path),
                  ),
                ],
              ),

              SizedBox(height: context.spacing.panelPadding),

              // My Toys Section
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: context.spacing.gapLg,
                  runSpacing: context.spacing.gapSm,
                  children: [
                    Text(
                      'home.my_active_toys'.tr(),
                      style: theme.textTheme.titleLarge,
                    ),
                    CustomButton(
                      text: 'home.add_toy'.tr(),
                      onPressed: () =>
                          context.push(AppRoutes.connectionSetup.path),
                      leading: _HomeSvgIcon(
                        key: const ValueKey('home-add-toy-icon'),
                        asset: _plusIconAsset,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      variant: ButtonVariant.text,
                      height: 40,
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.spacing.sectionTitleBottomMargin),

              // Active Toys List
              _buildActiveToysList(context, ref),

              if (Config.isFeatureEnabled(ReleaseFeature.homeQuickActions)) ...[
                SizedBox(height: context.spacing.panelPadding),

                // Quick Actions
                Text(
                  'home.quick_actions'.tr(),
                  style: theme.textTheme.titleLarge,
                ),

                SizedBox(height: context.spacing.sectionTitleBottomMargin),

                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        iconAsset: _micIconAsset,
                        iconKey: 'home-quick-action-voice-icon',
                        label: 'home.voice_history'.tr(),
                        color: context.colors.success,
                        onTap: () => context.push(AppRoutes.voiceHistory.path),
                      ),
                    ),
                    SizedBox(width: context.spacing.labelBottomMargin),
                    Expanded(
                      child: _QuickActionCard(
                        iconAsset: _bookOpenIconAsset,
                        iconKey: 'home-quick-action-knowledge-icon',
                        label: 'home.knowledge'.tr(),
                        color: context.colors.warning,
                        onTap: () =>
                            context.push(AppRoutes.knowledgeSearch.path),
                      ),
                    ),
                    SizedBox(width: context.spacing.labelBottomMargin),
                    Expanded(
                      child: _QuickActionCard(
                        iconAsset: _sparklesIconAsset,
                        iconKey: 'home-quick-action-personalities-icon',
                        label: 'home.personalities'.tr(),
                        color: context.colors.secondary,
                        onTap: () => context.push(AppRoutes.personalities.path),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.spacing.panelPadding),
              ],
            ],
          ),
        ),
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
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: NebuDotsLoader(key: ValueKey('home-devices-loader')),
        ),
      ),
      error: (_, _) =>
          _buildErrorBanner(context, theme, 'home.devices_error'.tr()),
    );
  }

  Widget _buildErrorBanner(
    BuildContext context,
    ThemeData theme,
    String message,
  ) => Container(
    padding: EdgeInsets.all(context.spacing.alertPadding),
    decoration: BoxDecoration(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
      borderRadius: context.radius.tile,
      border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HomeSvgIcon(
          key: const ValueKey('home-devices-error-icon'),
          asset: _alertIconAsset,
          color: theme.colorScheme.error,
          size: 32,
        ),
        SizedBox(height: context.spacing.labelBottomMargin),
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
          padding: EdgeInsets.all(context.spacing.panelPadding),
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
                child: Center(
                  child: SvgPicture.asset(
                    _homeDinoAsset,
                    key: const ValueKey('home-empty-dino'),
                    width: 74,
                    height: 82,
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                    excludeFromSemantics: true,
                  ),
                ),
              ),
              SizedBox(height: context.spacing.alertPadding),
              Text(
                'home.no_toys'.tr(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: context.spacing.labelBottomMargin),
              Text(
                'home.no_toys_hint'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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

  String _batteryIconAsset(int level) {
    if (level > 80) {
      return _batteryFullIconAsset;
    }
    if (level > 50) {
      return _batteryMediumIconAsset;
    }
    if (level > 20) {
      return _batteryLowIconAsset;
    }
    return _batteryWarningIconAsset;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final batteryLevel = ref.watch(batteryLevelProvider(device));

    return Container(
      margin: EdgeInsets.only(bottom: context.spacing.paragraphBottomMarginSm),
      padding: EdgeInsets.all(context.spacing.alertPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: context.radius.panel,
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
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
            padding: EdgeInsets.all(context.spacing.paragraphBottomMarginSm),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: context.radius.tile,
            ),
            child: _HomeSvgIcon(
              key: const ValueKey('home-device-bluetooth-icon'),
              asset: _bluetoothIconAsset,
              color: context.colors.primary,
            ),
          ),
          SizedBox(width: context.spacing.paragraphBottomMarginSm),
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
                SizedBox(height: context.spacing.gapXs),
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
                    SizedBox(width: context.spacing.gapSm),
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
                _HomeSvgIcon(
                  key: const ValueKey('home-device-battery-icon'),
                  asset: _batteryIconAsset(level),
                  size: 20,
                  color: level > 20
                      ? context.colors.success
                      : context.colors.error,
                ),
                SizedBox(width: context.spacing.gapXs),
                Text(
                  '$level%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            loading: () => NebuDotsLoader(
              key: const ValueKey('home-device-battery-loader'),
              color: context.colors.primary,
              dotSize: 4,
              gap: 3,
            ),
            error: (error, stack) => _HomeSvgIcon(
              key: const ValueKey('home-device-battery-error-icon'),
              asset: _alertIconAsset,
              color: context.colors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.iconAsset,
    required this.iconKey,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String iconAsset;
  final String iconKey;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.radius.tile,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: context.spacing.paragraphBottomMarginSm,
            horizontal: context.spacing.labelBottomMargin,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: context.radius.tile,
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              _HomeSvgIcon(
                key: ValueKey(iconKey),
                asset: iconAsset,
                color: color,
              ),
              SizedBox(height: context.spacing.labelBottomMargin),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSvgIcon extends StatelessWidget {
  const _HomeSvgIcon({
    required this.asset,
    required this.color,
    super.key,
    this.size = 24,
  });

  final String asset;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    asset,
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    excludeFromSemantics: true,
  );
}
