import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/voice_session.dart';
import '../providers/voice_session_provider.dart';
import '../widgets/custom_button.dart';

class VoiceSessionsScreen extends ConsumerWidget {
  const VoiceSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final metricsAsync = ref.watch(voiceMetricsProvider);
    final sessionsAsync = ref.watch(userVoiceSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('voice_history.title'.tr())),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(voiceMetricsProvider)
            ..invalidate(userVoiceSessionsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Metrics summary
            SliverToBoxAdapter(
              child: metricsAsync.when(
                data: (metrics) => _MetricsSummary(metrics: metrics),
                loading: () => Padding(
                  padding: EdgeInsets.all(context.spacing.alertPadding),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => Padding(
                  padding: EdgeInsets.all(context.spacing.alertPadding),
                  child: Text(
                    'limits.metrics_error'.tr(),
                    style: context.theme.textTheme.bodyMedium?.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                ),
              ),
            ),

            // Sessions header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.alertPadding,
                  vertical: context.spacing.labelBottomMargin,
                ),
                child: Text(
                  'voice_history.sessions'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Sessions list
            sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return SliverFillRemaining(
                    child: _buildEmptyState(context, theme),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.alertPadding,
                  ),
                  sliver: SliverList.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) =>
                        _SessionCard(session: sessions[index]),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => SliverFillRemaining(
                child: _buildErrorState(context, theme, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.record_voice_over_outlined,
          size: 80,
          color: context.colors.primary.withValues(alpha: 0.3),
        ),
        SizedBox(height: context.spacing.panelPadding),
        Text(
          'voice_history.empty_title'.tr(),
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
            'voice_history.empty_message'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );

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
        Text('voice_history.error'.tr()),
        SizedBox(height: context.spacing.panelPadding),
        CustomButton(
          text: 'common.retry'.tr(),
          icon: Icons.refresh,
          onPressed: () {
            ref
              ..invalidate(voiceMetricsProvider)
              ..invalidate(userVoiceSessionsProvider);
          },
        ),
      ],
    ),
  );
}

// ─── Metrics Summary ───

class _MetricsSummary extends StatelessWidget {
  const _MetricsSummary({required this.metrics});
  final VoiceMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Padding(
      padding: EdgeInsets.all(context.spacing.alertPadding),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.panelPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'voice_history.metrics'.tr(),
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
                      label: 'voice_history.total_sessions'.tr(),
                      value: '${metrics.totalSessions}',
                    ),
                  ),
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.chat_bubble_outline,
                      label: 'voice_history.total_conversations'.tr(),
                      value: '${metrics.totalConversations}',
                    ),
                  ),
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.timer_outlined,
                      label: 'voice_history.avg_duration'.tr(),
                      value: _formatDuration(
                        metrics.averageSessionDuration.toInt(),
                      ),
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

// ─── Session Card ───

class _SessionCard extends ConsumerWidget {
  const _SessionCard({required this.session});
  final VoiceSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final isActive = session.status == 'active';

    return Card(
      margin: EdgeInsets.only(bottom: context.spacing.paragraphBottomMarginSm),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor:
              (isActive ? context.colors.success : context.colors.primary)
                  .withValues(alpha: 0.15),
          child: Icon(
            isActive ? Icons.mic : Icons.mic_off,
            color: isActive ? context.colors.success : context.colors.primary,
          ),
        ),
        title: Text(
          session.summary ?? 'voice_history.session_default'.tr(),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              _formatDate(session.startedAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (session.durationSeconds != null) ...[
              SizedBox(width: context.spacing.labelBottomMargin),
              Icon(
                Icons.timer_outlined,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: context.spacing.gapXxs),
              Text(
                _formatSessionDuration(session.durationSeconds!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (isActive) ...[
              SizedBox(width: context.spacing.labelBottomMargin),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: context.colors.success.withValues(alpha: 0.15),
                  borderRadius: context.radius.tile,
                ),
                child: Text(
                  'voice_history.active'.tr(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: context.colors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        children: [_SessionDetail(session: session)],
      ),
    );
  }

  String _formatDate(DateTime date) {
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

  String _formatSessionDuration(int seconds) {
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

// ─── Session Detail (expanded) ───

class _SessionDetail extends ConsumerWidget {
  const _SessionDetail({required this.session});
  final VoiceSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final conversationsAsync = ref.watch(
      sessionConversationsProvider(session.id),
    );

    return Padding(
      padding: EdgeInsets.all(context.spacing.panelPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session info row
          Wrap(
            spacing: context.spacing.labelBottomMargin,
            runSpacing: context.spacing.labelBottomMargin,
            children: [
              if (session.emotion != null)
                Chip(
                  avatar: Icon(emotionIcon(session.emotion!), size: 16),
                  label: Text(
                    session.emotion!,
                    style: theme.textTheme.labelSmall,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              Chip(
                avatar: const Icon(Icons.chat_bubble_outline, size: 16),
                label: Text(
                  'voice_history.messages'.tr(
                    args: ['${session.messageCount}'],
                  ),
                  style: theme.textTheme.labelSmall,
                ),
                visualDensity: VisualDensity.compact,
              ),
              Chip(
                avatar: const Icon(Icons.language, size: 16),
                label: Text(
                  session.language.toUpperCase(),
                  style: theme.textTheme.labelSmall,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          // Topics
          if (session.topics != null && session.topics!.isNotEmpty) ...[
            SizedBox(height: context.spacing.labelBottomMargin),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: session.topics!
                  .map(
                    (topic) => Chip(
                      label: Text(topic, style: theme.textTheme.labelSmall),
                      backgroundColor: context.colors.primary.withValues(
                        alpha: 0.08,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],

          SizedBox(height: context.spacing.paragraphBottomMarginSm),

          // Conversations
          Text(
            'voice_history.conversation'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.spacing.labelBottomMargin),

          conversationsAsync.when(
            data: (conversations) {
              if (conversations.isEmpty) {
                return Text(
                  'voice_history.no_messages'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              }
              return Column(
                children: conversations
                    .map((c) => _ConversationBubble(conversation: c))
                    .toList(),
              );
            },
            loading: () => Padding(
              padding: EdgeInsets.symmetric(vertical: context.spacing.alertPadding),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Text(
              'voice_history.error_conversations'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Conversation Bubble ───

class _ConversationBubble extends StatelessWidget {
  const _ConversationBubble({required this.conversation});
  final AiConversation conversation;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isUser = conversation.messageType == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: context.spacing.labelBottomMargin,
          left: isUser ? context.spacing.alertPadding * 2 : 0,
          right: isUser ? 0 : context.spacing.alertPadding * 2,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.paragraphBottomMarginSm,
          vertical: context.spacing.labelBottomMargin,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? context.colors.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: context.radius.tile,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(conversation.content, style: theme.textTheme.bodySmall),
            if (conversation.createdAt != null) ...[
              SizedBox(height: context.spacing.gapXxs),
              Text(
                _formatTime(conversation.createdAt!),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
