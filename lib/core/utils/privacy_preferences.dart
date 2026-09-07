import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

extension PrivacyPreferences on SharedPreferences {
  /// Optional telemetry requires an explicitly saved choice. Reading this
  /// preference must never create consent for a new or upgraded installation.
  bool get analyticsEnabled =>
      getBool(StorageKeys.privacyAnalyticsEnabled) ?? false;
}
