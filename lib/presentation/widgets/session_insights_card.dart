import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/voice_session.dart';
import '../providers/voice_session_provider.dart';

/// Parental insights summary built from recent voice sessions.
/// Shows emotion trend, top topics, and session stats.
class SessionInsightsCard extends ConsumerWidget {
  const SessionInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(userVoiceSessionsProvider);

    return sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return const SizedBox.shrink();
        }
        return _InsightsContent(sessions: sessions);
      },
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: context.spacing.gapMd),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _InsightsContent extends StatelessWidget {
  const _InsightsContent({required this.sessions});

  final List<VoiceSession> sessions;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final emotions = _recentEmotions(sessions);
    final topics = _topTopics(sessions);
    final totalMinutes = _totalMinutes(sessions);

    return Card(
      margin: EdgeInsets.only(bottom: context.spacing.alertPadding),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.alertPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.insights, size: 20, color: context.colors.primary),
                SizedBox(width: context.spacing.labelBottomMargin),
                Text(
                  'activity_log.insights_title'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'activity_log.insights_sessions'.tr(
                    args: ['${sessions.length}'],
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            SizedBox(height: context.spacing.paragraphBottomMarginSm),

            // Stats row
            Row(
              children: [
                _StatChip(
                  icon: Icons.timer_outlined,
                  label: 'activity_log.insights_minutes'.tr(
                    args: ['$totalMinutes'],
                  ),
                  color: context.colors.primary,
                ),
                SizedBox(width: context.spacing.labelBottomMargin),
                _StatChip(
                  icon: Icons.chat_outlined,
                  label: 'activity_log.insights_messages'.tr(
                    args: ['${_totalMessages(sessions)}'],
                  ),
                  color: context.colors.secondary,
                ),
              ],
            ),

            // Emotions
            if (emotions.isNotEmpty) ...[
              SizedBox(height: context.spacing.paragraphBottomMarginSm),
              Text(
                'activity_log.insights_emotions'.tr(),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: context.spacing.labelBottomMargin),
              Wrap(
                spacing: context.spacing.labelBottomMargin,
                runSpacing: context.spacing.labelBottomMargin,
                children: emotions.entries
                    .map((e) => _EmotionBadge(emotion: e.key, count: e.value))
                    .toList(),
              ),
            ],

            // Topics
            if (topics.isNotEmpty) ...[
              SizedBox(height: context.spacing.paragraphBottomMarginSm),
              Text(
                'activity_log.insights_topics'.tr(),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: context.spacing.labelBottomMargin),
              Wrap(
                spacing: context.spacing.labelBottomMargin,
                runSpacing: context.spacing.labelBottomMargin,
                children: topics
                    .map(
                      (t) => Chip(
                        label: Text(t, style: theme.textTheme.labelSmall),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Count emotions from recent sessions.
  Map<String, int> _recentEmotions(List<VoiceSession> sessions) {
    final counts = <String, int>{};
    for (final s in sessions) {
      if (s.emotion != null && s.emotion!.isNotEmpty) {
        counts[s.emotion!] = (counts[s.emotion!] ?? 0) + 1;
      }
    }
    // Sort by frequency descending
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(4));
  }

  /// Top topics across all sessions (deduplicated, max 6).
  List<String> _topTopics(List<VoiceSession> sessions) {
    final counts = <String, int>{};
    for (final s in sessions) {
      if (s.topics != null) {
        for (final t in s.topics!) {
          final topic = t.trim();
          if (topic.isNotEmpty) {
            counts[topic] = (counts[topic] ?? 0) + 1;
          }
        }
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(6).map((e) => e.key).toList();
  }

  int _totalMinutes(List<VoiceSession> sessions) {
    var total = 0;
    for (final s in sessions) {
      total += s.durationSeconds ?? 0;
    }
    return (total / 60).round();
  }

  int _totalMessages(List<VoiceSession> sessions) {
    var total = 0;
    for (final s in sessions) {
      total += s.messageCount;
    }
    return total;
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: context.spacing.gapMd,
      vertical: context.spacing.gapXs,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: context.radius.tile,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: context.spacing.gapXs),
        Text(
          label,
          style: context.theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _EmotionBadge extends StatelessWidget {
  const _EmotionBadge({required this.emotion, required this.count});

  final String emotion;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.gapMd,
        vertical: context.spacing.gapXs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: context.radius.tile,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(emotionIcon(emotion), size: 14),
          SizedBox(width: context.spacing.gapXs),
          Text(
            'activity_log.emotion_count'.tr(args: [emotion, '$count']),
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
