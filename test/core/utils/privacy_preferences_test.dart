import 'package:flutter_test/flutter_test.dart';
import 'package:nebu_mobile_flutter/core/constants/storage_keys.dart';
import 'package:nebu_mobile_flutter/core/utils/privacy_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('telemetry is off without a saved choice, including upgrades', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    expect(preferences.analyticsEnabled, isFalse);
    expect(
      preferences.containsKey(StorageKeys.privacyAnalyticsEnabled),
      isFalse,
    );
  });

  for (final allowed in [false, true]) {
    test('respects an explicitly saved telemetry choice: $allowed', () async {
      SharedPreferences.setMockInitialValues({
        StorageKeys.privacyAnalyticsEnabled: allowed,
      });
      final preferences = await SharedPreferences.getInstance();

      expect(preferences.analyticsEnabled, allowed);
    });
  }
}
