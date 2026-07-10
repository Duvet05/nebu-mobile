import 'package:flutter_test/flutter_test.dart';
import 'package:nebu_mobile_flutter/core/utils/livekit_participant_selector.dart';

void main() {
  test('uses the backend-provided device identity', () {
    final selected = selectLiveKitDeviceIdentity(const [
      'voice-agent-1',
      'ESP32_OTHER',
      'ESP32_EXPECTED',
    ], expectedIdentity: 'ESP32_EXPECTED');

    expect(selected, 'ESP32_EXPECTED');
  });

  test('does not fall back to a different device when identity is known', () {
    final selected = selectLiveKitDeviceIdentity(const [
      'voice-agent-1',
      'ESP32_OTHER',
    ], expectedIdentity: 'ESP32_EXPECTED');

    expect(selected, isNull);
  });

  test('legacy fallback ignores agents and parents deterministically', () {
    final selected = selectLiveKitDeviceIdentity(const [
      'user-parent-1',
      'ESP32_BBBBBBBBBBBB',
      'voice-agent-1',
      'ESP32_AAAAAAAAAAAA',
    ]);

    expect(selected, 'ESP32_AAAAAAAAAAAA');
  });

  test('reports disconnected when only non-device participants remain', () {
    final selected = selectLiveKitDeviceIdentity(const [
      'voice-agent-1',
      'user-parent-1',
    ]);

    expect(selected, isNull);
  });
}
