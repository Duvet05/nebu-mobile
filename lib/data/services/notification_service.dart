import 'package:logger/logger.dart';

import '../../core/errors/app_exception.dart';
import '../models/app_notification.dart';
import 'api_service.dart';

class NotificationService {
  NotificationService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  /// Get my notifications
  Future<List<AppNotification>> getMyNotifications() async {
    _logger.d('Fetching my notifications');

    List<dynamic> response;
    try {
      response = await _apiService.get<List<dynamic>>('/notifications/my');
    } on NotFoundException {
      _logger.i('No notifications found (404), returning empty list');
      return [];
    }

    if (response.isEmpty) {
      return [];
    }

    final notifications = <AppNotification>[];
    for (var i = 0; i < response.length; i++) {
      try {
        final json = response[i] as Map<String, dynamic>;
        notifications.add(AppNotification.fromJson(json));
      } on Exception catch (e) {
        _logger.e('Error parsing notification $i: $e');
      }
    }
    return notifications;
  }

  /// Get unread notifications
  Future<List<AppNotification>> getUnreadNotifications() async {
    _logger.d('Fetching unread notifications');

    List<dynamic> response;
    try {
      response = await _apiService.get<List<dynamic>>(
        '/notifications/my/unread',
      );
    } on NotFoundException {
      _logger.i('No unread notifications found (404), returning empty list');
      return [];
    }

    if (response.isEmpty) {
      return [];
    }

    final notifications = <AppNotification>[];
    for (var i = 0; i < response.length; i++) {
      try {
        final json = response[i] as Map<String, dynamic>;
        notifications.add(AppNotification.fromJson(json));
      } on Exception catch (e) {
        _logger.e('Error parsing notification $i: $e');
      }
    }
    return notifications;
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    _logger.d('Marking notification $notificationId as read');
    await _apiService.patch<dynamic>('/notifications/$notificationId/read');
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    _logger.d('Marking all notifications as read');
    await _apiService.patch<dynamic>('/notifications/read-all');
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    _logger.d('Deleting notification $notificationId');
    await _apiService.delete<dynamic>('/notifications/$notificationId');
  }
}
