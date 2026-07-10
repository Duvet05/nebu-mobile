import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nebu_mobile_flutter/core/utils/microphone_intent_guard.dart';

void main() {
  test('a later stop wins when enable completes out of order', () async {
    final calls = <bool>[];
    final completions = <Completer<void>>[];
    final guard = MicrophoneIntentGuard(({required enabled}) {
      calls.add(enabled);
      final completion = Completer<void>();
      completions.add(completion);
      return completion.future;
    });

    final start = guard.setEnabled(enabled: true);
    final stop = guard.setEnabled(enabled: false);

    completions[1].complete();
    await stop;
    completions[0].complete();
    await Future<void>.delayed(Duration.zero);

    expect(calls, [true, false, false]);
    completions[2].complete();
    expect(await start, isFalse);
    expect(guard.desiredEnabled, isFalse);
  });

  test('forceDisable invalidates an in-flight enable', () async {
    final calls = <bool>[];
    final first = Completer<void>();
    var invocation = 0;
    final guard = MicrophoneIntentGuard(({required enabled}) async {
      calls.add(enabled);
      if (invocation++ == 0) {
        await first.future;
      }
    });

    final start = guard.setEnabled(enabled: true);
    await guard.forceDisable();
    first.complete();
    await start;

    expect(calls.last, isFalse);
    expect(guard.desiredEnabled, isFalse);
  });
}
