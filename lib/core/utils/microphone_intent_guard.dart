typedef MicrophoneSetter = Future<void> Function({required bool enabled});

/// Serializes microphone intent without assuming platform calls complete in
/// order. If an older "enable" completes after a newer "disable", it issues a
/// final disable so releasing push-to-talk always wins.
class MicrophoneIntentGuard {
  MicrophoneIntentGuard(this._setMicrophoneEnabled);

  final MicrophoneSetter _setMicrophoneEnabled;
  int _generation = 0;
  bool _desiredEnabled = false;

  bool get desiredEnabled => _desiredEnabled;

  Future<bool> setEnabled({required bool enabled}) async {
    final generation = ++_generation;
    _desiredEnabled = enabled;
    await _setMicrophoneEnabled(enabled: enabled);

    if (generation != _generation) {
      if (!_desiredEnabled) {
        await _setMicrophoneEnabled(enabled: false);
      }
      return false;
    }

    return enabled;
  }

  void invalidate() {
    _generation++;
    _desiredEnabled = false;
  }

  Future<void> forceDisable() async {
    invalidate();
    await _setMicrophoneEnabled(enabled: false);
  }
}
