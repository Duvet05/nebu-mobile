import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/conversation.dart';
import '../../data/models/toy.dart';
import '../providers/memory_provider.dart';

class ToyMemoryScreen extends ConsumerStatefulWidget {
  const ToyMemoryScreen({required this.toy, super.key});

  final Toy toy;

  @override
  ConsumerState<ToyMemoryScreen> createState() => _ToyMemoryScreenState();
}

class _ToyMemoryScreenState extends ConsumerState<ToyMemoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('memory.title'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.psychology),
              text: 'memory.tab_memories'.tr(),
            ),
            Tab(
              icon: const Icon(Icons.insights),
              text: 'memory.tab_insights'.tr(),
            ),
            Tab(
              icon: const Icon(Icons.search),
              text: 'memory.tab_search'.tr(),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MemoriesTab(toyId: widget.toy.id),
          _InsightsTab(toyId: widget.toy.id),
          _SearchTab(toyId: widget.toy.id, searchController: _searchController),
        ],
      ),
    );
}

// ─── Memories Tab ───

class _MemoriesTab extends ConsumerWidget {
  const _MemoriesTab({required this.toyId});
  final String toyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final memoriesAsync = ref.watch(toyMemoriesProvider(toyId));

    return memoriesAsync.when(
      data: (memories) {
        if (memories.isEmpty) {
          return _buildEmptyState(
            context,
            theme,
            Icons.psychology_outlined,
            'memory.empty_memories_title'.tr(),
            'memory.empty_memories_message'.tr(),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(toyMemoriesProvider(toyId)),
          child: ListView.builder(
            padding: EdgeInsets.all(context.spacing.alertPadding),
            itemCount: memories.length,
            itemBuilder: (context, index) =>
                _MemoryCard(memory: memories[index]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(context, theme, ref),
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme, WidgetRef ref) =>
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('memory.error_loading'.tr()),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(toyMemoriesProvider(toyId)),
              icon: const Icon(Icons.refresh),
              label: Text('common.retry'.tr()),
            ),
          ],
        ),
      );
}

class _MemoryCard extends ConsumerWidget {
  const _MemoryCard({required this.memory});
  final MemoryEntry memory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final catColor = _getCategoryColor(context, memory.category);
    final catIcon = _getCategoryIcon(memory.category);

    return Dismissible(
      key: Key(memory.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('memory.delete_memory_title'.tr()),
            content: Text('memory.delete_memory_confirm'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('common.cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'common.delete'.tr(),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
        );

        if (confirmed ?? false) {
          try {
            final service = ref.read(memoryServiceProvider);
            await service.deleteMemory(memory.id);
            return true;
          } on Exception {
            return false;
          }
        }
        return false;
      },
      child: Card(
        margin: EdgeInsets.only(bottom: context.spacing.paragraphBottomMarginSm),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: catColor.withValues(alpha: 0.15),
                child: Icon(catIcon, color: catColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.12),
                            borderRadius: context.radius.tile,
                          ),
                          child: Text(
                            memory.category,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: catColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (memory.relevanceScore != null)
                          Text(
                            '${(memory.relevanceScore! * 100).toInt()}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      memory.content,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(memory.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(BuildContext context, String category) =>
      switch (category.toLowerCase()) {
        'preference' || 'preferencia' => context.colors.primary,
        'fact' || 'hecho' => context.colors.secondary,
        'emotion' || 'emocion' => context.colors.warning,
        'topic' || 'tema' => context.colors.success,
        'relationship' || 'relacion' => context.colors.error,
        _ => context.colors.primary,
      };

  IconData _getCategoryIcon(String category) => switch (category.toLowerCase()) {
        'preference' || 'preferencia' => Icons.favorite,
        'fact' || 'hecho' => Icons.lightbulb,
        'emotion' || 'emocion' => Icons.mood,
        'topic' || 'tema' => Icons.topic,
        'relationship' || 'relacion' => Icons.people,
        _ => Icons.memory,
      };

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'memory.minutes_ago'.tr(args: ['${diff.inMinutes}']);
    if (diff.inHours < 24) return 'memory.hours_ago'.tr(args: ['${diff.inHours}']);
    if (diff.inDays < 7) return 'memory.days_ago'.tr(args: ['${diff.inDays}']);
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ─── Insights Tab ───

class _InsightsTab extends ConsumerWidget {
  const _InsightsTab({required this.toyId});
  final String toyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final insightsAsync = ref.watch(toyInsightsProvider(toyId));

    return insightsAsync.when(
      data: (insights) {
        if (insights.isEmpty) {
          return _buildEmptyState(
            context,
            theme,
            Icons.insights_outlined,
            'memory.empty_insights_title'.tr(),
            'memory.empty_insights_message'.tr(),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(toyInsightsProvider(toyId)),
          child: ListView.builder(
            padding: EdgeInsets.all(context.spacing.alertPadding),
            itemCount: insights.length,
            itemBuilder: (context, index) =>
                _InsightCard(insight: insights[index]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('memory.error_loading'.tr()),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(toyInsightsProvider(toyId)),
              icon: const Icon(Icons.refresh),
              label: Text('common.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});
  final ConversationInsight insight;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Card(
      margin: EdgeInsets.only(bottom: context.spacing.paragraphBottomMarginSm),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _getInsightIcon(insight.type),
                  color: context.colors.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  insight.type.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: context.colors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (insight.messageCount != null)
                  Chip(
                    label: Text(
                      'memory.messages_count'.tr(
                        args: ['${insight.messageCount}'],
                      ),
                      style: theme.textTheme.labelSmall,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Summary
            Text(insight.summary, style: theme.textTheme.bodyMedium),

            // Topics
            if (insight.topics != null && insight.topics!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: insight.topics!
                    .map(
                      (topic) => Chip(
                        label: Text(
                          topic,
                          style: theme.textTheme.labelSmall,
                        ),
                        visualDensity: VisualDensity.compact,
                        backgroundColor:
                            context.colors.primary.withValues(alpha: 0.08),
                      ),
                    )
                    .toList(),
              ),
            ],

            // Emotion analysis
            if (insight.emotionAnalysis != null &&
                insight.emotionAnalysis!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildEmotionBar(context, theme, insight.emotionAnalysis!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionBar(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> emotions,
  ) {
    final entries = emotions.entries
        .where((e) => e.value is num)
        .toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));

    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'memory.emotions'.tr(),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        ...entries.take(3).map((e) {
          final value = (e.value as num).toDouble();
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    e.key,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: value.clamp(0, 1),
                    backgroundColor:
                        context.colors.primary.withValues(alpha: 0.1),
                    color: _emotionColor(context, e.key),
                    minHeight: 6,
                    borderRadius: context.radius.checkbox,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _emotionColor(BuildContext context, String emotion) =>
      switch (emotion.toLowerCase()) {
        'happy' || 'feliz' || 'joy' => context.colors.success,
        'sad' || 'triste' => context.colors.primary,
        'angry' || 'enojado' => context.colors.error,
        'curious' || 'curioso' => context.colors.secondary,
        'excited' || 'emocionado' => context.colors.warning,
        _ => context.colors.primary,
      };

  IconData _getInsightIcon(String type) => switch (type.toLowerCase()) {
        'summary' || 'resumen' => Icons.summarize,
        'topic' || 'tema' => Icons.topic,
        'emotion' || 'emocion' => Icons.mood,
        'behavior' || 'comportamiento' => Icons.analytics,
        _ => Icons.insights,
      };
}

// ─── Search Tab ───

class _SearchTab extends ConsumerWidget {
  const _SearchTab({required this.toyId, required this.searchController});
  final String toyId;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final AsyncValue<List<MemoryEntry>> searchResults =
        ref.watch(memorySearchProvider);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(context.spacing.alertPadding),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'memory.search_hint'.tr(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        ref.read(memorySearchProvider.notifier).clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: context.radius.input),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (query) {
              if (query.trim().isNotEmpty) {
                ref
                    .read(memorySearchProvider.notifier)
                    .search(query: query.trim(), toyId: toyId);
              }
            },
          ),
        ),

        Expanded(
          child: searchResults.when(
            data: (results) {
              if (results.isEmpty && searchController.text.isEmpty) {
                return _buildEmptyState(
                  context,
                  theme,
                  Icons.search,
                  'memory.search_empty_title'.tr(),
                  'memory.search_empty_message'.tr(),
                );
              }

              if (results.isEmpty) {
                return Center(
                  child: Text(
                    'memory.no_results'.tr(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.alertPadding,
                ),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final MemoryEntry memory = results[index];
                  return _MemoryCard(memory: memory);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: Text(
                'memory.search_error'.tr(),
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared ───

Widget _buildEmptyState(
  BuildContext context,
  ThemeData theme,
  IconData icon,
  String title,
  String message,
) =>
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: context.colors.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
