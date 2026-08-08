import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nebu_mobile_flutter/core/utils/analytics_service.dart';

void main() {
  group('AnalyticsService', () {
    late _FakeAnalyticsBackend backend;
    late AnalyticsService service;

    setUp(() {
      backend = _FakeAnalyticsBackend();
      service = AnalyticsService.forTesting(backend);
    });

    test('enables collection and sets only the app environment', () async {
      await service.initialize(collectionEnabled: true);

      expect(service.isCollectionEnabled, isTrue);
      expect(backend.collectionValues, [true]);
      expect(backend.userProperties.keys, ['app_environment']);
      expect(backend.userProperties['app_environment'], isNotEmpty);
    });

    test('does not emit events when collection is disabled', () async {
      await service.initialize(collectionEnabled: false);
      await service.logLogin(AnalyticsAuthMethod.password);
      await service.logScreenView('/home');

      expect(service.isCollectionEnabled, isFalse);
      expect(backend.events, isEmpty);
    });

    test('uses recommended authentication event names and methods', () async {
      await service.initialize(collectionEnabled: true);
      await service.logLogin(AnalyticsAuthMethod.google);
      await service.logSignUp(AnalyticsAuthMethod.password);

      expect(backend.events, [
        const _RecordedEvent('login', {'method': 'google'}),
        const _RecordedEvent('sign_up', {'method': 'password'}),
      ]);
    });

    test('normalizes route paths without retaining query data', () async {
      await service.initialize(collectionEnabled: true);
      await service.logScreenView('/setup/toy-name?source=email');

      expect(
        backend.events.single,
        const _RecordedEvent('screen_view', {'screen_name': 'setup_toy_name'}),
      );
    });

    test(
      'device and Wi-Fi events contain only fixed safe parameters',
      () async {
        await service.initialize(collectionEnabled: true);
        await service.logDevicePairFailed(
          AnalyticsTransport.bluetoothLe,
          AnalyticsFailureReason.connectionError,
        );
        await service.logWifiProvisionSucceeded(
          AnalyticsTransport.webBluetooth,
        );
        await service.logToySetupCompleted(deviceRegistered: true);

        expect(backend.events, [
          const _RecordedEvent('device_pair_failed', {
            'transport': 'bluetooth_le',
            'failure_reason': 'connection_error',
          }),
          const _RecordedEvent('wifi_provision_succeeded', {
            'transport': 'web_bluetooth',
          }),
          const _RecordedEvent('toy_setup_completed', {'device_registered': 1}),
        ]);
      },
    );

    test('stops emitting before the native privacy toggle completes', () async {
      await service.initialize(collectionEnabled: true);
      final nativeToggle = Completer<void>();
      backend.collectionGate = nativeToggle;

      final disableFuture = service.setCollectionEnabled(enabled: false);
      await service.logDeviceScanStarted(AnalyticsTransport.bluetoothLe);

      expect(service.isCollectionEnabled, isFalse);
      expect(backend.events, isEmpty);

      nativeToggle.complete();
      await disableFuture;
      expect(backend.collectionValues, [true, false]);
    });
  });
}

final class _FakeAnalyticsBackend implements AnalyticsBackend {
  final List<bool> collectionValues = [];
  final Map<String, String?> userProperties = {};
  final List<_RecordedEvent> events = [];
  Completer<void>? collectionGate;

  @override
  Future<void> setCollectionEnabled({required bool enabled}) async {
    collectionValues.add(enabled);
    await collectionGate?.future;
  }

  @override
  Future<void> setUserProperty({required String name, String? value}) async {
    userProperties[name] = value;
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    events.add(_RecordedEvent(name, parameters ?? const {}));
  }

  @override
  Future<void> logLogin({
    required String method,
    Map<String, Object>? parameters,
  }) async {
    events.add(_RecordedEvent('login', {'method': method, ...?parameters}));
  }

  @override
  Future<void> logSignUp({
    required String method,
    Map<String, Object>? parameters,
  }) async {
    events.add(_RecordedEvent('sign_up', {'method': method, ...?parameters}));
  }

  @override
  Future<void> logScreenView({required String screenName}) async {
    events.add(_RecordedEvent('screen_view', {'screen_name': screenName}));
  }
}

final class _RecordedEvent {
  const _RecordedEvent(this.name, this.parameters);

  final String name;
  final Map<String, Object> parameters;

  @override
  bool operator ==(Object other) =>
      other is _RecordedEvent &&
      other.name == name &&
      _mapsEqual(other.parameters, parameters);

  @override
  int get hashCode =>
      Object.hash(name, Object.hashAllUnordered(parameters.entries));

  @override
  String toString() => '$name $parameters';
}

bool _mapsEqual(Map<String, Object> left, Map<String, Object> right) {
  if (left.length != right.length) {
    return false;
  }
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}
