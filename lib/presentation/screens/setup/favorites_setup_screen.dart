import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart' as auth_provider;
import '../../widgets/setup_widgets.dart';

class FavoritesSetupScreen extends ConsumerStatefulWidget {
  const FavoritesSetupScreen({super.key});

  @override
  ConsumerState<FavoritesSetupScreen> createState() =>
      _FavoritesSetupScreenState();
}

class _FavoritesSetupScreenState extends ConsumerState<FavoritesSetupScreen> {
  static const _maxFavorites = 5;
  final Set<String> _selectedFavorites = {};

  final List<Map<String, dynamic>> _categories = [
    {'id': 'animals', 'label': 'setup.favorites.animals', 'icon': Icons.pets},
    {
      'id': 'space',
      'label': 'setup.favorites.space',
      'icon': Icons.rocket_launch,
    },
    {
      'id': 'sports',
      'label': 'setup.favorites.sports',
      'icon': Icons.sports_soccer,
    },
    {'id': 'music', 'label': 'setup.favorites.music', 'icon': Icons.music_note},
    {'id': 'art', 'label': 'setup.favorites.art', 'icon': Icons.palette},
    {
      'id': 'science',
      'label': 'setup.favorites.science',
      'icon': Icons.science,
    },
    {
      'id': 'stories',
      'label': 'setup.favorites.stories',
      'icon': Icons.menu_book,
    },
    {'id': 'games', 'label': 'setup.favorites.games', 'icon': Icons.games},
  ];

  Future<void> _saveAndContinue() async {
    final nav = GoRouter.of(context);
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );
    await prefs.setString(
      StorageKeys.setupFavorites,
      json.encode(_selectedFavorites.toList()),
    );

    if (mounted) {
      await nav.push(AppRoutes.worldInfoSetup.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final canProceed = _selectedFavorites.length >= 2;
    final atLimit = _selectedFavorites.length >= _maxFavorites;

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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: context.spacing.gapLg,
                          mainAxisSpacing: context.spacing.gapLg,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final categoryId = category['id'] as String;
                          final isSelected = _selectedFavorites.contains(
                            categoryId,
                          );
                          final isDisabled = !isSelected && atLimit;

                          return Semantics(
                            button: true,
                            label: (category['label'] as String).tr(),
                            selected: isSelected,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedFavorites.remove(categoryId);
                                  } else if (_selectedFavorites.length < _maxFavorites) {
                                    _selectedFavorites.add(categoryId);
                                  }
                                });
                              },
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: isDisabled ? 0.4 : 1.0,
                                child: DecoratedBox(
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
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? context.colors.primary.withValues(
                                                alpha: 0.15,
                                              )
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
                                    SizedBox(height: context.spacing.gapLg),
                                    Text(
                                      (category['label'] as String).tr(),
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? context.colors.primary
                                                : colorScheme.onSurface,
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
                      text: canProceed
                          ? 'setup.favorites.next_with_count'.tr(
                              args: [_selectedFavorites.length.toString()],
                            )
                          : 'setup.favorites.select_at_least'.tr(),
                      isEnabled: canProceed,
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
}
