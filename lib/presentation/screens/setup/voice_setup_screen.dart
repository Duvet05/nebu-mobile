import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/setup_widgets.dart';

class VoiceSetupScreen extends StatefulWidget {
  const VoiceSetupScreen({super.key});

  @override
  State<VoiceSetupScreen> createState() => _VoiceSetupScreenState();
}

class _VoiceSetupScreenState extends State<VoiceSetupScreen> {
  String? _selectedVoice;

  final List<Map<String, dynamic>> _voices = [
    {
      'label': 'setup.voice.child_voice',
      'icon': Icons.child_care,
      'description': 'setup.voice.child_voice_desc',
    },
    {
      'label': 'setup.voice.friendly_adult',
      'icon': Icons.person,
      'description': 'setup.voice.friendly_adult_desc',
    },
    {
      'label': 'setup.voice.robot_voice',
      'icon': Icons.smart_toy,
      'description': 'setup.voice.robot_voice_desc',
    },
    {
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
                          final isSelected = _selectedVoice == voice['label'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedVoice = voice['label'] as String;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? context.colors.primary
                                          .withValues(alpha: 0.08)
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
                                    const SizedBox(width: 16),
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
                                          const SizedBox(height: 4),
                                          Text(
                                            (voice['description'] as String)
                                                .tr(),
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: isSelected
                                                  ? context.colors.primary
                                                      .withValues(alpha: 0.7)
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
                          );
                        },
                      ),
                    ),

                    SetupPrimaryButton(
                      text: 'common.next'.tr(),
                      isEnabled: canProceed,
                      onPressed: () =>
                          context.push(AppRoutes.favoritesSetup.path),
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
