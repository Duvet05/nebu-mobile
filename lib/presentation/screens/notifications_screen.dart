import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../providers/api_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _filter = 'all';
  List<_Notification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(notificationServiceProvider);
      final data = await service.getMyNotifications();
      if (!mounted) {
        return;
      }
      setState(() {
        _notifications = data
            .map(
              (json) => _Notification(
                id: json['id'] as String? ?? '',
                title: json['title'] as String? ?? '',
                message: json['message'] as String? ?? '',
                type: json['type'] as String? ?? 'system',
                timestamp: DateTime.tryParse(
                      json['createdAt'] as String? ?? '',
                    ) ??
                    DateTime.now(),
                isRead: json['readAt'] != null,
              ),
            )
            .toList();
        _isLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {inal theme = context.theme;

    ffinal filteredNotifications = _filter == 'all'
        ? _notifications
        : _notifications.where((n) => n.type == _filter).toList();

    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('notifications.title'.tr()),
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'notifications.mark_all_read'.tr(),
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('all', 'notifications.all'.tr(), theme),
                const SizedBox(width: 8),
                _buildFilterChip('toys', 'notifications.toys'.tr(), theme),
                const SizedBox(width: 8),
                _buildFilterChip('orders', 'notifications.orders'.tr(), theme),
                const SizedBox(width: 8),
                _buildFilterChip('system', 'notifications.system'.tr(), theme),
              ],
            ),
          ),

          // Notifications list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredNotifications.isEmpty
                    ? _buildEmptyState(theme)
                    : RefreshIndicator(
                        onRefresh: _loadNotifications,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = filteredNotifications[index];
                            return _NotificationCard(
                              notification: notification,
                              onTap: () =>
                                  _handleNotificationTap(notification),
                              onDismiss: () =>
                                  _dismissNotification(notification),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, ThemeData theme) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filter = value);
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
    );
  }

  Widget _buildEmptyState(ThemeData theme) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.notifications_none,
          size: 100,
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
        SizedBox(height: context.spacing.panelPadding),
        Text(
          'notifications.no_notifications'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: context.spacing.titleBottomMarginSm),
        Text(
          'notifications.no_notifications_desc'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Future<void> _markAllAsRead() async {
    final service = ref.read(notificationServiceProvider);
    final success = await service.markAllAsRead();
    if (!mounted) {
      return;
    }
    if (success) {
      setState(() {
        for (final n in _notifications) {
          n.isRead = true;
        }
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('notifications.marked_all_read'.tr())),
    );
  }

  Future<void> _handleNotificationTap(_Notification notification) async {
    final service = ref.read(notificationServiceProvider);
    await service.markAsRead(notification.id);
    if (!mounted) {
      return;
    }
    setState(() {
      notification.isRead = true;
    });
  }

  Future<void> _dismissNotification(_Notification notification) async {
    final service = ref.read(notificationServiceProvider);
    await service.deleteNotification(notification.id);
    if (!mounted) {
      return;
    }
    setState(() {
      _notifications.remove(notification);
    });
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final _Notification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {inal theme = context.theme;

    rreturn Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: context.colors.error,
          borderRadius: context.radius.tile,
        ),
        child: Icon(Icons.delete, color: context.colors.textOnFilled),
      ),
      child: Card(
        margin: EdgeInsets.only(bottom: context.spacing.paragraphBottomMarginSm),
        elevation: notification.isRead ? 0 : 2,
        color: notification.isRead
            ? theme.colorScheme.surface
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: context.radius.tile,
          side: BorderSide(
            color: notification.isRead
                ? Colors.transparent
                : theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: context.radius.tile,
          child: Padding(
            padding: EdgeInsets.all(context.spacing.alertPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getTypeColor(
                      notification.type,
                      context,
                    ).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getTypeIcon(notification.type),
                    color: _getTypeColor(notification.type, context),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: context.spacing.titleBottomMarginSm),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'toys':
        return Icons.smart_toy;
      case 'orders':
        return Icons.shopping_bag;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type, BuildContext context) {
    switch (type) {
      case 'toys':
        return context.colors.secondary;
      case 'orders':
        return context.colors.success;
      case 'system':
        return context.colors.warning;
      default:
        return context.colors.primary;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'notifications.just_now'.tr();
    } else if (difference.inMinutes < 60) {
      return 'notifications.minutes_ago'.tr(
        args: [difference.inMinutes.toString()],
      );
    } else if (difference.inHours < 24) {
      return 'notifications.hours_ago'.tr(
        args: [difference.inHours.toString()],
      );
    } else if (difference.inDays < 7) {
      return 'notifications.days_ago'.tr(args: [difference.inDays.toString()]);
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }
}

class _Notification {
  _Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  bool isRead;
}
