List<Map<String, dynamic>> upsertLocalToyEntry(
  Iterable<Map<String, dynamic>> existing,
  Map<String, dynamic> toy,
) {
  final entries = existing.map(Map<String, dynamic>.from).toList();
  final toyId = toy['id'];
  final index = entries.indexWhere((entry) => entry['id'] == toyId);
  if (index == -1) {
    entries.add(Map<String, dynamic>.from(toy));
  } else {
    entries[index] = Map<String, dynamic>.from(toy);
  }
  return entries;
}

String stableLocalSetupToyId(String? storedId, {required String fallbackId}) {
  if (storedId != null && storedId.startsWith('local_')) {
    return storedId;
  }
  return fallbackId;
}
