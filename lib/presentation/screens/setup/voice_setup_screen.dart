import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart' as auth_provider;
import '../../widgets/setup_widgets.dart';

class VoiceSetupScreen extends ConsumerStatefulWidget {
  const VoiceSetupScreen({super.key});

  @override
  ConsumerState<VoiceSetupScreen> createState() => _VoiceSetupScreenState();
}

class _VoiceSetupScreenState extends ConsumerState<VoiceSetupScreen> {
  String? _selectedVoice;

  final List<Map<String, dynamic>> _voices = [
    {
      'id': 'child_voice',
      'label': 'setup.voice.child_voice',
      'icon': Icons.child_care,
      'description': 'setup.voice.child_voice_desc',
    },
    {
      'id': 'friendly_adult',
      'label': 'setup.voice.friendly_adult',
      'icon': Icons.person,
      'description': 'setup.voice.friendly_adult_desc',
    },
    {
      'id': 'robot_voice',
      'label': 'setup.voice.robot_voice',
      'icon': Icons.smart_toy,
      'description': 'setup.voice.robot_voice_desc',
    },
    {
      'id': 'custom',
      'label': 'setup.voice.custom',
      'icon': Icons.tune,
      'description': 'setup.voice.custom_desc',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final canProceed = _selectedVoice != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SetupHeader(currentStep: 6, totalSteps: 7),

            // Content
            Expanded(
              child: Padding(
                padding: context.spacing.pageEdgeInsets,
                child: Column(
                  children: [
                    SizedBox(height: context.spacing.titleBottomMargin),

                    Text(
                      'setup.voice.title'.tr(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.spacing.titleBottomMarginSm),
                    Text(
                      'setup.voice.subtitle'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: context.spacing.largePageBottomMargin),

                    // Voice options
                    Expanded(
                      child: ListView.builder(
                        itemCount: _voices.length,
                        itemBuilder: (context, index) {
                          final voice = _voices[index];
                          final voiceId = voice['id'] as String;
                          final isSelected = _selectedVoice == voiceId;

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: context.spacing.gapLg,
                            ),
                            child: Semantics(
                              button: true,
                              label: (voice['label'] as String).tr(),
                              selected: isSelected,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedVoice = voiceId;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(
                                    context.spacing.gapXl,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? context.colors.primary.withValues(
                                            alpha: 0.08,
                                          )
                                        : colorScheme.surfaceContainerHighest
                                              .withValues(alpha: 0.3),
                                    borderRadius: context.radius.panel,
                                    border: Border.all(
                                      color: isSelected
                                          ? context.colors.primary
                                          : colorScheme.outline,
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
                                              ? context.colors.primary
                                                    .withValues(alpha: 0.15)
                                              : colorScheme
                                                    .surfaceContainerHighest,
                                          borderRadius: context.radius.panel,
                                        ),
                                        child: Icon(
                                          voice['icon'] as IconData,
                                          size: 24,
                                          color: isSelected
                                              ? context.colors.primary
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      SizedBox(width: context.spacing.gapXl),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              (voice['label'] as String).tr(),
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: isSelected
                                                        ? context.colors.primary
                                                        : colorScheme.onSurface,
                                                  ),
                                            ),
                                            SizedBox(
                                              height: context.spacing.gapXs,
                                            ),
                                            Text(
                                              (voice['description'] as String)
                                                  .tr(),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: isSelected
                                                        ? context.colors.primary
                                                              .withValues(
                                                                alpha: 0.7,
                                                              )
                                                        : colorScheme
                                                              .onSurfaceVariant,
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
                            ),
                          );
                        },
                      ),
                    ),

                    SetupPrimaryButton(
                      text: 'common.next'.tr(),
                      isEnabled: canProceed,
                      onPressed: () async {
                        final nav = GoRouter.of(context);
                        final prefs = await ref.read(
                          auth_provider.sharedPreferencesProvider.future,
                        );
                        await prefs.setString(
                          StorageKeys.setupVoicePreference,
                          _selectedVoice!,
                        );
                        if (mounted) {
                          await nav.push(AppRoutes.favoritesSetup.path);
                        }
                      },
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
}
