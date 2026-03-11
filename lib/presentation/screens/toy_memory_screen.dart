import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/conversation.dart';
import '../../data/models/toy.dart';
import '../providers/memory_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

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
    _tabController = TabController(length: 2, vsync: this);
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
          Tab(icon: const Icon(Icons.search), text: 'memory.tab_search'.tr()),
        ],
      ),
    ),
    body: TabBarView(
      controller: _tabController,
      children: [
        _MemoriesTab(toyId: widget.toy.id),
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

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
  ) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
        SizedBox(height: context.spacing.panelPadding),
        Text('memory.error_loading'.tr()),
        SizedBox(height: context.spacing.panelPadding),
        CustomButton(
          text: 'common.retry'.tr(),
          onPressed: () => ref.invalidate(toyMemoriesProvider(toyId)),
          icon: Icons.refresh,
          height: 44,
        ),
      ],
    ),
  );
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({required this.memory});
  final MemoryEntry memory;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final emotion = memory.emotion ?? 'neutral';
    final emotionColor = _emotionColor(context, emotion);

    return Card(
      margin: EdgeInsets.only(bottom: context.spacing.paragraphBottomMarginSm),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.panelPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: emotionColor.withValues(alpha: 0.15),
              child: Icon(emotionIcon(emotion), color: emotionColor, size: 20),
            ),
            SizedBox(width: context.spacing.paragraphBottomMarginSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: emotion badge + relevance
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.gapMd,
                          vertical: context.spacing.gapXxs,
                        ),
                        decoration: BoxDecoration(
                          color: emotionColor.withValues(alpha: 0.12),
                          borderRadius: context.radius.tile,
                        ),
                        child: Text(
                          emotion,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: emotionColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (memory.relevance != null)
                        Text(
                          '${memory.relevance!.toInt()}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: context.spacing.labelBottomMargin),

                  // Summary
                  Text(memory.summary, style: theme.textTheme.bodyMedium),

                  // Topics
                  if (memory.topics != null && memory.topics!.isNotEmpty) ...[
                    SizedBox(height: context.spacing.labelBottomMargin),
                    Wrap(
                      spacing: context.spacing.gapSm,
                      runSpacing: context.spacing.gapXs,
                      children: memory.topics!.split(',').map((topic) {
                        final trimmed = topic.trim();
                        if (trimmed.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Chip(
                          label: Text(
                            trimmed,
                            style: theme.textTheme.labelSmall,
                          ),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: context.colors.primary.withValues(
                            alpha: 0.08,
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Footer: message count + timestamp
                  SizedBox(height: context.spacing.labelBottomMargin),
                  Row(
                    children: [
                      if (memory.messageCount != null) ...[
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: context.spacing.gapXs),
                        Text(
                          'memory.messages_count'.tr(
                            args: ['${memory.messageCount}'],
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(
                          width: context.spacing.paragraphBottomMarginSm,
                        ),
                      ],
                      if (memory.timestamp != null)
                        Expanded(
                          child: Text(
                            _formatTimestamp(memory.timestamp!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  String _formatTimestamp(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) {
      return iso;
    }

    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) {
      return 'memory.minutes_ago'.tr(args: ['${diff.inMinutes}']);
    }
    if (diff.inHours < 24) {
      return 'memory.hours_ago'.tr(args: ['${diff.inHours}']);
    }
    if (diff.inDays < 7) {
      return 'memory.days_ago'.tr(args: ['${diff.inDays}']);
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ─── Search Tab ───

class _SearchTab extends ConsumerWidget {
  const _SearchTab({required this.toyId, required this.searchController});
  final String toyId;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final AsyncValue<List<MemoryEntry>> searchResults = ref.watch(
      memorySearchProvider,
    );

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(context.spacing.alertPadding),
          child: CustomInput(
            controller: searchController,
            hint: 'memory.search_hint'.tr(),
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
            textInputAction: TextInputAction.search,
            onEditingComplete: () {
              final query = searchController.text.trim();
              if (query.isNotEmpty) {
                ref
                    .read(memorySearchProvider.notifier)
                    .search(query: query, toyId: toyId);
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
                itemBuilder: (context, index) =>
                    _MemoryCard(memory: results[index]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'memory.search_error'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  SizedBox(height: context.spacing.panelPadding),
                  CustomButton(
                    text: 'common.retry'.tr(),
                    onPressed: () => ref.invalidate(memorySearchProvider),
                    variant: ButtonVariant.outline,
                  ),
                ],
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
) => Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        icon,
        size: 80,
        color: context.colors.primary.withValues(alpha: 0.3),
      ),
      SizedBox(height: context.spacing.panelPadding),
      Text(
        title,
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
