import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../config/config.dart';

enum AnalyticsAuthMethod {
  password('password'),
  google('google'),
  apple('apple'),
  facebook('facebook');

  const AnalyticsAuthMethod(this.value);
  final String value;
}

enum AnalyticsTransport {
  bluetoothLe('bluetooth_le'),
  webBluetooth('web_bluetooth');

  const AnalyticsTransport(this.value);
  final String value;
}

enum AnalyticsFailureReason {
  permissionDenied('permission_denied'),
  scanError('scan_error'),
  connectionError('connection_error'),
  timeout('timeout'),
  deviceReportedFailure('device_reported_failure'),
  streamError('stream_error'),
  cancelled('cancelled');

  const AnalyticsFailureReason(this.value);
  final String value;
}

abstract interface class AnalyticsBackend {
  Future<void> setCollectionEnabled({required bool enabled});

  Future<void> setUserProperty({required String name, String? value});

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  });

  Future<void> logLogin({
    required String method,
    Map<String, Object>? parameters,
  });

  Future<void> logSignUp({
    required String method,
    Map<String, Object>? parameters,
  });

  Future<void> logScreenView({required String screenName});
}

final class FirebaseAnalyticsBackend implements AnalyticsBackend {
  FirebaseAnalyticsBackend(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> setCollectionEnabled({required bool enabled}) =>
      _analytics.setAnalyticsCollectionEnabled(enabled);

  @override
  Future<void> setUserProperty({required String name, String? value}) =>
      _analytics.setUserProperty(name: name, value: value);

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) => _analytics.logEvent(name: name, parameters: parameters);

  @override
  Future<void> logLogin({
    required String method,
    Map<String, Object>? parameters,
  }) => _analytics.logLogin(loginMethod: method, parameters: parameters);

  @override
  Future<void> logSignUp({
    required String method,
    Map<String, Object>? parameters,
  }) => _analytics.logSignUp(signUpMethod: method, parameters: parameters);

  @override
  Future<void> logScreenView({required String screenName}) => _analytics
      .logScreenView(screenClass: 'NebuFlutterScreen', screenName: screenName);
}

/// Privacy-aware Analytics facade.
///
/// Only fixed, non-identifying parameters are accepted by the public API.
/// Never add child data, email, audio/transcript content, SSIDs, device IDs,
/// MAC addresses, or free-form error messages to these events.
class AnalyticsService {
  AnalyticsService._();

  @visibleForTesting
  AnalyticsService.forTesting(AnalyticsBackend backend) : _backend = backend;

  static final AnalyticsService instance = AnalyticsService._();

  AnalyticsBackend? _backend;
  bool _isCollectionEnabled = false;

  bool get isCollectionEnabled => _isCollectionEnabled;

  Future<void> initialize({required bool collectionEnabled}) async {
    if (_backend == null) {
      if (Firebase.apps.isEmpty) {
        _isCollectionEnabled = false;
        return;
      }
      _backend = FirebaseAnalyticsBackend(FirebaseAnalytics.instance);
    }

    await setCollectionEnabled(enabled: collectionEnabled);
    if (_isCollectionEnabled) {
      await _safeExecute(
        () => _backend!.setUserProperty(
          name: 'app_environment',
          value: Config.environment,
        ),
        context: 'set environment',
      );
    }
  }

  Future<void> setCollectionEnabled({required bool enabled}) async {
    final backend = _backend;
    if (backend == null) {
      _isCollectionEnabled = false;
      return;
    }

    // Stop app-level logging before waiting for the native SDK to persist the
    // opt-out. This prevents events racing with the privacy toggle.
    if (!enabled) {
      _isCollectionEnabled = false;
    }
    final applied = await _safeExecute(
      () => backend.setCollectionEnabled(enabled: enabled),
      context: 'collection toggle',
    );
    _isCollectionEnabled = applied && enabled;
  }

  Future<void> logLogin(AnalyticsAuthMethod method) async {
    if (!_isCollectionEnabled) {
      return;
    }
    await _safeExecute(
      () => _backend!.logLogin(method: method.value),
      context: 'login',
    );
  }

  Future<void> logSignUp(AnalyticsAuthMethod method) async {
    if (!_isCollectionEnabled) {
      return;
    }
    await _safeExecute(
      () => _backend!.logSignUp(method: method.value),
      context: 'sign_up',
    );
  }

  Future<void> logScreenView(String routePath) async {
    if (!_isCollectionEnabled) {
      return;
    }
    final screenName = _screenNameFor(routePath);
    await _safeExecute(
      () => _backend!.logScreenView(screenName: screenName),
      context: 'screen_view',
    );
  }

  Future<void> logDeviceScanStarted(AnalyticsTransport transport) =>
      _logEvent('device_scan_started', {'transport': transport.value});

  Future<void> logDeviceScanFailed(
    AnalyticsTransport transport,
    AnalyticsFailureReason reason,
  ) => _logEvent('device_scan_failed', {
    'transport': transport.value,
    'failure_reason': reason.value,
  });

  Future<void> logDevicePairSucceeded(AnalyticsTransport transport) =>
      _logEvent('device_pair_succeeded', {'transport': transport.value});

  Future<void> logDevicePairFailed(
    AnalyticsTransport transport,
    AnalyticsFailureReason reason,
  ) => _logEvent('device_pair_failed', {
    'transport': transport.value,
    'failure_reason': reason.value,
  });

  Future<void> logWifiProvisionStarted(AnalyticsTransport transport) =>
      _logEvent('wifi_provision_started', {'transport': transport.value});

  Future<void> logWifiProvisionSucceeded(AnalyticsTransport transport) =>
      _logEvent('wifi_provision_succeeded', {'transport': transport.value});

  Future<void> logWifiProvisionFailed(
    AnalyticsTransport transport,
    AnalyticsFailureReason reason,
  ) => _logEvent('wifi_provision_failed', {
    'transport': transport.value,
    'failure_reason': reason.value,
  });

  Future<void> logToySetupCompleted({required bool deviceRegistered}) =>
      _logEvent('toy_setup_completed', {
        'device_registered': deviceRegistered ? 1 : 0,
      });

  Future<void> _logEvent(String name, Map<String, Object> parameters) async {
    if (!_isCollectionEnabled) {
      return;
    }
    await _safeExecute(
      () => _backend!.logEvent(name: name, parameters: parameters),
      context: name,
    );
  }

  String _screenNameFor(String routePath) {
    final path = Uri.tryParse(routePath)?.path ?? routePath;
    if (path == '/') {
      return 'splash';
    }
    return path
        .replaceFirst(RegExp('^/+'), '')
        .replaceAll('/', '_')
        .replaceAll('-', '_');
  }

  Future<bool> _safeExecute(
    Future<void> Function() action, {
    required String context,
  }) async {
    try {
      await action();
      return true;
    } on Exception catch (error) {
      if (kDebugMode) {
        debugPrint('Analytics skipped: [$context] ${error.runtimeType}');
      }
    }
    return false;
  }
}
