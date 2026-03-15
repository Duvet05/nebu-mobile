import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart' as auth_provider;
import '../../widgets/setup_widgets.dart';

class AgeSetupScreen extends ConsumerStatefulWidget {
  const AgeSetupScreen({super.key});

  @override
  ConsumerState<AgeSetupScreen> createState() => _AgeSetupScreenState();
}

class _AgeSetupScreenState extends ConsumerState<AgeSetupScreen> {
  String? _selectedAge;

  final List<Map<String, dynamic>> _ageGroups = [
    {'id': '3-5', 'label': 'setup.age.age_3_5', 'icon': Icons.child_care},
    {'id': '6-8', 'label': 'setup.age.age_6_8', 'icon': Icons.face},
    {'id': '9-12', 'label': 'setup.age.age_9_12', 'icon': Icons.boy},
    {'id': '13+', 'label': 'setup.age.age_13_plus', 'icon': Icons.person},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final canProceed = _selectedAge != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SetupHeader(currentStep: 4, totalSteps: 7),

            // Content
            Expanded(
              child: Padding(
                padding: context.spacing.pageEdgeInsets,
                child: Column(
                  children: [
                    SizedBox(height: context.spacing.titleBottomMargin),

                    Text(
                      'setup.age.title'.tr(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: context.spacing.titleBottomMarginSm),
                    Text(
                      'setup.age.subtitle'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: context.spacing.largePageBottomMargin),

                    // Age options
                    Expanded(
                      child: ListView.builder(
                        itemCount: _ageGroups.length,
                        itemBuilder: (context, index) {
                          final age = _ageGroups[index];
                          final ageId = age['id'] as String;
                          final isSelected = _selectedAge == ageId;

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: context.spacing.gapLg,
                            ),
                            child: Semantics(
                              button: true,
                              label: (age['label'] as String).tr(),
                              selected: isSelected,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedAge = ageId;
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
                                          age['icon'] as IconData,
                                          size: 24,
                                          color: isSelected
                                              ? context.colors.primary
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      SizedBox(width: context.spacing.gapXl),
                                      Expanded(
                                        child: Text(
                                          (age['label'] as String).tr(),
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? context.colors.primary
                                                    : colorScheme.onSurface,
                                              ),
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
                          StorageKeys.setupChildAge,
                          _selectedAge!,
                        );
                        if (mounted) {
                          await nav.push(AppRoutes.personalitySetup.path);
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
