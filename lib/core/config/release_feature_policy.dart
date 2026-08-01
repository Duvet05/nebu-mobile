import '../constants/app_routes.dart';

/// Features that can be omitted from a deliberately small store release.
enum ReleaseFeature {
  accountAuthentication,
  homeQuickActions,
  healthCheck,
  usageLimits,
  notifications,
}

/// Keeps the minimum-release surface explicit and independent of any backend.
final class ReleaseFeaturePolicy {
  const ReleaseFeaturePolicy({required this.minimalRelease});

  final bool minimalRelease;

  bool isFeatureEnabled(ReleaseFeature feature) {
    if (!minimalRelease) {
      return true;
    }

    return switch (feature) {
      ReleaseFeature.accountAuthentication ||
      ReleaseFeature.homeQuickActions ||
      ReleaseFeature.healthCheck ||
      ReleaseFeature.usageLimits ||
      ReleaseFeature.notifications => false,
    };
  }

  bool isRouteEnabled(String routePath) =>
      !minimalRelease || !_minimalReleaseDisabledRoutes.contains(routePath);

  static final Set<String> _minimalReleaseDisabledRoutes = {
    AppRoutes.login.path,
    AppRoutes.signUp.path,
    AppRoutes.verifyEmail.path,
    AppRoutes.resetPassword.path,
    AppRoutes.profile.path,
    AppRoutes.editProfile.path,
    AppRoutes.privacySettings.path,
    AppRoutes.persons.path,
    AppRoutes.voiceHistory.path,
    AppRoutes.knowledgeSearch.path,
    AppRoutes.personalities.path,
    AppRoutes.playground.path,
    AppRoutes.healthCheck.path,
    AppRoutes.usageLimits.path,
    AppRoutes.notifications.path,
  };
}
