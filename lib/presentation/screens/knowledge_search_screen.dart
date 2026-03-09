import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/voice_session.dart';
import '../providers/memory_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class KnowledgeSearchScreen extends ConsumerStatefulWidget {
  const KnowledgeSearchScreen({super.key});

  @override
  ConsumerState<KnowledgeSearchScreen> createState() =>
      _KnowledgeSearchScreenState();
}

class _KnowledgeSearchScreenState extends ConsumerState<KnowledgeSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    ref
        .read(knowledgeSearchProvider.notifier)
        .search(query: query, language: context.locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final results = ref.watch(knowledgeSearchProvider);

    return Scaffold(
      appBar: AppBar(title: Text('knowledge.title'.tr())),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(context.spacing.alertPadding),
            child: CustomInput(
              controller: _searchController,
              hint: 'knowledge.search_hint'.tr(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(knowledgeSearchProvider.notifier).clear();
                      },
                    )
                  : null,
              textInputAction: TextInputAction.search,
              onEditingComplete: _performSearch,
            ),
          ),

          // Results
          Expanded(
            child: results.when(
              data: (entries) {
                if (entries.isEmpty && _searchController.text.isEmpty) {
                  return _buildEmptyState(context, theme);
                }
                if (entries.isEmpty) {
                  return Center(
                    child: Text(
                      'knowledge.no_results'.tr(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.alertPadding,
                  ),
                  itemCount: entries.length,
                  itemBuilder: (context, index) =>
                      _KnowledgeCard(entry: entries[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: colorScheme.error,
                    ),
                    SizedBox(height: context.spacing.panelPadding),
                    Text('knowledge.error'.tr()),
                    SizedBox(height: context.spacing.panelPadding),
                    CustomButton(
                      text: 'common.retry'.tr(),
                      onPressed: _performSearch,
                      icon: Icons.refresh,
                      height: 44,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.menu_book_rounded,
          size: 80,
          color: context.colors.primary.withValues(alpha: 0.3),
        ),
        SizedBox(height: context.spacing.panelPadding),
        Text(
          'knowledge.empty_title'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.spacing.labelBottomMargin),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.alertPadding * 2,
          ),
          child: Text(
            'knowledge.empty_message'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}

class _KnowledgeCard extends StatelessWidget {
  const _KnowledgeCard({required this.entry});
  final KnowledgeEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.only(bottom: context.spacing.paragraphBottomMarginSm),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.panelPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: topic + relevance
            Row(
              children: [
                Icon(
                  _categoryIcon(entry.category),
                  size: 18,
                  color: context.colors.primary,
                ),
                SizedBox(width: context.spacing.labelBottomMargin),
                if (entry.topic != null)
                  Expanded(
                    child: Text(
                      entry.topic!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (entry.relevance != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      borderRadius: context.radius.tile,
                    ),
                    child: Text(
                      '${entry.relevance!.toInt()}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: context.spacing.labelBottomMargin),

            // Content
            Text(entry.content, style: theme.textTheme.bodyMedium),

            SizedBox(height: context.spacing.labelBottomMargin),

            // Footer: category + verified badge
            Row(
              children: [
                if (entry.category != null)
                  Chip(
                    label: Text(
                      entry.category!,
                      style: theme.textTheme.labelSmall,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                if (entry.verified) ...[
                  SizedBox(width: context.spacing.labelBottomMargin),
                  Icon(Icons.verified, size: 16, color: context.colors.success),
                  const SizedBox(width: 4),
                  Text(
                    'knowledge.verified'.tr(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: context.colors.success,
                    ),
                  ),
                ],
                if (entry.source != null) ...[
                  const Spacer(),
                  Text(
                    entry.source!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String? category) => switch (category?.toLowerCase()) {
    'ciencia' || 'science' => Icons.science,
    'historia' || 'history' => Icons.history_edu,
    'naturaleza' || 'nature' => Icons.eco,
    'arte' || 'art' => Icons.palette,
    'matematicas' || 'math' => Icons.calculate,
    'musica' || 'music' => Icons.music_note,
    _ => Icons.menu_book_rounded,
  };
}
