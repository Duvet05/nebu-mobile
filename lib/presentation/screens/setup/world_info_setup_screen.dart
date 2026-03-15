import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/toy.dart';
import '../../providers/api_provider.dart';
import '../../providers/auth_provider.dart' as auth_provider;
import '../../providers/person_provider.dart';
import '../../providers/toy_provider.dart';
import '../../widgets/setup_widgets.dart';

class WorldInfoSetupScreen extends ConsumerWidget {
  const WorldInfoSetupScreen({super.key});

  Future<void> _finishSetup(BuildContext context, WidgetRef ref) async {
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );
    final logger = ref.read(loggerProvider);

    final deviceRegistered =
        prefs.getBool(StorageKeys.setupDeviceRegistered) ?? false;
    final personalityId = prefs.getString(StorageKeys.setupPersonalityId);

    // Read all setup preferences collected during the wizard
    final childAge = prefs.getString(StorageKeys.setupChildAge);
    final voicePreference = prefs.getString(StorageKeys.setupVoicePreference);
    final favoritesJson = prefs.getString(StorageKeys.setupFavorites);
    final List<String> favorites = favoritesJson != null
        ? (json.decode(favoritesJson) as List<dynamic>).cast<String>()
        : [];

    // Build settings map with collected preferences
    final Map<String, dynamic> setupSettings = {
      'childAge': ?childAge,
      'voicePreference': ?voicePreference,
      if (favorites.isNotEmpty) 'interests': favorites,
    };

    if (deviceRegistered) {
      // Toy was registered at step 3 — PATCH it with personality + settings
      // and create a Person (child) to link as owner
      try {
        final toys = ref.read(toyProvider).value;
        if (toys != null && toys.isNotEmpty) {
          final toy = toys.last;
          final hasPersonality =
              personalityId != null && personalityId.isNotEmpty;
          final hasSettings = setupSettings.isNotEmpty;

          // Create a Person (child) for the toy owner so the agent
          // receives proper context (name, age, interests).
          // Estimate birthDate from the age-range selection.
          String? ownerId;
          final authState = ref.read(auth_provider.authProvider);
          if (authState.value != null) {
            try {
              final birthDate = _estimateBirthDate(childAge);
              final child = await ref
                  .read(personProvider.notifier)
                  .createPerson(
                    givenName: 'Mi niño',
                    birthDate: birthDate,
                  );
              ownerId = child.id;
              logger.d('Child Person created: ${child.id}');
            } on Exception catch (e) {
              logger.e('Failed to create child Person: $e');
              // Non-blocking — toy settings still get applied below
            }
          }

          if (hasPersonality || hasSettings || ownerId != null) {
            await ref
                .read(toyProvider.notifier)
                .updateToy(
                  id: toy.id,
                  personalityProfile: hasPersonality ? personalityId : null,
                  settings: hasSettings ? setupSettings : null,
                  ownerId: ownerId,
                );
            logger.d(
              'Setup preferences applied to toy: '
              'personality=$personalityId, settings=$setupSettings, '
              'ownerId=$ownerId',
            );
          }
        }
      } on Exception catch (e) {
        logger.e('Failed to apply setup preferences to toy: $e');
        // Non-blocking — toy was created, preferences can be set later
      }
    } else {
      // Device was NOT registered — save as local toy with pending status
      final toyName = prefs.getString(StorageKeys.setupToyName) ?? 'My Nebu';

      final localToy = Toy(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        name: toyName,
        status: ToyStatus.pending,
        model: 'Nebu',
        manufacturer: 'NEBU',
        personalityProfile: personalityId,
        settings: setupSettings.isNotEmpty ? setupSettings : null,
        createdAt: DateTime.now(),
      );

      await ref.read(toyProvider.notifier).saveLocalToy(localToy);
    }

    // Clean up temporary setup flags in parallel
    await Future.wait([
      prefs.remove(StorageKeys.setupDeviceRegistered),
      prefs.remove(StorageKeys.setupPersonalityId),
      prefs.remove(StorageKeys.setupChildAge),
      prefs.remove(StorageKeys.setupVoicePreference),
      prefs.remove(StorageKeys.setupFavorites),
      prefs.setBool(StorageKeys.setupCompleted, true),
    ]);

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
                    SizedBox(height: context.spacing.gapXl),
                    _buildFeatureSummary(
                      context,
                      theme,
                      Icons.check_circle,
                      'setup.world_info.profile_configured'.tr(),
                    ),
                    SizedBox(height: context.spacing.gapXl),
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

  /// Estimate a birthDate from the age-range string selected in setup.
  /// Uses the midpoint of each range so Person.age is approximately correct.
  static DateTime? _estimateBirthDate(String? ageRange) {
    if (ageRange == null) return null;
    final int midAge;
    switch (ageRange) {
      case '3-5':
        midAge = 4;
      case '6-8':
        midAge = 7;
      case '9-12':
        midAge = 10;
      case '13+':
        midAge = 14;
      default:
        return null;
    }
    final now = DateTime.now();
    return DateTime(now.year - midAge, now.month, now.day);
  }

  Widget _buildFeatureSummary(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String text,
  ) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: context.colors.primary, size: 24),
      SizedBox(width: context.spacing.gapLg),
      Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
    ],
  );
}
