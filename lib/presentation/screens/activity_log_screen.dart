import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/activity.dart';
import '../providers/activity_provider.dart';
import '../providers/auth_provider.dart';

class ActivityLogScreen extends ConsumerStatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  ConsumerState<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends ConsumerState<ActivityLogScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActivities();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    final authState = ref.read(authProvider);
    final userId = authState.maybeWhen(
      data: (user) => user?.id,
      orElse: () => null,
    );
    if (userId == null) {
      return;
    }

    await ref
        .read(activityNotifierProvider.notifier)
        .loadActivities(userId: userId);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = ref.read(activityNotifierProvider);
      if (!state.isLoading && state.hasMore) {
        final authState = ref.read(authProvider);
        final userId = authState.maybeWhen(
          data: (user) => user?.id,
          orElse: () => null,
        );
        if (userId != null) {
          ref.read(activityNotifierProvider.notifier).loadMore(userId: userId);
        }
      }
    }
  }

  Future<void> _refreshActivities() async {
    final authState = ref.read(authProvider);
    final userId = authState.maybeWhen(
      data: (user) => user?.id,
      orElse: () => null,
    );
    if (userId == null) {
      return;
    }

    await ref.read(activityNotifierProvider.notifier).refresh(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(activityNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('activity_log.title'.tr()),
        actions: const [],
      ),
      body: _buildBody(state, theme),
    );
  }

  Widget _buildBody(ActivityState state, ThemeData theme) {
    if (state.error != null) {
      return RefreshIndicator(
        onRefresh: _refreshActivities,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(context.spacing.pageMargin),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                SizedBox(height: context.spacing.sectionTitleBottomMargin),
                Text(
                  'activity.error_loading'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.spacing.paragraphBottomMarginSm),
                Container(
                  padding: EdgeInsets.all(context.spacing.alertPadding),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: context.radius.tile,
                    border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: SelectableText(
                    state.error!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: context.spacing.panelPadding),
                ElevatedButton.icon(
                  onPressed: _loadActivities,
                  icon: const Icon(Icons.refresh),
                  label: Text('common.retry'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: context.colors.textOnFilled,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.isLoading && state.activities.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.activities.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshActivities,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: _buildEmptyState(theme),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshActivities,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(context.spacing.alertPadding),
        itemCount: state.activities.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.activities.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final activity = state.activities[index];
          return _buildActivityCard(context, activity, theme);
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Icon(
              Icons.history,
              size: 80,
              color: context.colors.secondary,
            ),
          ),
          SizedBox(height: context.spacing.paragraphBottomMargin),
          Text(
            'activity_log.empty_title'.tr(),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.spacing.sectionTitleBottomMargin),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'activity_log.empty_message'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );

  Widget _buildActivityCard(BuildContext context, Activity activity, ThemeData theme) {
    final icon = _getIconForActivityType(activity.type);
    final activityColor = _getColorForActivityType(context, activity.type);

    return Card(
      margin: EdgeInsets.only(bottom: context.spacing.paragraphBottomMarginSm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: activityColor.withValues(alpha: 0.2),
          child: Icon(icon, color: activityColor),
        ),
        title: Text(
          _getActivityTitle(activity.type),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              activity.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTimestamp(activity.timestamp),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForActivityType(ActivityType type) => switch (type) {
      ActivityType.voiceCommand => Icons.mic,
      ActivityType.connection => Icons.link,
      ActivityType.interaction => Icons.touch_app,
      ActivityType.update => Icons.system_update,
      ActivityType.error => Icons.error,
      ActivityType.play => Icons.play_circle,
      ActivityType.sleep => Icons.bedtime,
      ActivityType.wake => Icons.wb_sunny,
      ActivityType.chat => Icons.chat,
    };

  Color _getColorForActivityType(BuildContext context, ActivityType type) => switch (type) {
      ActivityType.voiceCommand => context.colors.secondary,
      ActivityType.connection => context.colors.success,
      ActivityType.interaction => context.colors.primary,
      ActivityType.update => context.colors.warning,
      ActivityType.error => context.colors.error,
      ActivityType.play => context.colors.primary,
      ActivityType.sleep => context.colors.primary,
      ActivityType.wake => context.colors.warning100,
      ActivityType.chat => context.colors.secondary100,
    };

  String _getActivityTitle(ActivityType type) => switch (type) {
      ActivityType.voiceCommand => 'activity_log.voice_command'.tr(),
      ActivityType.connection => 'activity_log.connection'.tr(),
      ActivityType.interaction => 'activity_log.interaction'.tr(),
      ActivityType.update => 'activity_log.update'.tr(),
      ActivityType.error => 'activity_log.error_type'.tr(),
      ActivityType.play => 'activity_log.play'.tr(),
      ActivityType.sleep => 'activity_log.sleep'.tr(),
      ActivityType.wake => 'activity_log.wake'.tr(),
      ActivityType.chat => 'activity_log.chat'.tr(),
    };

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'activity_log.just_now'.tr();
    } else if (difference.inHours < 1) {
      return 'activity_log.minutes_ago'.tr(args: ['${difference.inMinutes}']);
    } else if (difference.inDays < 1) {
      return 'activity_log.hours_ago'.tr(args: ['${difference.inHours}']);
    } else if (difference.inDays < 7) {
      return 'activity_log.days_ago'.tr(args: ['${difference.inDays}']);
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}
