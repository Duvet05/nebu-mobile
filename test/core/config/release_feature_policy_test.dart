import 'package:flutter_test/flutter_test.dart';
import 'package:nebu_mobile_flutter/core/config/release_feature_policy.dart';
import 'package:nebu_mobile_flutter/core/constants/app_routes.dart';

void main() {
  group('ReleaseFeaturePolicy', () {
    test('keeps all optional features in the full release', () {
      for (final feature in ReleaseFeature.values) {
        expect(
          const ReleaseFeaturePolicy(
            minimalRelease: false,
          ).isFeatureEnabled(feature),
          isTrue,
        );
      }
    });

    test('hides optional features in the minimum release', () {
      for (final feature in ReleaseFeature.values) {
        expect(
          const ReleaseFeaturePolicy(
            minimalRelease: true,
          ).isFeatureEnabled(feature),
          isFalse,
        );
      }
    });

    test('blocks optional routes only in the minimum release', () {
      final optionalRoutes = [
        AppRoutes.voiceHistory,
        AppRoutes.knowledgeSearch,
        AppRoutes.personalities,
        AppRoutes.playground,
        AppRoutes.healthCheck,
        AppRoutes.usageLimits,
        AppRoutes.notifications,
      ];

      for (final route in optionalRoutes) {
        expect(
          const ReleaseFeaturePolicy(
            minimalRelease: true,
          ).isRouteEnabled(route.path),
          isFalse,
        );
      }

      expect(
        const ReleaseFeaturePolicy(
          minimalRelease: true,
        ).isRouteEnabled(AppRoutes.connectionSetup.path),
        isTrue,
      );
    });
  });
}
