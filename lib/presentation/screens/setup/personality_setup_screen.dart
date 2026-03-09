import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/personality.dart';
import '../../providers/auth_provider.dart' as auth_provider;
import '../../providers/personality_provider.dart';
import '../../widgets/setup_widgets.dart';

class PersonalitySetupScreen extends ConsumerStatefulWidget {
  const PersonalitySetupScreen({super.key});

  @override
  ConsumerState<PersonalitySetupScreen> createState() =>
      _PersonalitySetupScreenState();
}

class _PersonalitySetupScreenState
    extends ConsumerState<PersonalitySetupScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _loadSavedSelection();
  }

  Future<void> _loadSavedSelection() async {
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );
    final saved = prefs.getString(StorageKeys.setupPersonalityId);
    if (saved != null && saved.isNotEmpty && mounted) {
      setState(() {
        _selectedId = saved;
      });
    }
  }

  Future<void> _saveAndContinue() async {
    if (_selectedId == null) {
      return;
    }

    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );
    await prefs.setString(StorageKeys.setupPersonalityId, _selectedId!);

    if (mounted) {
      await context.push(AppRoutes.voiceSetup.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final personalitiesAsync = ref.watch(personalitiesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SetupHeader(currentStep: 5, totalSteps: 7),

            Expanded(
              child: Padding(
                padding: context.spacing.pageEdgeInsets,
                child: Column(
                  children: [
                    SizedBox(height: context.spacing.titleBottomMargin),

                    Text(
                      'setup.personality.title'.tr(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.spacing.titleBottomMarginSm),
                    Text(
                      'setup.personality.subtitle'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: context.spacing.largePageBottomMargin),

                    // Personality list from backend
                    Expanded(
                      child: personalitiesAsync.when(
                        loading: () => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: context.colors.primary,
                              ),
                              SizedBox(
                                height: context.spacing.titleBottomMarginSm,
                              ),
                              Text(
                                'setup.personality.loading'.tr(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        error: (error, _) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: context.colors.error,
                              ),
                              SizedBox(
                                height: context.spacing.titleBottomMarginSm,
                              ),
                              Text(
                                'setup.personality.error_loading'.tr(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: context.spacing.titleBottomMarginSm,
                              ),
                              SetupPrimaryButton(
                                text: 'common.retry'.tr(),
                                onPressed: () =>
                                    ref.invalidate(personalitiesProvider),
                              ),
                            ],
                          ),
                        ),
                        data: (personalities) {
                          if (personalities.isEmpty) {
                            return Center(
                              child: Text(
                                'setup.personality.empty'.tr(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: personalities.length,
                            itemBuilder: (context, index) =>
                                _buildPersonalityCard(
                                  context,
                                  personalities[index],
                                ),
                          );
                        },
                      ),
                    ),

                    SetupPrimaryButton(
                      text: 'setup.personality.next'.tr(),
                      isEnabled: _selectedId != null,
                      onPressed: _saveAndContinue,
                    ),

                    SizedBox(height: context.spacing.sectionTitleBottomMargin),

                    SetupSkipButton(
                      onTap: () => context.go(AppRoutes.home.path),
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

  Widget _buildPersonalityCard(BuildContext context, Personality personality) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedId == personality.id;

    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing.panelPadding),
      child: GestureDetector(
        onTap: () => setState(() => _selectedId = personality.id),
        child: Container(
          padding: EdgeInsets.all(context.spacing.panelPadding),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.primary.withValues(alpha: 0.08)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: context.radius.panel,
            border: Border.all(
              color: isSelected ? context.colors.primary : colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primary.withValues(alpha: 0.15)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: context.radius.panel,
                ),
                child: Icon(
                  _iconForPersonality(personality.id),
                  size: 24,
                  color: isSelected
                      ? context.colors.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(width: context.spacing.panelPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      personality.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? context.colors.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: context.spacing.labelBottomMargin),
                    Text(
                      personality.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? context.colors.primary.withValues(alpha: 0.7)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: context.colors.textOnFilled,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForPersonality(String id) => switch (id) {
    'mexican' => Icons.celebration_rounded,
    'peruvian' => Icons.terrain_rounded,
    'kpop' => Icons.music_note_rounded,
    'roblox' => Icons.sports_esports_rounded,
    _ => Icons.smart_toy_rounded,
  };
}
