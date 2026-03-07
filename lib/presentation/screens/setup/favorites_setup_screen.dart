import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/setup_widgets.dart';

class FavoritesSetupScreen extends StatefulWidget {
  const FavoritesSetupScreen({super.key});

  @override
  State<FavoritesSetupScreen> createState() => _FavoritesSetupScreenState();
}

class _FavoritesSetupScreenState extends State<FavoritesSetupScreen> {
  final Set<String> _selectedFavorites = {};

  final List<Map<String, dynamic>> _categories = [
    {'label': 'setup.favorites.animals', 'icon': Icons.pets},
    {'label': 'setup.favorites.space', 'icon': Icons.rocket_launch},
    {'label': 'setup.favorites.sports', 'icon': Icons.sports_soccer},
    {'label': 'setup.favorites.music', 'icon': Icons.music_note},
    {'label': 'setup.favorites.art', 'icon': Icons.palette},
    {'label': 'setup.favorites.science', 'icon': Icons.science},
    {'label': 'setup.favorites.stories', 'icon': Icons.menu_book},
    {'label': 'setup.favorites.games', 'icon': Icons.games},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canProceed = _selectedFavorites.length >= 2;

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
                    SizedBox(height: context.spacing.titleBottomMargin),

                    Text(
                      'setup.favorites.title'.tr(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.spacing.titleBottomMarginSm),
                    Text(
                      'setup.favorites.subtitle'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: context.spacing.largePageBottomMargin),

                    // Categories grid
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = _selectedFavorites
                              .contains(category['label'] as String);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedFavorites
                                      .remove(category['label'] as String);
                                } else {
                                  _selectedFavorites
                                      .add(category['label'] as String);
                                }
                              });
                            },
                            child: DecoratedBox(
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                      category['icon'] as IconData,
                                      size: 24,
                                      color: isSelected
                                          ? context.colors.primary
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    (category['label'] as String).tr(),
                                    style:
                                        theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? context.colors.primary
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SetupPrimaryButton(
                      text: canProceed
                          ? 'setup.favorites.next_with_count'.tr(
                              args: [_selectedFavorites.length.toString()],
                            )
                          : 'setup.favorites.select_at_least'.tr(),
                      isEnabled: canProceed,
                      onPressed: () =>
                          context.go(AppRoutes.worldInfoSetup.path),
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
