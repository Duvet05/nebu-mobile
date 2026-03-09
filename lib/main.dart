import 'package:easy_localization/easy_localization.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'core/config/config.dart';
import 'core/config/config_loader.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';

final _logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } on Exception catch (e) {
    _logger.w('Firebase init failed (may not be configured yet): $e');
  }

  // Initialize Easy Localization (only show warnings and errors)
  EasyLocalization.logger.enableLevels = [
    LevelMessages.warning,
    LevelMessages.error,
  ];
  await EasyLocalization.ensureInitialized();

  // Load configuration (from .env in dev, dart-define in prod)
  try {
    await ConfigLoader.initialize();
  } on Exception catch (e) {
    _logger
      ..w('Error loading configuration: $e')
      ..w('Make sure .env exists (copy from .env.example)');
    // En desarrollo, podemos continuar con valores por defecto
    // En producción, esto fallará si no hay dart-define
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('es')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(child: NebuApp()),
    ),
  );
}

class NebuApp extends ConsumerWidget {
  const NebuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return themeAsync.when(
      data: (themeState) => MaterialApp.router(
        title: Config.appName,
        debugShowCheckedModeBanner: false,

        // Localization
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,

        // Theme
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeState.themeMode,

        // Router
        routerConfig: router,
      ),
      loading: () => const MaterialApp(
        title: Config.appName,
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (_, _) => const MaterialApp(
        title: Config.appName,
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: Text('Error loading theme'))),
      ),
    );
  }
}
