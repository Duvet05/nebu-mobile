import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:logger/logger.dart';

import 'api_service.dart';

class FirebasePushService {
  FirebasePushService({required Logger logger, required ApiService apiService})
    : _logger = logger,
      _apiService = apiService;

  final Logger _logger;
  final ApiService _apiService;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    try {
      final settings = await _messaging.requestPermission();
      _logger.d('Notification permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _registerToken();
        _listenForTokenRefresh();
        _setupForegroundHandler();
      }
    } on Exception catch (e) {
      _initialized = false;
      _logger.w('Push notification init failed (will retry): $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _getMessagingToken();
    } on Exception catch (e) {
      _logger.w('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> _registerToken() async {
    try {
      final token = await _getMessagingToken();
      if (token != null) {
        _logger.d('FCM Token obtained');
        await _apiService.post<dynamic>(
          '/notifications/register-device',
          data: {'token': token, 'platform': defaultTargetPlatform.name},
        );
      }
    } on Exception catch (e) {
      _logger.w('Error registering FCM token: $e');
    }
  }

  Future<String?> _getMessagingToken() async {
    if (_requiresApnsToken) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null) {
        _logger.w('APNs token not available yet; deferring FCM token request');
        return null;
      }
    }

    return _messaging.getToken();
  }

  bool get _requiresApnsToken =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  void _listenForTokenRefresh() {
    _messaging.onTokenRefresh.listen((token) async {
      _logger.d('FCM token refreshed');
      try {
        await _apiService.post<dynamic>(
          '/notifications/register-device',
          data: {'token': token, 'platform': defaultTargetPlatform.name},
        );
      } on Exception catch (e) {
        _logger.w('Error registering refreshed token: $e');
      }
    });
  }

  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((message) {
      _logger
        ..d('Foreground message: ${message.messageId}')
        ..d('Notification title: ${message.notification?.title}')
        ..d('Notification body: ${message.notification?.body}')
        ..d('Data: ${message.data}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _logger.d('Message opened app: ${message.messageId}');
    });
  }
}
