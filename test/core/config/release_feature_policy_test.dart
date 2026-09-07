import 'package:flutter_test/flutter_test.dart';
import 'package:nebu_mobile_flutter/core/config/release_feature_policy.dart';
import 'package:nebu_mobile_flutter/core/constants/app_routes.dart';

void main() {
  group('ReleaseFeaturePolicy', () {
    test('keeps current optional features in the full release', () {
      for (final feature in ReleaseFeature.values) {
        expect(
          const ReleaseFeaturePolicy(
            minimalRelease: false,
          ).isFeatureEnabled(feature),
          feature == ReleaseFeature.homeQuickActions ? isFalse : isTrue,
        );
      }
    });

    test('retires Explore and clone creation for every release and user', () {
      for (final minimalRelease in [false, true]) {
        final policy = ReleaseFeaturePolicy(minimalRelease: minimalRelease);
        expect(
          policy.isFeatureEnabled(ReleaseFeature.homeQuickActions),
          isFalse,
        );
        for (final route in [
          AppRoutes.voiceClone,
          AppRoutes.voiceHistory,
          AppRoutes.knowledgeSearch,
        ]) {
          expect(
            policy.isRouteEnabled(route.path),
            isFalse,
            reason: route.name,
          );
        }
      }
    });

    test(
      'preserves MVP accounts, child profiles, personalities and toy tools',
      () {
        const policy = ReleaseFeaturePolicy(minimalRelease: false);
        for (final route in [
          AppRoutes.login,
          AppRoutes.signUp,
          AppRoutes.verifyEmail,
          AppRoutes.resetPassword,
          AppRoutes.profile,
          AppRoutes.editProfile,
          AppRoutes.privacySettings,
          AppRoutes.childProfile,
          AppRoutes.persons,
          AppRoutes.personalities,
          AppRoutes.playground,
          AppRoutes.home,
          AppRoutes.myToys,
          AppRoutes.activityLog,
          AppRoutes.toySettings,
          AppRoutes.toyMemory,
          AppRoutes.walkieTalkie,
          AppRoutes.connectionSetup,
          AppRoutes.toyNameSetup,
          AppRoutes.wifiSetup,
          AppRoutes.ageSetup,
          AppRoutes.personalitySetup,
          AppRoutes.voiceSetup,
          AppRoutes.favoritesSetup,
          AppRoutes.worldInfoSetup,
        ]) {
          expect(policy.isRouteEnabled(route.path), isTrue, reason: route.name);
        }
      },
    );

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
        AppRoutes.login,
        AppRoutes.signUp,
        AppRoutes.verifyEmail,
        AppRoutes.resetPassword,
        AppRoutes.profile,
        AppRoutes.editProfile,
        AppRoutes.privacySettings,
        AppRoutes.persons,
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
      expect(
        const ReleaseFeaturePolicy(
          minimalRelease: true,
        ).isRouteEnabled(AppRoutes.privacyPolicy.path),
        isTrue,
      );
      expect(
        const ReleaseFeaturePolicy(
          minimalRelease: true,
        ).isRouteEnabled(AppRoutes.termsOfService.path),
        isTrue,
      );
    });
  });
}
