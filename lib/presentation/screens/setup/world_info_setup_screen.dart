import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/toy.dart';
import '../../providers/auth_provider.dart' as auth_provider;
import '../../providers/toy_provider.dart';
import '../../widgets/setup_widgets.dart';

class WorldInfoSetupScreen extends ConsumerWidget {
  const WorldInfoSetupScreen({super.key});

  Future<void> _finishSetup(BuildContext context, WidgetRef ref) async {
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );

    final deviceRegistered =
        prefs.getBool(StorageKeys.setupDeviceRegistered) ?? false;

    if (!deviceRegistered) {
      // Device was NOT registered in backend — save as local toy with pending status
      final toyName =
          prefs.getString(StorageKeys.setupToyName) ?? 'My Nebu';

      final localToy = Toy(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        name: toyName,
        status: ToyStatus.pending,
        model: 'Nebu',
        manufacturer: 'NEBU',
        createdAt: DateTime.now(),
      );

      await ref.read(toyProvider.notifier).saveLocalToy(localToy);
    }

    // Clean up temporary setup flags
    await prefs.remove(StorageKeys.setupDeviceRegistered);
    await prefs.setBool(StorageKeys.setupCompleted, true);

    if (context.mounted) {
      context.go(AppRoutes.home.path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SetupHeader(currentStep: 7, totalSteps: 7),

            // Content
            Expanded(
              child: Padding(
                padding: context.spacing.pageEdgeInsets,
                child: Column(
                  children: [
                    const Spacer(),

                    // Completion icon
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 60,
                          color: context.colors.primary,
                        ),
                      ),
                    ),

                    SizedBox(height: context.spacing.largePageBottomMargin),

                    // Title
                    Text(
                      'setup.world_info.all_set'.tr(),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: context.spacing.titleBottomMarginSm),

                    Text(
                      'setup.world_info.ready_message'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: context.spacing.largePageBottomMargin),

                    // Features summary
                    _buildFeatureSummary(
                      context,
                      theme,
                      Icons.check_circle,
                      'setup.world_info.device_connected'.tr(),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureSummary(
                      context,
                      theme,
                      Icons.check_circle,
                      'setup.world_info.profile_configured'.tr(),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureSummary(
                      context,
                      theme,
                      Icons.check_circle,
                      'setup.world_info.preferences_saved'.tr(),
                    ),

                    const Spacer(),

                    // Finish button
                    SetupPrimaryButton(
                      text: 'setup.world_info.start_using'.tr(),
                      onPressed: () => _finishSetup(context, ref),
                    ),

                    SizedBox(height: context.spacing.panelPadding),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSummary(
          BuildContext context, ThemeData theme, IconData icon, String text) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: context.colors.primary, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
}
