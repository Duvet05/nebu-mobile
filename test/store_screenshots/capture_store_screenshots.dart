// Harness para generar las capturas del listing de Play Store.
//
// No es un test de CI (no termina en _test.dart): se ejecuta explícitamente
//   flutter test test/store_screenshots/capture_store_screenshots.dart
// y escribe PNGs de 1080x1920 (9:16, apto para Play) en
//   build/store_screenshots/<locale>/NN_nombre.png
//
// Renderiza pantallas reales con datos demo y las fuentes empaquetadas,
// por lo que las imágenes reflejan la UI verdadera de la app (requisito de
// la política de metadata de Google Play).

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/mockito.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/data/models/person.dart';
import 'package:nebu_mobile_flutter/data/models/personality.dart';
import 'package:nebu_mobile_flutter/data/models/toy.dart';
import 'package:nebu_mobile_flutter/data/models/user.dart';
import 'package:nebu_mobile_flutter/presentation/providers/api_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/auth_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/person_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/personality_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/toy_provider.dart';
import 'package:nebu_mobile_flutter/presentation/screens/home_screen.dart';
import 'package:nebu_mobile_flutter/presentation/screens/main_screen.dart';
import 'package:nebu_mobile_flutter/presentation/screens/persons_screen.dart';
import 'package:nebu_mobile_flutter/presentation/screens/setup/personality_setup_screen.dart';
import 'package:nebu_mobile_flutter/presentation/screens/setup/voice_setup_screen.dart';
import 'package:nebu_mobile_flutter/presentation/screens/toy_settings_screen.dart';
import 'package:nebu_mobile_flutter/presentation/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/localization_test_helper.dart';
import '../services/mocks.dart';

const _demoToy = Toy(
  id: 'demo-toy-1',
  name: 'Nebu',
  status: ToyStatus.connected,
  ownerId: 'demo-person-1',
  batteryLevel: '85%',
  model: 'NB-100',
  personalityProfile: 'peruvian',
  settings: {
    'voicePreference': 'default-oklrorszoxbwzfdj8zjhng__nebu',
    'childAge': '6-8',
    'enableWalkieTalkie': true,
    'enableVarietyEngine': true,
  },
);

const _demoToy2 = Toy(
  id: 'demo-toy-2',
  name: 'Dino',
  status: ToyStatus.disconnected,
  ownerId: 'demo-person-2',
  batteryLevel: '52%',
  model: 'NB-100',
);

class _FakeToyNotifier extends ToyNotifier {
  @override
  Future<List<Toy>> build() async => const [_demoToy, _demoToy2];

  @override
  Future<void> loadMyToys() async {}

  @override
  Future<void> syncMyToys() async {}

  @override
  Future<Toy> getToyById(String id) async =>
      id == _demoToy2.id ? _demoToy2 : _demoToy;
}

class _FakeAuthNotifier extends AuthNotifier {
  @override
  Future<User?> build() async =>
      const User(id: 'demo-user', email: 'demo@nebu.pe', firstName: 'Camila');
}

class _FakePersonalitiesNotifier extends PersonalitiesNotifier {
  @override
  Future<List<Personality>> build() async => const [
    Personality(id: 'peruvian', name: 'Nebu', description: 'Nebu'),
  ];
}

class _FakePersonNotifier extends PersonNotifier {
  @override
  Future<List<Person>> build() async => [
    Person(
      id: 'demo-person-1',
      givenName: 'Lucas',
      birthDate: DateTime(2018, 5, 10),
    ),
    Person(
      id: 'demo-person-2',
      givenName: 'Emma',
      birthDate: DateTime(2020, 6, 15),
    ),
  ];

  @override
  Future<void> loadMyPersons() async {}
}

/// Shell único: EasyLocalization/MaterialApp se montan una sola vez y las
/// pantallas se intercambian con setState (el singleton de easy_localization
/// no sobrevive a un segundo pumpWidget en el mismo proceso).
final _shellKey = GlobalKey<_ShellState>();

class _Shell extends StatefulWidget {
  const _Shell({super.key});

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  // ValueNotifier: GoRouter cachea el resultado del builder de la ruta, así
  // que el swap de pantalla debe reconstruir vía listenable, no por setState.
  final ValueNotifier<Widget> _screen = ValueNotifier(const SizedBox.shrink());

  late final GoRouter router = GoRouter(
    initialLocation: '/shot',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())],
      ),
      GoRoute(
        path: '/shot',
        builder: (_, _) => ValueListenableBuilder<Widget>(
          valueListenable: _screen,
          builder: (_, screen, _) => screen,
        ),
      ),
    ],
  );

  void show(Widget screen) {
    _screen.value = screen;
    router.go('/shot');
  }

  void goHome() => router.go('/home');

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: context.localizationDelegates,
    routerConfig: router,
  );
}

Future<void> _loadFonts() async {
  final manifest =
      json.decode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest) {
    final map = family as Map<String, dynamic>;
    final loader = FontLoader(map['family'] as String);
    for (final font in map['fonts'] as List) {
      loader.addFont(rootBundle.load((font as Map)['asset'] as String));
    }
    await loader.load();
  }

  const googleFonts = {
    'Manrope': [
      'assets/google_fonts/Manrope-Regular.ttf',
      'assets/google_fonts/Manrope-Medium.ttf',
      'assets/google_fonts/Manrope-SemiBold.ttf',
    ],
    'Funnel Display': [
      'assets/google_fonts/FunnelDisplay-Regular.ttf',
      'assets/google_fonts/FunnelDisplay-Medium.ttf',
      'assets/google_fonts/FunnelDisplay-SemiBold.ttf',
    ],
    'FunnelDisplay': [
      'assets/google_fonts/FunnelDisplay-Regular.ttf',
      'assets/google_fonts/FunnelDisplay-Medium.ttf',
      'assets/google_fonts/FunnelDisplay-SemiBold.ttf',
    ],
  };
  for (final entry in googleFonts.entries) {
    final loader = FontLoader(entry.key);
    for (final asset in entry.value) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('genera capturas del listing de Play', (tester) async {
    // 1080x1920 físico = 9:16 exacto, el ratio más seguro para Play.
    tester.view
      ..physicalSize = const Size(1080, 1920)
      ..devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final outRoot = Directory('build/store_screenshots');

    await tester.runAsync(_loadFonts);

    // The screenshot harness never contacts a backend or creates consent.
    final demoApi = MockApiService();
    when(
      demoApi.get<Map<String, dynamic>>('/users/demo-user/setup'),
    ).thenAnswer((_) async => <String, dynamic>{'parentalConsent': null});

    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es'), Locale('pt')],
        path: 'assets/translations',
        assetLoader: const TestJsonAssetLoader(),
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('es'),
        saveLocale: false,
        child: ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(demoApi),
            toyProvider.overrideWith(_FakeToyNotifier.new),
            authProvider.overrideWith(_FakeAuthNotifier.new),
            personalitiesProvider.overrideWith(_FakePersonalitiesNotifier.new),
            personProvider.overrideWith(_FakePersonNotifier.new),
          ],
          child: RepaintBoundary(
            key: boundaryKey,
            // Fondo de respaldo: zonas transparentes salen crema, no negras
            child: ColoredBox(
              color: AppTheme.lightTheme.scaffoldBackgroundColor,
              child: _Shell(key: _shellKey),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> settleImages() async {
      // Decodifica imágenes/SVGs fuera del fake-async para que pinten.
      for (var i = 0; i < 8; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 120)),
        );
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();
    }

    Future<void> shoot(String locale, String name) async {
      await settleImages();
      expect(tester.takeException(), isNull, reason: 'excepción en $name');
      await tester.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 3);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('${outRoot.path}/$locale/$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      debugPrint('captura: $locale/$name.png');
    }

    Future<void> show(Widget screen) async {
      _shellKey.currentState!.show(screen);
      await tester.pump();
      await tester.pumpAndSettle();
    }

    Future<void> captureSet(String locale) async {
      // 01 — Bienvenida (marca)
      await show(const WelcomeScreen());
      await shoot(locale, '01_bienvenida');

      // 02 — Home con juguetes activos (MainScreen es el shell con nav)
      _shellKey.currentState!.goHome();
      await tester.pumpAndSettle();
      await shoot(locale, '02_home');

      // 03 — Selección de voz del setup
      await show(const VoiceSetupScreen());
      await shoot(locale, '03_voces');

      // 04 — Personalidad, conservada en el release simplificado.
      await show(const PersonalitySetupScreen());
      await shoot(locale, '04_personalidad');

      // 05 — Perfiles infantiles con datos ficticios, sin llamadas a la API.
      await show(const PersonsScreen());
      await shoot(locale, '05_perfiles');

      // 06 — Configuración del juguete, con voz de catálogo.
      await show(ToySettingsScreen(key: UniqueKey(), toy: _demoToy));
      await shoot(locale, '06_configuracion');
    }

    await captureSet('es');

    final ctx = _shellKey.currentContext!;
    await ctx.setLocale(const Locale('en'));
    await tester.pumpAndSettle();
    await captureSet('en');

    // Desmonta para cancelar timers.
    await show(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
