import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/personality.dart';
import '../../data/models/toy.dart';
import '../providers/personality_provider.dart';
import '../providers/toy_provider.dart';

class PersonalitiesScreen extends ConsumerStatefulWidget {
  const PersonalitiesScreen({super.key});

  @override
  ConsumerState<PersonalitiesScreen> createState() =>
      _PersonalitiesScreenState();
}

class _PersonalitiesScreenState extends ConsumerState<PersonalitiesScreen> {
  String _selectedCategory = PersonalityCategories.all;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final personalitiesAsync = ref.watch(personalitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('personalities.title'.tr()),
      ),
      body: personalitiesAsync.when(
        data: (personalities) =>
            _buildContent(context, personalities, theme),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(context, theme, error),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Personality> personalities,
    ThemeData theme,
  ) {
    final filtered = _selectedCategory == PersonalityCategories.all
        ? personalities
        : personalities
            .where((p) =>
                p.category?.toLowerCase() == _selectedCategory)
            .toList();

    return Column(
      children: [
        // Category filter chips
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.alertPadding,
              vertical: 8,
            ),
            itemCount: PersonalityCategories.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = PersonalityCategories.values[index];
              final isSelected = _selectedCategory == cat;
              return FilterChip(
                label: Text(
                  'personalities.category_$cat'.tr(),
                ),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedCategory = cat),
                selectedColor: _getCategoryColor(context, cat).withValues(alpha: 0.2),
                checkmarkColor: _getCategoryColor(context, cat),
                labelStyle: TextStyle(
                  color: isSelected
                      ? _getCategoryColor(context, cat)
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            },
          ),
        ),

        // Personalities grid
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'personalities.empty'.tr(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.all(context.spacing.alertPadding),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _PersonalityCard(
                    personality: filtered[index],
                    onTap: () => _showDetailModal(context, filtered[index]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, ThemeData theme, Object error) =>
      Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.panelPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'personalities.error_loading'.tr(),
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(personalitiesProvider),
                icon: const Icon(Icons.refresh),
                label: Text('common.retry'.tr()),
              ),
            ],
          ),
        ),
      );

  void _showDetailModal(BuildContext context, Personality personality) {
    final theme = context.theme;
    final catColor = _getCategoryColor(context, personality.category ?? '');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: context.radius.bottomSheetTop,
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (ctx, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(context.spacing.panelPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: context.radius.checkbox,
                  ),
                ),
              ),

              // Icon + name
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: catColor.withValues(alpha: 0.15),
                    child: Icon(
                      _getCategoryIcon(personality.category ?? ''),
                      color: catColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          personality.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (personality.category != null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.15),
                              borderRadius: context.radius.tile,
                            ),
                            child: Text(
                              'personalities.category_${personality.category}'.tr(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: catColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Description
              Text(
                personality.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              // Greeting
              if (personality.greeting != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.08),
                    borderRadius: context.radius.tile,
                    border: Border.all(color: catColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.chat_bubble_outline, color: catColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          personality.greeting!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Settings
              if (personality.settings != null) ...[
                const SizedBox(height: 20),
                Text(
                  'personalities.settings'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingRow(
                  theme,
                  Icons.record_voice_over,
                  'personalities.voice'.tr(),
                  personality.settings!.voice ?? '-',
                ),
                _buildSettingRow(
                  theme,
                  Icons.speed,
                  'personalities.speed'.tr(),
                  personality.settings!.speed?.toString() ?? '-',
                ),
                _buildSettingRow(
                  theme,
                  Icons.language,
                  'personalities.language'.tr(),
                  personality.settings!.language ?? '-',
                ),
                _buildSettingRow(
                  theme,
                  Icons.style,
                  'personalities.style'.tr(),
                  personality.settings!.style ?? '-',
                ),
              ],

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push(
                          AppRoutes.playground.path,
                          extra: personality,
                        );
                      },
                      icon: const Icon(Icons.play_circle_outline),
                      label: Text('personalities.try_playground'.tr()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _selectPersonality(ctx, personality),
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text('personalities.select'.tr()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(label, style: theme.textTheme.bodyMedium),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );

  Future<void> _selectPersonality(
    BuildContext ctx,
    Personality personality,
  ) async {
    final toysAsync = ref.read(toyProvider);
    final toys = toysAsync.hasValue ? toysAsync.value! : <Toy>[];

    if (toys.isEmpty) {
      Navigator.pop(ctx);
      if (mounted) {
        context.showInfoSnackBar('personalities.no_toys'.tr());
      }
      return;
    }

    if (toys.length == 1) {
      Navigator.pop(ctx);
      try {
        await ref.read(personalityServiceProvider).assignPersonalityToToy(
              toyId: toys.first.id,
              personalityId: personality.id,
            );
        if (mounted) {
          context.showInfoSnackBar('personalities.assigned_success'.tr(
            args: [personality.name, toys.first.name],
          ));
        }
      } on Exception catch (e) {
        if (mounted) {
          context.showErrorSnackBar(
              e.toString().replaceFirst('Exception: ', ''));
        }
      }
      return;
    }

    // Multiple toys: show picker
    if (!ctx.mounted) {
      return;
    }
    final selectedToy = await showDialog<String>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text('personalities.select_toy'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: toys
              .map(
                (toy) => ListTile(
                  title: Text(toy.name),
                  leading: const Icon(Icons.smart_toy),
                  onTap: () => Navigator.pop(dialogCtx, toy.id),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (selectedToy == null) {
      return;
    }
    if (ctx.mounted) {
      Navigator.pop(ctx);
    }

    try {
      await ref.read(personalityServiceProvider).assignPersonalityToToy(
            toyId: selectedToy,
            personalityId: personality.id,
          );
      if (mounted) {
        context.showInfoSnackBar('personalities.assigned_success'.tr(
          args: [personality.name, ''],
        ));
      }
    } on Exception catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Color _getCategoryColor(BuildContext context, String category) =>
      switch (category.toLowerCase()) {
        'educativo' => context.colors.primary,
        'entretenimiento' => context.colors.secondary,
        'companero' => context.colors.success,
        'creativo' => context.colors.warning,
        'aventura' => context.colors.error,
        'bienestar' => context.colors.primary,
        _ => context.colors.secondary,
      };

  IconData _getCategoryIcon(String category) => switch (category.toLowerCase()) {
        'educativo' => Icons.school,
        'entretenimiento' => Icons.theater_comedy,
        'companero' => Icons.favorite,
        'creativo' => Icons.palette,
        'aventura' => Icons.explore,
        'bienestar' => Icons.spa,
        _ => Icons.psychology,
      };
}

class _PersonalityCard extends StatelessWidget {
  const _PersonalityCard({
    required this.personality,
    required this.onTap,
  });

  final Personality personality;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final catColor = _getCategoryColor(context, personality.category ?? '');

    return InkWell(
      onTap: onTap,
      borderRadius: context.radius.panel,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: context.radius.panel,
          border: Border.all(
            color: catColor.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: catColor.withValues(alpha: 0.12),
              child: Icon(
                _getCategoryIcon(personality.category ?? ''),
                color: catColor,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              personality.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            if (personality.category != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.1),
                  borderRadius: context.radius.tile,
                ),
                child: Text(
                  'personalities.category_${personality.category}'.tr(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: catColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              personality.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(BuildContext context, String category) =>
      switch (category.toLowerCase()) {
        'educativo' => context.colors.primary,
        'entretenimiento' => context.colors.secondary,
        'companero' => context.colors.success,
        'creativo' => context.colors.warning,
        'aventura' => context.colors.error,
        'bienestar' => context.colors.primary,
        _ => context.colors.secondary,
      };

  IconData _getCategoryIcon(String category) => switch (category.toLowerCase()) {
        'educativo' => Icons.school,
        'entretenimiento' => Icons.theater_comedy,
        'companero' => Icons.favorite,
        'creativo' => Icons.palette,
        'aventura' => Icons.explore,
        'bienestar' => Icons.spa,
        _ => Icons.psychology,
      };
}
