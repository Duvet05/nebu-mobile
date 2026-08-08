import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/personality.dart';
import '../../data/models/toy.dart';
import '../../data/models/user.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/toy_provider.dart';
import '../../presentation/screens/activity_log_screen.dart';
import '../../presentation/screens/child_profile_screen.dart';
import '../../presentation/screens/edit_profile_screen.dart';
import '../../presentation/screens/email_verification_screen.dart';
import '../../presentation/screens/health_check_screen.dart';
import '../../presentation/screens/help_support_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/knowledge_search_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/main_screen.dart';
import '../../presentation/screens/my_toys_screen.dart';
import '../../presentation/screens/notifications_screen.dart';
import '../../presentation/screens/personalities_screen.dart';
import '../../presentation/screens/persons_screen.dart';
import '../../presentation/screens/playground_screen.dart';
import '../../presentation/screens/privacy_policy_screen.dart';
import '../../presentation/screens/privacy_settings_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/qr_scanner_screen.dart';
import '../../presentation/screens/reset_password_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/setup/age_setup_screen.dart';
import '../../presentation/screens/setup/connection_setup_screen.dart';
import '../../presentation/screens/setup/favorites_setup_screen.dart';
import '../../presentation/screens/setup/personality_setup_screen.dart';
import '../../presentation/screens/setup/setup_route_args.dart';
import '../../presentation/screens/setup/toy_name_setup_screen.dart';
import '../../presentation/screens/setup/voice_setup_screen.dart';
import '../../presentation/screens/setup/wifi_setup_screen.dart';
import '../../presentation/screens/setup/world_info_setup_screen.dart';
import '../../presentation/screens/signup_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/terms_of_service_screen.dart';
import '../../presentation/screens/toy_memory_screen.dart';
import '../../presentation/screens/toy_settings_screen.dart';
import '../../presentation/screens/usage_limits_screen.dart';
import '../../presentation/screens/voice_sessions_screen.dart';
import '../../presentation/screens/walkie_talkie_screen.dart';
import '../../presentation/screens/welcome_screen.dart';
import '../config/config.dart';
import '../constants/app_routes.dart';
import '../utils/analytics_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authChange = ValueNotifier<AsyncValue<User?>>(
    const AsyncValue.loading(),
  );
  ref
    ..listen(authProvider, (_, next) => authChange.value = next)
    // Re-assign current value to trigger refreshListenable
    ..listen(hasLocalToysProvider, (_, _) {
      authChange.value = ref.read(authProvider);
    })
    ..listen(setupSkippedProvider, (_, _) {
      authChange.value = ref.read(authProvider);
    })
    ..listen(sessionExpiredProvider, (_, expired) {
      if (expired == true) {
        ref.read(sessionExpiredProvider.notifier).reset();
        ref.read(authProvider.notifier).forceLogout();
      }
    });

  final router = GoRouter(
    initialLocation: AppRoutes.splash.path,
    refreshListenable: authChange,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final toysAsync = ref.read(hasLocalToysProvider);
      final setupAsync = ref.read(setupSkippedProvider);
      // Wait for async providers to resolve — but only block on loading, not errors.
      // Errors in SharedPreferences reads are treated as false (safe default).
      if (auth.isLoading || toysAsync.isLoading || setupAsync.isLoading) {
        return null;
      }

      final user = auth.value;
      final path = state.matchedLocation;
      final hasToys = toysAsync.value ?? false;
      final skippedSetup = setupAsync.value ?? false;

      // The minimum iPhone release removes optional features from both the UI
      // and navigation. Keep this local to the compiled build, never remote.
      if (!Config.isRouteEnabled(path)) {
        return AppRoutes.home.path;
      }

      if (Config.isMinimalIosReleaseConfigured) {
        return _redirectMinimumRelease(
          path: path,
          hasToys: hasToys,
          skippedSetup: skippedSetup,
        );
      }

      return _redirectFullRelease(
        user: user,
        path: path,
        hasToys: hasToys,
        skippedSetup: skippedSetup,
      );
    },
    routes: AppRouter._getRoutes(),
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('errors.route_not_found'.tr()))),
  );

  String? lastTrackedPath;
  void trackCurrentRoute() {
    final path = router.routerDelegate.currentConfiguration.uri.path;
    if (path == lastTrackedPath) {
      return;
    }
    lastTrackedPath = path;
    unawaited(AnalyticsService.instance.logScreenView(path));
  }

  router.routerDelegate.addListener(trackCurrentRoute);
  ref.onDispose(() => router.routerDelegate.removeListener(trackCurrentRoute));
  scheduleMicrotask(trackCurrentRoute);

  return router;
});

String? _redirectMinimumRelease({
  required String path,
  required bool hasToys,
  required bool skippedSetup,
}) {
  if (path == AppRoutes.splash.path) {
    return (hasToys || skippedSetup)
        ? AppRoutes.home.path
        : AppRoutes.welcome.path;
  }

  final isWelcomePage = path == AppRoutes.welcome.path;
  final isSetupPage = path.startsWith('/setup/');
  final isPublicPage = {
    AppRoutes.helpSupport.path,
    AppRoutes.privacyPolicy.path,
    AppRoutes.termsOfService.path,
  }.contains(path);

  if (!isWelcomePage &&
      !isSetupPage &&
      !isPublicPage &&
      !hasToys &&
      !skippedSetup) {
    return AppRoutes.welcome.path;
  }

  return null;
}

String? _redirectFullRelease({
  required User? user,
  required String path,
  required bool hasToys,
  required bool skippedSetup,
}) {
  final isVerifyPage = path == AppRoutes.verifyEmail.path;
  final isResetPasswordPage = path == AppRoutes.resetPassword.path;
  final isAuthPage =
      path == AppRoutes.login.path ||
      path == AppRoutes.signUp.path ||
      path == AppRoutes.welcome.path;
  final isPublicPage = {
    AppRoutes.helpSupport.path,
    AppRoutes.privacyPolicy.path,
    AppRoutes.termsOfService.path,
  }.contains(path);

  // Email verification runs before splash to prevent bypass. Checking for
  // true also covers the null value returned by some social providers.
  if (user != null && user.emailVerified != true && !isPublicPage) {
    return isVerifyPage ? null : AppRoutes.verifyEmail.path;
  }
  if (user != null && isVerifyPage) {
    return hasToys ? AppRoutes.home.path : AppRoutes.connectionSetup.path;
  }

  if (path == AppRoutes.splash.path) {
    return (user != null || hasToys || skippedSetup)
        ? AppRoutes.home.path
        : AppRoutes.welcome.path;
  }

  if (user != null && isAuthPage) {
    return hasToys ? AppRoutes.home.path : AppRoutes.connectionSetup.path;
  }

  final isSetupPage = path.startsWith('/setup/');
  if (user == null &&
      !isAuthPage &&
      !isVerifyPage &&
      !isResetPasswordPage &&
      !isPublicPage &&
      !isSetupPage &&
      !hasToys &&
      !skippedSetup) {
    return AppRoutes.welcome.path;
  }

  final needsAccount = {
    AppRoutes.editProfile.path,
    AppRoutes.usageLimits.path,
    AppRoutes.notifications.path,
    AppRoutes.privacySettings.path,
    AppRoutes.persons.path,
  }.contains(path);

  return needsAccount && user == null ? AppRoutes.login.path : null;
}

class AppRouter {
  AppRouter._();

  static List<RouteBase> _getRoutes() => [
    GoRoute(
      path: AppRoutes.splash.path,
      builder: (_, _) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.welcome.path,
      builder: (_, _) => const WelcomeScreen(),
    ),
    if (Config.isMinimalIosReleaseConfigured) ...[
      _redirectRoute(AppRoutes.login.path, AppRoutes.welcome.path),
      _redirectRoute(AppRoutes.signUp.path, AppRoutes.welcome.path),
      _redirectRoute(AppRoutes.verifyEmail.path, AppRoutes.welcome.path),
      _redirectRoute(AppRoutes.resetPassword.path, AppRoutes.welcome.path),
    ] else ...[
      GoRoute(
        path: AppRoutes.login.path,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp.path,
        builder: (_, _) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail.path,
        builder: (_, s) => EmailVerificationScreen(
          email: s.extra as String?,
          token: s.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword.path,
        builder: (_, s) => ResetPasswordScreen(
          token:
              s.uri.queryParameters['token'] ?? s.uri.queryParameters['code'],
        ),
      ),
    ],

    ShellRoute(
      builder: (context, state, child) => MainScreen(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home.path,
          pageBuilder: (_, _) => const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.activityLog.path,
          pageBuilder: (_, _) =>
              const NoTransitionPage(child: ActivityLogScreen()),
        ),
        GoRoute(
          path: AppRoutes.myToys.path,
          pageBuilder: (_, _) => const NoTransitionPage(child: MyToysScreen()),
        ),
        if (Config.isMinimalIosReleaseConfigured)
          _redirectRoute(AppRoutes.profile.path, AppRoutes.settings.path)
        else
          GoRoute(
            path: AppRoutes.profile.path,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        GoRoute(
          path: AppRoutes.settings.path,
          pageBuilder: (_, _) =>
              const NoTransitionPage(child: SettingsScreen()),
        ),
      ],
    ),

    // Common Apps
    GoRoute(
      path: AppRoutes.qrScanner.path,
      builder: (_, _) => const QRScannerScreen(),
    ),
    if (Config.isMinimalIosReleaseConfigured) ...[
      _redirectRoute(AppRoutes.editProfile.path, AppRoutes.settings.path),
      _redirectRoute(AppRoutes.privacySettings.path, AppRoutes.settings.path),
    ] else ...[
      GoRoute(
        path: AppRoutes.editProfile.path,
        builder: (_, _) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacySettings.path,
        builder: (_, _) => const PrivacySettingsScreen(),
      ),
    ],
    GoRoute(
      path: AppRoutes.privacyPolicy.path,
      builder: (_, _) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: AppRoutes.termsOfService.path,
      builder: (_, _) => const TermsOfServiceScreen(),
    ),
    GoRoute(
      path: AppRoutes.helpSupport.path,
      builder: (_, _) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: AppRoutes.usageLimits.path,
      builder: (_, _) => const UsageLimitsScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications.path,
      builder: (_, _) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.childProfile.path,
      builder: (_, _) => const ChildProfileScreen(),
    ),
    if (Config.isMinimalIosReleaseConfigured)
      _redirectRoute(AppRoutes.persons.path, AppRoutes.settings.path)
    else
      GoRoute(
        path: AppRoutes.persons.path,
        builder: (_, _) => const PersonsScreen(),
      ),
    GoRoute(
      path: AppRoutes.personalities.path,
      builder: (_, _) => const PersonalitiesScreen(),
    ),
    GoRoute(
      path: AppRoutes.healthCheck.path,
      builder: (_, _) => const HealthCheckScreen(),
    ),
    GoRoute(
      path: AppRoutes.knowledgeSearch.path,
      builder: (_, _) => const KnowledgeSearchScreen(),
    ),
    GoRoute(
      path: AppRoutes.voiceHistory.path,
      builder: (_, _) => const VoiceSessionsScreen(),
    ),

    // Dynamic Routes
    GoRoute(
      path: AppRoutes.toySettings.path,
      builder: (c, s) => s.extra is Toy
          ? ToySettingsScreen(toy: s.extra! as Toy)
          : Scaffold(body: Center(child: Text('errors.invalid_toy'.tr()))),
    ),
    GoRoute(
      path: AppRoutes.toyMemory.path,
      builder: (c, s) => s.extra is Toy
          ? ToyMemoryScreen(toy: s.extra! as Toy)
          : Scaffold(body: Center(child: Text('errors.invalid_toy'.tr()))),
    ),
    GoRoute(
      path: AppRoutes.walkieTalkie.path,
      builder: (c, s) => s.extra is Toy
          ? WalkieTalkieScreen(toy: s.extra! as Toy)
          : Scaffold(body: Center(child: Text('errors.invalid_toy'.tr()))),
    ),
    GoRoute(
      path: AppRoutes.playground.path,
      builder: (c, s) =>
          PlaygroundScreen(initialPersonality: s.extra as Personality?),
    ),

    // Setup flow
    ..._getSetupRoutes(),
  ];

  static List<RouteBase> _getSetupRoutes() => [
    GoRoute(
      path: AppRoutes.connectionSetup.path,
      builder: (_, s) => ConnectionSetupScreen(
        args: s.extra is ConnectionSetupRouteArgs
            ? s.extra! as ConnectionSetupRouteArgs
            : const ConnectionSetupRouteArgs(),
      ),
    ),
    GoRoute(
      path: AppRoutes.toyNameSetup.path,
      builder: (_, _) => const ToyNameSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.wifiSetup.path,
      builder: (_, s) => WifiSetupScreen(
        args: s.extra is WifiSetupRouteArgs
            ? s.extra! as WifiSetupRouteArgs
            : WifiSetupRouteArgs(webBleService: s.extra),
      ),
    ),
    GoRoute(
      path: AppRoutes.ageSetup.path,
      builder: (_, _) => const AgeSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.personalitySetup.path,
      builder: (_, _) => const PersonalitySetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.voiceSetup.path,
      builder: (_, _) => const VoiceSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.favoritesSetup.path,
      builder: (_, _) => const FavoritesSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.worldInfoSetup.path,
      builder: (_, _) => const WorldInfoSetupScreen(),
    ),
  ];

  static GoRoute _redirectRoute(String path, String destination) =>
      GoRoute(path: path, redirect: (_, _) => destination);
}
