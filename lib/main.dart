import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/config.dart';
import 'core/constants/storage_keys.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/error_reporting_service.dart';
import 'firebase_options.dart';
import 'presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  // Inicialización paralela (más rápido que secuencial)
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    () async {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        // ignore: avoid_catching_errors
      } on UnsupportedError {
        // Linux and other desktop platforms not configured for Firebase
      } on Exception catch (e) {
        debugPrint('Firebase skip: $e');
      }
    }(),
    () async {
      try {
        await GoogleSignIn.instance.initialize(
          clientId: Config.googleIosClientId.isNotEmpty
              ? Config.googleIosClientId
              : null,
          serverClientId: Config.googleWebClientId.isNotEmpty
              ? Config.googleWebClientId
              : null,
        );
        // ignore: avoid_catching_errors
      } on UnimplementedError {
        // Platform doesn't support Google Sign In (e.g. Linux desktop)
      } on Exception catch (e) {
        debugPrint('GoogleSignIn init skip: $e');
      }
    }(),
  ]);

  final prefs = await SharedPreferences.getInstance();
  final crashReportingAllowed =
      prefs.getBool(StorageKeys.privacyAnalyticsEnabled) ?? true;
  await ErrorReportingService.initialize(
    collectionEnabled: crashReportingAllowed,
  );
  ErrorReportingService.installGlobalErrorHandlers();

  runZonedGuarded(
    () => runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es'), Locale('pt')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const ProviderScope(child: NebuApp()),
      ),
    ),
    (error, stack) {
      unawaited(
        ErrorReportingService.recordError(
          error,
          stack,
          reason: 'Unhandled error in root zone',
          fatal: true,
        ),
      );
      debugPrint('Unhandled app error: $error\n$stack');
    },
  );
}

class NebuApp extends ConsumerWidget {
  const NebuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(themeProvider).value?.themeMode ?? ThemeMode.system;
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: Config.appName,
      debugShowCheckedModeBanner: false,

      // Localización
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // Tema
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      routerConfig: router,
    );
  }
}
