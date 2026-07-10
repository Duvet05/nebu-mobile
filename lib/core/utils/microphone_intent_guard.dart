import 'dart:async';

typedef MicrophoneSetter = Future<void> Function({required bool enabled});

/// Serializes microphone changes and applies only the latest queued intent.
///
/// Platform microphone calls are never allowed to overlap. If a new intent
/// arrives while a call is in flight, that call is allowed to finish and the
/// latest intent is applied immediately afterwards. This gives both enable and
/// disable transitions last-intent-wins semantics.
class MicrophoneIntentGuard {
  MicrophoneIntentGuard(this._setMicrophoneEnabled);

  final MicrophoneSetter _setMicrophoneEnabled;
  int _generation = 0;
  bool _desiredEnabled = false;
  Future<void> _operationTail = Future<void>.value();

  bool get desiredEnabled => _desiredEnabled;

  Future<bool> setEnabled({required bool enabled}) {
    final generation = ++_generation;
    _desiredEnabled = enabled;
    final result = Completer<bool>();

    final previous = _operationTail;
    _operationTail = () async {
      // A failed platform operation is reported to its own caller, but must
      // not poison the queue for later safety-critical intents.
      await previous.onError((_, _) {});

      if (generation != _generation) {
        result.complete(false);
        return;
      }

      try {
        await _setMicrophoneEnabled(enabled: enabled);
        result.complete(generation == _generation && enabled);
      } on Object catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    }();

    return result.future;
  }

  void invalidate() {
    _generation++;
    _desiredEnabled = false;
  }

  Future<void> forceDisable() async {
    await setEnabled(enabled: false);
  }
}
