import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../config/config.dart';

class ErrorReportingService {
  ErrorReportingService._();

  static bool _initialized = false;
  static bool _isCollectionEnabled = false;
  static bool _handlersInstalled = false;

  static bool get isEnabled => _isCollectionEnabled;

  static Future<void> initialize({bool collectionEnabled = true}) async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    if (!Config.enableCrashReporting || !collectionEnabled) {
      await setCollectionEnabled(enabled: false);
      return;
    }

    if (Firebase.apps.isEmpty) {
      return;
    }

    await _safeExecute(() async {
      await setCollectionEnabled(enabled: true);
      await FirebaseCrashlytics.instance.setCustomKey(
        'environment',
        Config.environment,
      );
      await FirebaseCrashlytics.instance.setCustomKey(
        'app_name',
        Config.appName,
      );
    }, context: 'Firebase Crashlytics initialization');
  }

  static Future<void> setCollectionEnabled({required bool enabled}) async {
    final shouldEnable = enabled && Config.enableCrashReporting;
    if (Firebase.apps.isEmpty) {
      _isCollectionEnabled = false;
      return;
    }

    var applied = false;
    await _safeExecute(() async {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        shouldEnable,
      );
      if (!shouldEnable) {
        await FirebaseCrashlytics.instance.deleteUnsentReports();
      }
      applied = true;
    }, context: 'Crashlytics collection toggle');

    _isCollectionEnabled = applied && shouldEnable;
  }

  static Future<void> setUserContext({
    required String userId,
    String? email,
  }) async {
    if (!_isCollectionEnabled) {
      return;
    }

    await _safeExecute(() async {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
      if (email != null && email.isNotEmpty) {
        await FirebaseCrashlytics.instance.setCustomKey('user_email', email);
      }
    }, context: 'Crashlytics setUser');
  }

  static Future<void> clearUserContext() async {
    if (!_isCollectionEnabled) {
      return;
    }

    await _safeExecute(
      () => FirebaseCrashlytics.instance.setUserIdentifier('anonymous'),
      context: 'Crashlytics clearUser',
    );
    await _safeExecute(
      () => FirebaseCrashlytics.instance.deleteUnsentReports(),
      context: 'Crashlytics clearUser',
    );
  }

  static void installGlobalErrorHandlers() {
    if (_handlersInstalled) {
      return;
    }
    _handlersInstalled = true;

    final previousFlutterError = FlutterError.onError;
    FlutterError.onError = (details) {
      unawaited(recordFlutterError(details, fatal: !details.silent));
      previousFlutterError?.call(details);
    };

    final previousZoneError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(
        recordError(
          error,
          stack,
          reason: 'Uncaught platform error',
          fatal: true,
          context: {'handler': 'PlatformDispatcher.onError'},
        ),
      );
      return previousZoneError?.call(error, stack) ?? false;
    };
  }

  static Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, String>? context,
  }) async {
    if (!_isCollectionEnabled) {
      return;
    }

    await _safeExecute(() async {
      if (context != null) {
        for (final entry in context.entries) {
          await FirebaseCrashlytics.instance.setCustomKey(
            entry.key,
            entry.value,
          );
        }
      }

      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
        printDetails: false,
      );
    }, context: reason);
  }

  static Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) async {
    if (!_isCollectionEnabled) {
      return;
    }

    await _safeExecute(() async {
      if (fatal) {
        await FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      } else {
        await FirebaseCrashlytics.instance.recordError(
          details.exception,
          details.stack,
          reason: details.exceptionAsString(),
          printDetails: false,
        );
      }
    }, context: 'Flutter error');
  }

  static Future<void> _safeExecute(
    Future<void> Function() action, {
    String? context,
  }) async {
    try {
      await action();
    } on Exception catch (error) {
      if (kDebugMode) {
        debugPrint('Error reporting disabled: [$context] ${error.runtimeType}');
      }
    }
  }
}
