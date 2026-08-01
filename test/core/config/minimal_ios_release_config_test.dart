import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nebu_mobile_flutter/core/config/config.dart';
import 'package:nebu_mobile_flutter/core/config/release_feature_policy.dart';
import 'package:nebu_mobile_flutter/core/constants/app_routes.dart';

void main() {
  const minimumReleaseConfigured = bool.fromEnvironment('MINIMAL_IOS_RELEASE');

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('compiled iOS flag selects the expected account surface', () {
    expect(Config.isMinimalIosRelease, minimumReleaseConfigured);
    expect(
      Config.isFeatureEnabled(ReleaseFeature.accountAuthentication),
      isNot(minimumReleaseConfigured),
    );
    expect(
      Config.isRouteEnabled(AppRoutes.login.path),
      isNot(minimumReleaseConfigured),
    );
    expect(Config.isRouteEnabled(AppRoutes.privacyPolicy.path), isTrue);
  });
}
