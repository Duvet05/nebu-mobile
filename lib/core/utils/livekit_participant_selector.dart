/// Resolves the physical IoT device participant without relying on LiveKit's
/// participant insertion order.
///
/// New backends return [expectedIdentity]. The ESP32 fallback keeps the app
/// compatible with servers deployed before that additive response field.
String? selectLiveKitDeviceIdentity(
  Iterable<String> participantIdentities, {
  String? expectedIdentity,
}) {
  final identities = participantIdentities
      .map((identity) => identity.trim())
      .where((identity) => identity.isNotEmpty)
      .toSet();
  final expected = expectedIdentity?.trim();

  if (expected != null && expected.isNotEmpty) {
    return identities.contains(expected) ? expected : null;
  }

  final legacyDeviceIdentities =
      identities.where((identity) => identity.startsWith('ESP32_')).toList()
        ..sort();
  return legacyDeviceIdentities.firstOrNull;
}
