import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final isLoggedIn = user != null;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context, isLoggedIn),
        onTap: (index) => _onItemTapped(index, context, isLoggedIn),
        type: BottomNavigationBarType.fixed,
        items: isLoggedIn ? _authItems() : _unauthItems(),
      ),
    );
  }

  List<BottomNavigationBarItem> _authItems() => [
    BottomNavigationBarItem(
      icon: const Icon(Icons.home),
      label: 'nav.home'.tr(),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.history),
      label: 'nav.activity'.tr(),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.dashboard),
      label: 'nav.my_toys'.tr(),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.person),
      label: 'nav.profile'.tr(),
    ),
  ];

  List<BottomNavigationBarItem> _unauthItems() => [
    BottomNavigationBarItem(
      icon: const Icon(Icons.home),
      label: 'nav.home'.tr(),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.history),
      label: 'nav.activity'.tr(),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.dashboard),
      label: 'nav.my_toys'.tr(),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.settings),
      label: 'nav.settings'.tr(),
    ),
  ];

  int _calculateSelectedIndex(BuildContext context, bool isLoggedIn) {
    final String location = GoRouterState.of(context).matchedLocation;

    if (location.startsWith(AppRoutes.home.path)) {
      return 0;
    }
    if (location.startsWith(AppRoutes.activityLog.path)) {
      return 1;
    }

    if (isLoggedIn) {
      if (location.startsWith(AppRoutes.myToys.path)) {
        return 2;
      }
      if (location.startsWith(AppRoutes.profile.path)) {
        return 3;
      }
    } else {
      if (location.startsWith(AppRoutes.myToys.path)) {
        return 2;
      }
      if (location.startsWith(AppRoutes.settings.path)) {
        return 3;
      }
    }

    return 0;
  }

  void _onItemTapped(int index, BuildContext context, bool isLoggedIn) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home.path);
      case 1:
        context.go(AppRoutes.activityLog.path);
      case 2:
        context.go(AppRoutes.myToys.path);
      case 3:
        if (isLoggedIn) {
          context.go(AppRoutes.profile.path);
        } else {
          context.go(AppRoutes.settings.path);
        }
    }
  }
}
