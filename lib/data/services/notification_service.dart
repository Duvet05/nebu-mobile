import 'package:logger/logger.dart';

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
    final response = await _apiService.get<List<dynamic>>('/notifications/my');
    return response.cast<Map<String, dynamic>>().map(AppNotification.fromJson).toList();
  }

  /// Get unread notifications
  Future<List<AppNotification>> getUnreadNotifications() async {
    _logger.d('Fetching unread notifications');
    final response = await _apiService.get<List<dynamic>>(
      '/notifications/my/unread',
    );
    return response.cast<Map<String, dynamic>>().map(AppNotification.fromJson).toList();
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    _logger.d('Marking notification $notificationId as read');
    await _apiService.patch<dynamic>(
      '/notifications/$notificationId/read',
    );
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    _logger.d('Marking all notifications as read');
    await _apiService.patch<dynamic>('/notifications/read-all');
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    _logger.d('Deleting notification $notificationId');
    await _apiService.delete<dynamic>(
      '/notifications/$notificationId',
    );
  }
}
