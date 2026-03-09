import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización paralela (más rápido que secuencial)
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    // Firebase se inicializa solo si es necesario, o lo movemos a un provider
    () async {
      try {
        await Firebase.initializeApp();
      } on Exception catch (e) {
        debugPrint('Firebase skip: $e');
      }
    }(),
  ]);

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
    // Escuchamos el tema, pero usamos un valor inicial para evitar el "loading flicker"
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

      // Tema (Línea Directa)
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      routerConfig: router,
    );
  }
}
