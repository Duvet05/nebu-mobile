import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/models/app_notification.dart';
import '../providers/api_provider.dart';
import '../widgets/custom_button.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _filter = 'all';
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  bool _isBusy = false;
  bool _isDismissing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final service = ref.read(notificationServiceProvider);
      final data = await service.getMyNotifications();
      if (!mounted) {
        return;
      }
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } on Exception catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final filteredNotifications = _filter == 'all'
        ? _notifications
        : _notifications.where((n) => n.type == _filter).toList();

    final unreadCount = _notifications.where((n) => n.readAt == null).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('notifications.title'.tr()),
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            CustomButton(
              text: 'notifications.mark_all_read'.tr(),
              onPressed: (_isBusy || _isDismissing) ? null : _markAllAsRead,
              isLoading: _isBusy,
              variant: ButtonVariant.text,
              height: 48,
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.gapXl,
              vertical: context.spacing.gapLg,
            ),
            child: Row(
              children: [
                _buildFilterChip('all', 'notifications.all'.tr(), theme),
                SizedBox(width: context.spacing.gapMd),
                _buildFilterChip('toys', 'notifications.toys'.tr(), theme),
                SizedBox(width: context.spacing.gapMd),
                _buildFilterChip('limits', 'notifications.limits'.tr(), theme),
                SizedBox(width: context.spacing.gapMd),
                _buildFilterChip('system', 'notifications.system'.tr(), theme),
              ],
            ),
          ),

          // Notifications list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? _buildErrorState(theme)
                : filteredNotifications.isEmpty
                ? _buildEmptyState(theme)
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.gapXl,
                      ),
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = filteredNotifications[index];
                        return _NotificationCard(
                          notification: notification,
                          onTap: notification.readAt != null
                              ? null
                              : () => _handleNotificationTap(notification),
                          onDismiss: () => _dismissNotification(notification),
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

  Widget _buildErrorState(ThemeData theme) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 100,
          color: context.colors.error.withValues(alpha: 0.3),
        ),
        SizedBox(height: context.spacing.panelPadding),
        Text(
          'notifications.error_loading'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.spacing.panelPadding),
        CustomButton(
          text: 'common.retry'.tr(),
          onPressed: _loadNotifications,
          variant: ButtonVariant.outline,
        ),
      ],
    ),
  );

  Future<void> _markAllAsRead() async {
    if (_isBusy) {
      return;
    }
    setState(() => _isBusy = true);
    final service = ref.read(notificationServiceProvider);
    try {
      await service.markAllAsRead();
      if (!mounted) {
        return;
      }
      setState(() {
        _notifications = _notifications
            .map((n) => n.copyWith(readAt: DateTime.now()))
            .toList();
        _isBusy = false;
      });
      context.showInfoSnackBar('notifications.marked_all_read'.tr());
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isBusy = false);
      context.showErrorSnackBar(e.message);
    } on Exception catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isBusy = false);
      context.showErrorSnackBar(e.toString());
    }
  }

  Future<void> _handleNotificationTap(AppNotification notification) async {
    if (_isBusy || _isDismissing) {
      return;
    }
    if (notification.readAt != null) {
      return;
    }
    setState(() => _isBusy = true);
    final service = ref.read(notificationServiceProvider);
    try {
      await service.markAsRead(notification.id);
      if (!mounted) {
        return;
      }
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        setState(() {
          _notifications = [
            ..._notifications.sublist(0, index),
            _notifications[index].copyWith(readAt: DateTime.now()),
            ..._notifications.sublist(index + 1),
          ];
          _isBusy = false;
        });
      } else {
        setState(() => _isBusy = false);
      }
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isBusy = false);
      context.showErrorSnackBar(e.message);
    } on Exception catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isBusy = false);
      context.showErrorSnackBar(e.toString());
    }
  }

  Future<void> _dismissNotification(AppNotification notification) async {
    final index = _notifications.indexWhere((n) => n.id == notification.id);
    if (index == -1) {
      return;
    }

    // Optimistic delete — single setState to avoid torn state
    final backup = List<AppNotification>.from(_notifications);
    setState(() {
      _isDismissing = true;
      _notifications = [
        ..._notifications.sublist(0, index),
        ..._notifications.sublist(index + 1),
      ];
    });

    final service = ref.read(notificationServiceProvider);
    try {
      await service.deleteNotification(notification.id);
      if (!mounted) {
        return;
      }
      setState(() => _isDismissing = false);
      context.showInfoSnackBar('notifications.deleted'.tr());
    } on Exception catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _notifications = backup;
        _isDismissing = false;
      });
      context.showErrorSnackBar('notifications.dismiss_error'.tr());
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onDismiss,
    this.onTap,
  });

  final AppNotification notification;
  final VoidCallback? onTap;
  final Future<void> Function() onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isRead = notification.readAt != null;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: context.spacing.gapXxl),
        decoration: BoxDecoration(
          color: context.colors.error,
          borderRadius: context.radius.tile,
        ),
        child: Icon(Icons.delete, color: context.colors.textOnFilled),
      ),
      child: Card(
        margin: EdgeInsets.only(
          bottom: context.spacing.paragraphBottomMarginSm,
        ),
        elevation: isRead ? 0 : 2,
        color: isRead
            ? theme.colorScheme.surface
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: context.radius.tile,
          side: isRead
              ? BorderSide.none
              : BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
                SizedBox(width: context.spacing.gapXl),

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
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isRead)
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
                      SizedBox(height: context.spacing.gapXs),
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
                        _formatTimestamp(notification.createdAt, context),
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
      case 'limits':
        return Icons.timer_outlined;
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
      case 'limits':
        return context.colors.warning;
      case 'system':
        return context.colors.warning;
      default:
        return context.colors.primary;
    }
  }

  String _formatTimestamp(DateTime timestamp, BuildContext context) {
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
      return DateFormat(
        'notifications.date_format'.tr(),
        context.locale.languageCode,
      ).format(timestamp);
    }
  }
}
