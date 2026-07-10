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

class WorldInfoSetupScreen extends ConsumerStatefulWidget {
  const WorldInfoSetupScreen({super.key});

  @override
  ConsumerState<WorldInfoSetupScreen> createState() =>
      _WorldInfoSetupScreenState();
}

class _WorldInfoSetupScreenState extends ConsumerState<WorldInfoSetupScreen> {
  bool _isFinishing = false;

  Future<void> _finishSetup() async {
    if (_isFinishing) {
      return;
    }
    setState(() => _isFinishing = true);
    try {
      await _performFinishSetup();
    } on Exception catch (e) {
      ref.read(loggerProvider).e('Failed to finish setup: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('setup.wifi.error_generic'.tr()),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFinishing = false);
      }
    }
  }

  Future<void> _performFinishSetup() async {
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );
    final logger = ref.read(loggerProvider);

    final deviceRegistered =
        prefs.getBool(StorageKeys.setupDeviceRegistered) ?? false;
    final personalityId = prefs.getString(StorageKeys.setupPersonalityId);

    // Read all setup preferences collected during the wizard
    final childName = prefs.getString(StorageKeys.setupChildName)?.trim();
    final childAge = prefs.getString(StorageKeys.setupChildAge);
    final voicePreference = prefs.getString(StorageKeys.setupVoicePreference);
    final favoritesJson = prefs.getString(StorageKeys.setupFavorites);
    final List<String> favorites = favoritesJson != null
        ? (json.decode(favoritesJson) as List<dynamic>).cast<String>()
        : [];

    // Build settings map with collected preferences
    final Map<String, dynamic> setupSettings = {
      if (childName != null && childName.isNotEmpty) 'childName': childName,
      'childAge': ?childAge,
      'voicePreference': ?voicePreference,
      if (favorites.isNotEmpty) 'interests': favorites,
    };

    if (deviceRegistered) {
      // Toy was registered at step 3 — PATCH it with personality + settings
      // and create a Person (child) to link as owner
      try {
        final toys = ref.read(toyProvider).value;
        if (toys == null || toys.isEmpty) {
          throw StateError('Registered setup toy is missing from local state');
        }
        final setupToyId = prefs.getString(StorageKeys.setupToyId);
        Toy? toy;
        if (setupToyId != null) {
          for (final candidate in toys) {
            if (candidate.id == setupToyId) {
              toy = candidate;
              break;
            }
          }
        } else if (toys.length == 1) {
          // Compatibility for a wizard started before setupToyId existed.
          toy = toys.first;
        }
        if (toy == null) {
          throw StateError('Registered setup toy could not be resolved');
        }
        final hasPersonality =
            personalityId != null && personalityId.isNotEmpty;
        final hasSettings = setupSettings.isNotEmpty;

        // Create a Person (child) for the toy owner so the agent
        // receives proper context (name, age, interests).
        // Estimate birthDate from the age-range selection.
        String? ownerId = prefs.getString(StorageKeys.setupOwnerId);
        final authState = ref.read(auth_provider.authProvider);
        if (authState.value != null && ownerId == null) {
          try {
            final birthDate = _estimateBirthDate(childAge);
            final child = await ref
                .read(personProvider.notifier)
                .createPerson(
                  givenName: childName != null && childName.isNotEmpty
                      ? childName
                      : 'setup.world_info.default_child_name'.tr(),
                  birthDate: birthDate,
                );
            ownerId = child.id;
            await prefs.setString(StorageKeys.setupOwnerId, child.id);
            logger.d('Child Person created: ${child.id}');
          } on Exception catch (e) {
            logger.e('Failed to create child Person: $e');
            rethrow;
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
      } on Exception catch (e) {
        logger.e('Failed to apply setup preferences to toy: $e');
        rethrow;
      }
    } else {
      // Device was NOT registered — save as local toy with pending status
      final toyName = prefs.getString(StorageKeys.setupToyName) ?? 'Nebu';

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
      if (childName != null &&
          childName.isNotEmpty &&
          childAge != null &&
          personalityId != null &&
          personalityId.isNotEmpty) {
        await Future.wait([
          prefs.setString(StorageKeys.localChildName, childName),
          prefs.setString(StorageKeys.localChildAge, childAge),
          prefs.setString(StorageKeys.localChildPersonality, personalityId),
          prefs.setBool(StorageKeys.setupCompletedLocally, true),
        ]);
      }
    }

    // Clean up temporary setup flags in parallel
    await Future.wait([
      prefs.remove(StorageKeys.setupDeviceRegistered),
      prefs.remove(StorageKeys.setupToyId),
      prefs.remove(StorageKeys.setupOwnerId),
      prefs.remove(StorageKeys.setupPersonalityId),
      prefs.remove(StorageKeys.setupChildName),
      prefs.remove(StorageKeys.setupChildAge),
      prefs.remove(StorageKeys.setupVoicePreference),
      prefs.remove(StorageKeys.setupFavorites),
      prefs.setBool(StorageKeys.setupCompleted, true),
    ]);

    if (!mounted) {
      return;
    }
    context.go(AppRoutes.home.path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final prefs = ref.watch(auth_provider.sharedPreferencesProvider).value;
    final summaries = <String>[
      if (prefs?.getBool(StorageKeys.setupDeviceRegistered) ?? false)
        'setup.world_info.device_connected'.tr(),
      if ((prefs?.getString(StorageKeys.setupChildName)?.isNotEmpty ?? false) &&
          (prefs?.getString(StorageKeys.setupChildAge)?.isNotEmpty ?? false))
        'setup.world_info.profile_configured'.tr(),
      if ((prefs?.getString(StorageKeys.setupPersonalityId)?.isNotEmpty ??
              false) ||
          (prefs?.getString(StorageKeys.setupVoicePreference)?.isNotEmpty ??
              false) ||
          (prefs?.getString(StorageKeys.setupFavorites)?.isNotEmpty ?? false))
        'setup.world_info.preferences_saved'.tr(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SetupHeader(currentStep: 7, totalSteps: 7),

            // Content
            Expanded(
              child: Padding(
                padding: context.constrainedPageEdgeInsets,
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
                    for (var index = 0; index < summaries.length; index++) ...[
                      if (index > 0) SizedBox(height: context.spacing.gapXl),
                      _buildFeatureSummary(
                        context,
                        theme,
                        Icons.check_circle,
                        summaries[index],
                      ),
                    ],

                    const Spacer(),

                    // Finish button
                    SetupPrimaryButton(
                      text: 'setup.world_info.start_using'.tr(),
                      onPressed: _finishSetup,
                      isEnabled: !_isFinishing,
                      isLoading: _isFinishing,
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
    if (ageRange == null) {
      return null;
    }
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
