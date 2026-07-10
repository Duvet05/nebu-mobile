import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nebu_mobile_flutter/core/utils/microphone_intent_guard.dart';

void main() {
  test('serializes calls and a later stop wins', () async {
    final calls = <bool>[];
    final completions = <Completer<void>>[];
    var activeCalls = 0;
    var maxActiveCalls = 0;
    final guard = MicrophoneIntentGuard(({required enabled}) {
      calls.add(enabled);
      activeCalls++;
      if (activeCalls > maxActiveCalls) {
        maxActiveCalls = activeCalls;
      }
      final completion = Completer<void>();
      completions.add(completion);
      return completion.future.whenComplete(() => activeCalls--);
    });

    final start = guard.setEnabled(enabled: true);
    await Future<void>.delayed(Duration.zero);
    final stop = guard.setEnabled(enabled: false);

    expect(calls, [true]);
    completions[0].complete();
    await Future<void>.delayed(Duration.zero);
    expect(calls, [true, false]);

    completions[1].complete();
    expect(await start, isFalse);
    expect(await stop, isFalse);
    expect(maxActiveCalls, 1);
    expect(guard.desiredEnabled, isFalse);
  });

  test('a later start wins after an in-flight disable', () async {
    final calls = <bool>[];
    final completions = <Completer<void>>[];
    final guard = MicrophoneIntentGuard(({required enabled}) {
      calls.add(enabled);
      final completion = Completer<void>();
      completions.add(completion);
      return completion.future;
    });

    final stop = guard.setEnabled(enabled: false);
    await Future<void>.delayed(Duration.zero);
    final start = guard.setEnabled(enabled: true);

    expect(calls, [false]);
    completions[0].complete();
    await Future<void>.delayed(Duration.zero);
    expect(calls, [false, true]);

    completions[1].complete();
    expect(await stop, isFalse);
    expect(await start, isTrue);
    expect(guard.desiredEnabled, isTrue);
  });

  test('skips queued intents that are no longer current', () async {
    final calls = <bool>[];
    final completions = <Completer<void>>[];
    final guard = MicrophoneIntentGuard(({required enabled}) {
      calls.add(enabled);
      final completion = Completer<void>();
      completions.add(completion);
      return completion.future;
    });

    final firstStart = guard.setEnabled(enabled: true);
    await Future<void>.delayed(Duration.zero);
    final staleStop = guard.setEnabled(enabled: false);
    final latestStart = guard.setEnabled(enabled: true);

    completions[0].complete();
    await Future<void>.delayed(Duration.zero);
    expect(calls, [true, true]);

    completions[1].complete();
    expect(await firstStart, isFalse);
    expect(await staleStop, isFalse);
    expect(await latestStart, isTrue);
  });

  test('forceDisable is serialized after an in-flight enable', () async {
    final calls = <bool>[];
    final completions = <Completer<void>>[];
    final guard = MicrophoneIntentGuard(({required enabled}) {
      calls.add(enabled);
      final completion = Completer<void>();
      completions.add(completion);
      return completion.future;
    });

    final start = guard.setEnabled(enabled: true);
    await Future<void>.delayed(Duration.zero);
    final stop = guard.forceDisable();

    expect(calls, [true]);
    completions[0].complete();
    await Future<void>.delayed(Duration.zero);
    expect(calls, [true, false]);

    completions[1].complete();
    expect(await start, isFalse);
    await stop;
    expect(guard.desiredEnabled, isFalse);
  });
}
