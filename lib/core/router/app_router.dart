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
import '../../presentation/screens/health_check_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/main_screen.dart';
import '../../presentation/screens/my_toys_screen.dart';
import '../../presentation/screens/notifications_screen.dart';
import '../../presentation/screens/orders_screen.dart';
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
import '../../presentation/screens/walkie_talkie_screen.dart';
import '../../presentation/screens/welcome_screen.dart';
import '../constants/app_routes.dart';

/// Notifier that bridges Riverpod auth state changes to GoRouter's refreshListenable
class _AuthChangeNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final _authChangeNotifier = _AuthChangeNotifier();

// Router provider - created once, uses refreshListenable for auth state changes
final routerProvider = Provider<GoRouter>((ref) {
  // Listen to auth changes and trigger GoRouter redirect re-evaluation
  ref.listen(authProvider, (_, _) {
    _authChangeNotifier.notify();
  });
  ref.listen(hasLocalToysProvider, (_, _) {
    _authChangeNotifier.notify();
  });

  return GoRouter(
    initialLocation: AppRoutes.splash.path,
    refreshListenable: _authChangeNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final hasLocalToys = ref.read(hasLocalToysProvider).value ?? false;
      return AppRouter._redirectLogic(authState, state, hasLocalToys: hasLocalToys);
    },
    routes: AppRouter._getRoutesStatic(),
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error?.message}')),
    ),
  );
});

class AppRouter {
  AppRouter._();

  static String? _redirectLogic(
    AsyncValue<User?> authState,
    GoRouterState state, {
    bool hasLocalToys = false,
  }) {
    final isAuthenticated = authState.value != null;
    final isLoading = authState.isLoading;
    final location = state.matchedLocation;

    // While auth is still loading, don't redirect — stay on current page
    if (isLoading) {
      return null;
    }

    // Splash screen: redirect once auth state is resolved
    if (location == AppRoutes.splash.path) {
      if (isAuthenticated || hasLocalToys) {
        return AppRoutes.home.path;
      }
      return AppRoutes.welcome.path;
    }

    // Routes accessible only when not authenticated
    final unauthenticatedRoutes = [
      AppRoutes.welcome.path,
      AppRoutes.login.path,
      AppRoutes.signUp.path,
    ];

    if (isAuthenticated) {
      // If authenticated, redirect from unauthenticated-only routes directly to home
      if (unauthenticatedRoutes.contains(location)) {
        return AppRoutes.home.path;
      }
    } else {
      final isSetupRoute = location.startsWith('/setup');

      if (hasLocalToys) {
        // User has a local toy — allow all app routes except auth-only ones
        // Only block routes that require a real account (profile, orders, etc.)
        final authRequiredRoutes = [
          AppRoutes.editProfile.path,
          AppRoutes.orders.path,
          AppRoutes.notifications.path,
          AppRoutes.privacySettings.path,
        ];
        if (authRequiredRoutes.contains(location)) {
          return AppRoutes.login.path;
        }
      } else {
        // No local toys, no auth — only allow onboarding routes
        final allowedUnauthRoutes = [
          ...unauthenticatedRoutes,
          AppRoutes.home.path,
          AppRoutes.activityLog.path,
          AppRoutes.myToys.path,
          AppRoutes.settings.path,
        ];

        if (!allowedUnauthRoutes.contains(location) && !isSetupRoute) {
          return AppRoutes.welcome.path;
        }
      }
    }

    return null; // No redirection needed
  }

  static List<RouteBase> _getRoutesStatic() => [
    GoRoute(
      path: AppRoutes.splash.path,
      builder: (_, _) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.welcome.path,
      builder: (_, _) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.login.path,
      builder: (_, _) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signUp.path,
      builder: (_, _) => const SignUpScreen(),
    ),

    // Main application shell
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

    // Other top-level screens
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
      path: AppRoutes.orders.path,
      builder: (_, _) => const OrdersScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications.path,
      builder: (_, _) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.toySettings.path,
      builder: (context, state) {
        final toy = state.extra as Toy?;
        if (toy == null) {
          return Scaffold(
            appBar: AppBar(title: Text('common.error'.tr())),
            body: Center(child: Text('common.invalid_data'.tr())),
          );
        }
        return ToySettingsScreen(toy: toy);
      },
    ),
    GoRoute(
      path: AppRoutes.toyMemory.path,
      builder: (context, state) {
        final toy = state.extra as Toy?;
        if (toy == null) {
          return Scaffold(
            appBar: AppBar(title: Text('common.error'.tr())),
            body: Center(child: Text('common.invalid_data'.tr())),
          );
        }
        return ToyMemoryScreen(toy: toy);
      },
    ),
    GoRoute(
      path: AppRoutes.walkieTalkie.path,
      builder: (context, state) {
        final toy = state.extra as Toy?;
        if (toy == null) {
          return Scaffold(
            appBar: AppBar(title: Text('common.error'.tr())),
            body: Center(child: Text('common.invalid_data'.tr())),
          );
        }
        return WalkieTalkieScreen(toy: toy);
      },
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
      path: AppRoutes.playground.path,
      builder: (context, state) {
        final personality = state.extra as Personality?;
        return PlaygroundScreen(initialPersonality: personality);
      },
    ),

    // Setup flow
    ..._getSetupRoutesStatic(),
  ];

  static List<RouteBase> _getSetupRoutesStatic() => [
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
