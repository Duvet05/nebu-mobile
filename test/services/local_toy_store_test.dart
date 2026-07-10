import 'package:flutter_test/flutter_test.dart';
import 'package:nebu_mobile_flutter/data/services/local_toy_store.dart';

void main() {
  test('upsertLocalToyEntry appends a new toy', () {
    final result = upsertLocalToyEntry(
      const [
        {'id': 'local-1', 'name': 'Nebu'},
      ],
      const {'id': 'local-2', 'name': 'Luna'},
    );

    expect(result.map((entry) => entry['id']), ['local-1', 'local-2']);
  });

  test('upsertLocalToyEntry replaces a retry with the same id', () {
    final result = upsertLocalToyEntry(
      const [
        {'id': 'local-1', 'name': 'Old name'},
      ],
      const {'id': 'local-1', 'name': 'Updated name'},
    );

    expect(result, hasLength(1));
    expect(result.single['name'], 'Updated name');
  });

  test('stableLocalSetupToyId keeps the id across retries', () {
    expect(
      stableLocalSetupToyId('local_existing', fallbackId: 'local_new'),
      'local_existing',
    );
    expect(
      stableLocalSetupToyId('remote-id', fallbackId: 'local_new'),
      'local_new',
    );
  });
}
