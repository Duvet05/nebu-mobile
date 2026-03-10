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
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/knowledge_search_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/main_screen.dart';
import '../../presentation/screens/my_toys_screen.dart';
import '../../presentation/screens/notifications_screen.dart';
import '../../presentation/screens/personalities_screen.dart';
import '../../presentation/screens/playground_screen.dart';
import '../../presentation/screens/privacy_policy_screen.dart';
import '../../presentation/screens/privacy_settings_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/qr_scanner_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/setup/age_setup_screen.dart';
import '../../presentation/screens/setup/connection_setup_screen.dart';
import '../../presentation/screens/setup/favorites_setup_screen.dart';
import '../../presentation/screens/setup/personality_setup_screen.dart';
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
import '../constants/app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authChange = ValueNotifier<AsyncValue<User?>>(
    const AsyncValue.loading(),
  );
  ref.listen(authProvider, (_, next) => authChange.value = next);

  return GoRouter(
    initialLocation: AppRoutes.splash.path,
    refreshListenable: authChange,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      if (auth.isLoading) {
        return null;
      }

      final user = auth.value;
      final path = state.matchedLocation;
      final hasToys = ref.read(hasLocalToysProvider).value ?? false;

      // 1. Splash Logic
      if (path == AppRoutes.splash.path) {
        return (user != null || hasToys)
            ? AppRoutes.home.path
            : AppRoutes.welcome.path;
      }

      // 2. Public / Auth Routes
      final isAuthPage =
          path == AppRoutes.login.path ||
          path == AppRoutes.signUp.path ||
          path == AppRoutes.welcome.path;

      // 2a. Email verification gate
      final isVerifyPage = path == AppRoutes.verifyEmail.path;
      if (user != null && user.emailVerified == false) {
        if (!isVerifyPage) {
          return AppRoutes.verifyEmail.path;
        }
        return null;
      }
      if (user != null && isVerifyPage) {
        // Already verified — leave verification screen
        return hasToys ? AppRoutes.home.path : AppRoutes.connectionSetup.path;
      }

      if (user != null && isAuthPage) {
        // No toys yet → setup flow (works for all auth methods)
        if (!hasToys) {
          return AppRoutes.connectionSetup.path;
        }
        return AppRoutes.home.path;
      }

      // 3. After logout: redirect to welcome if no user and no local toys
      //    Allow setup routes so "continue without account" works
      final isSetupPage = path.startsWith('/setup/');
      if (user == null && !isAuthPage && !isSetupPage && !hasToys) {
        return AppRoutes.welcome.path;
      }

      // 4. Security: Check if route requires a real account
      final needsAccount = [
        AppRoutes.editProfile.path,
        AppRoutes.usageLimits.path,
        AppRoutes.notifications.path,
        AppRoutes.privacySettings.path,
      ].contains(path);

      if (needsAccount && user == null) {
        return AppRoutes.login.path;
      }

      // 4. Default: Let it flow
      return null;
    },
    routes: AppRouter._getRoutes(),
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('errors.route_not_found'.tr()))),
  );
});

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
    GoRoute(path: AppRoutes.login.path, builder: (_, _) => const LoginScreen()),
    GoRoute(
      path: AppRoutes.signUp.path,
      builder: (_, _) => const SignUpScreen(),
    ),
    GoRoute(
      path: AppRoutes.verifyEmail.path,
      builder: (_, _) => const EmailVerificationScreen(),
    ),

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
        GoRoute(
          path: AppRoutes.profile.path,
          pageBuilder: (_, _) => const NoTransitionPage(child: ProfileScreen()),
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
    GoRoute(
      path: AppRoutes.editProfile.path,
      builder: (_, _) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.privacySettings.path,
      builder: (_, _) => const PrivacySettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.privacyPolicy.path,
      builder: (_, _) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: AppRoutes.termsOfService.path,
      builder: (_, _) => const TermsOfServiceScreen(),
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
      builder: (c, s) => ToySettingsScreen(toy: s.extra! as Toy),
    ),
    GoRoute(
      path: AppRoutes.toyMemory.path,
      builder: (c, s) => ToyMemoryScreen(toy: s.extra! as Toy),
    ),
    GoRoute(
      path: AppRoutes.walkieTalkie.path,
      builder: (c, s) => WalkieTalkieScreen(toy: s.extra! as Toy),
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
      builder: (_, _) => const ConnectionSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.toyNameSetup.path,
      builder: (_, _) => const ToyNameSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.wifiSetup.path,
      builder: (_, _) => const WifiSetupScreen(),
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
}
