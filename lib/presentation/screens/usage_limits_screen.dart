import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/voice_session.dart';
import '../providers/voice_session_provider.dart';
import '../widgets/custom_button.dart';

class UsageLimitsScreen extends ConsumerWidget {
  const UsageLimitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(voiceMetricsProvider);
    final sessionsAsync = ref.watch(userVoiceSessionsProvider);
    final limitsAsync = ref.watch(userLimitsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('limits.title'.tr())),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(voiceMetricsProvider)
            ..invalidate(userVoiceSessionsProvider)
            ..invalidate(userLimitsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Usage Summary Card
            SliverToBoxAdapter(
              child: metricsAsync.when(
                data: (metrics) => _UsageSummaryCard(metrics: metrics),
                loading: () => Padding(
                  padding: EdgeInsets.all(context.spacing.alertPadding),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => Padding(
                  padding: EdgeInsets.all(context.spacing.alertPadding),
                  child: _ErrorCard(
                    message: 'limits.metrics_error'.tr(),
                    onRetry: () => ref.invalidate(voiceMetricsProvider),
                  ),
                ),
              ),
            ),

            // Voice Usage Limits Card (real data from GET /users/me/limits)
            SliverToBoxAdapter(
              child: limitsAsync.when(
                data: (limits) => _UsageLimitsCard(voice: limits.voice),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),

            // Recent Activity Card
            SliverToBoxAdapter(
              child: sessionsAsync.when(
                data: (sessions) => _RecentActivityCard(sessions: sessions),
                loading: () => Padding(
                  padding: EdgeInsets.all(context.spacing.alertPadding),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => Padding(
                  padding: EdgeInsets.all(context.spacing.alertPadding),
                  child: _ErrorCard(
                    message: 'limits.sessions_error'.tr(),
                    onRetry: () =>
                        ref.invalidate(userVoiceSessionsProvider),
                  ),
                ),
              ),
            ),

            // Bottom spacing
            SliverToBoxAdapter(
              child: SizedBox(height: context.spacing.largePageBottomMargin),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Usage Summary Card ───

class _UsageSummaryCard extends StatelessWidget {
  const _UsageSummaryCard({required this.metrics});
  final VoiceMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Padding(
      padding: EdgeInsets.all(context.spacing.alertPadding),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: context.radius.panel),
        child: Padding(
          padding: EdgeInsets.all(context.spacing.panelPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'limits.usage_summary'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: context.spacing.paragraphBottomMarginSm),
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.mic,
                      label: 'limits.total_sessions'.tr(),
                      value: '${metrics.totalSessions}',
                    ),
                  ),
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.timer_outlined,
                      label: 'limits.avg_duration'.tr(),
                      value: _formatDuration(
                        metrics.averageSessionDuration.toInt(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.chat_bubble_outline,
                      label: 'limits.total_conversations'.tr(),
                      value: '${metrics.totalConversations}',
                    ),
                  ),
                ],
              ),
              if (metrics.activeSessions > 0) ...[
                SizedBox(height: context.spacing.paragraphBottomMarginSm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.paragraphBottomMarginSm,
                    vertical: context.spacing.gapSm,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.success.withValues(alpha: 0.12),
                    borderRadius: context.radius.tile,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: context.colors.success,
                      ),
                      SizedBox(width: context.spacing.gapMd),
                      Text(
                        'limits.active_sessions'.tr(
                          args: ['${metrics.activeSessions}'],
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: context.colors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    }
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }
}

// ─── Recent Activity Card ───

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.sessions});
  final List<VoiceSession> sessions;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final thisWeek =
        sessions.where((s) => s.startedAt.isAfter(weekAgo)).toList();

    final avgMessages = sessions.isEmpty
        ? 0.0
        : sessions.fold<int>(0, (sum, s) => sum + s.messageCount) /
            sessions.length;

    final emotionCounts = <String, int>{};
    for (final s in sessions) {
      if (s.emotion != null) {
        emotionCounts[s.emotion!] = (emotionCounts[s.emotion!] ?? 0) + 1;
      }
    }
    String? topEmotion;
    if (emotionCounts.isNotEmpty) {
      topEmotion = emotionCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.alertPadding),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: context.radius.panel),
        child: Padding(
          padding: EdgeInsets.all(context.spacing.panelPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'limits.recent_activity'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: context.spacing.paragraphBottomMarginSm),
              _ActivityRow(
                icon: Icons.date_range,
                label: 'limits.sessions_this_week'.tr(),
                value: '${thisWeek.length}',
              ),
              SizedBox(height: context.spacing.labelBottomMargin),
              _ActivityRow(
                icon: Icons.chat_bubble_outline,
                label: 'limits.avg_messages'.tr(),
                value: avgMessages.toStringAsFixed(1),
              ),
              if (topEmotion != null) ...[
                SizedBox(height: context.spacing.labelBottomMargin),
                _ActivityRow(
                  icon: emotionIcon(topEmotion),
                  label: 'limits.top_emotion'.tr(),
                  value: topEmotion,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Row(
      children: [
        Icon(icon, size: 20, color: context.colors.primary),
        SizedBox(width: context.spacing.gapLg),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Metric Tile ───

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      children: [
        Icon(icon, color: context.colors.primary),
        SizedBox(height: context.spacing.labelBottomMargin),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Voice Usage Limits Card ───

class _UsageLimitsCard extends StatelessWidget {
  const _UsageLimitsCard({required this.voice});
  final VoiceLimits voice;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.alertPadding),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: context.radius.panel),
        child: Padding(
          padding: EdgeInsets.all(context.spacing.panelPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'limits.voice_limits'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: context.spacing.paragraphBottomMarginSm),

              // Daily usage
              _UsageBar(
                icon: Icons.today,
                label: 'limits.daily_usage'.tr(),
                used: voice.dailyMinutesUsed,
                limit: voice.dailyMinutesLimit,
              ),
              SizedBox(height: context.spacing.paragraphBottomMarginSm),

              // Monthly usage
              _UsageBar(
                icon: Icons.calendar_month,
                label: 'limits.monthly_usage'.tr(),
                used: voice.monthlyMinutesUsed,
                limit: voice.monthlyMinutesLimit,
              ),
              SizedBox(height: context.spacing.paragraphBottomMarginSm),

              // Max session info
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: context.spacing.gapMd),
                  Text(
                    'limits.max_session'.tr(
                      args: ['${voice.maxSessionMinutes}'],
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsageBar extends StatelessWidget {
  const _UsageBar({
    required this.icon,
    required this.label,
    required this.used,
    required this.limit,
  });

  final IconData icon;
  final String label;
  final double used;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final ratio = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
    final color = ratio > 0.85
        ? context.colors.error
        : ratio > 0.6
            ? context.colors.warning
            : context.colors.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: context.colors.primary),
            SizedBox(width: context.spacing.gapMd),
            Expanded(
              child: Text(label, style: theme.textTheme.bodyMedium),
            ),
            Text(
              'limits.minutes_of'.tr(
                args: [
                  used.toStringAsFixed(0),
                  limit.toStringAsFixed(0),
                ],
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: context.spacing.gapSm),
        ClipRRect(
          borderRadius: context.radius.checkbox,
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ─── Error Card ───

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: context.radius.panel),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.panelPadding),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            SizedBox(height: context.spacing.labelBottomMargin),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.labelBottomMargin),
            CustomButton(
              text: 'common.retry'.tr(),
              icon: Icons.refresh,
              onPressed: onRetry,
              variant: ButtonVariant.outline,
            ),
          ],
        ),
      ),
    );
  }
}
