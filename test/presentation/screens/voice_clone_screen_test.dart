import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/data/models/toy.dart';
import 'package:nebu_mobile_flutter/presentation/screens/voice_clone_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock del method channel del plugin `record` para ejercitar el flujo
/// grabar → detener → confirmar sin micrófono real.
///
/// Nota: todos los escenarios corren sobre UN solo State de la pantalla
/// (encadenados con "Volver a grabar"). Crear un segundo AudioRecorder tras
/// desechar el primero deja bloqueado el semáforo global del plugin en tests,
/// porque dispose() intenta cancelar un EventChannel sin mock.
const _recordChannel = MethodChannel('com.llfbandit.record/messages');
const _pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const toy = Toy(id: 'toy-1', name: 'Nebu Bear', status: ToyStatus.active);
  final recordCalls = <String>[];
  String? lastStartPath;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    recordCalls.clear();
    lastStartPath = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_recordChannel, (call) async {
          recordCalls.add(call.method);
          switch (call.method) {
            case 'hasPermission':
              return true;
            case 'start':
              lastStartPath =
                  (call.arguments as Map<dynamic, dynamic>)['path'] as String?;
              return null;
            case 'stop':
              return lastStartPath;
            default:
              return null;
          }
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          _pathProviderChannel,
          (call) async => Directory.systemTemp.path,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_recordChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, null);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es'), Locale('pt')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('es'),
        saveLocale: false,
        child: ProviderScope(
          child: Builder(
            builder: (context) => MaterialApp(
              theme: AppTheme.lightTheme,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              home: const VoiceCloneScreen(toy: toy),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // easy_localization renderiza vacío mientras carga traducciones y
    // pumpAndSettle no siempre lo espera: bombea hasta que aparezca la pantalla
    for (
      var i = 0;
      i < 20 && find.byType(VoiceCloneScreen).evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // El singleton de easy_localization puede volver al fallback (en) en
    // pumps posteriores dentro del mismo proceso: fuerza español siempre.
    final ctx = tester.element(find.byType(VoiceCloneScreen));
    if (ctx.locale != const Locale('es')) {
      await ctx.setLocale(const Locale('es'));
      await tester.pumpAndSettle();
    }
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump();
  }

  // Un solo testWidgets: easy_localization y el plugin record mantienen estado
  // global de proceso (singleton / semáforo) que rompe un segundo pump en
  // tests separados, así que todos los escenarios corren secuencialmente.
  testWidgets('render inicial y flujo de grabación: completo, re-grabar, '
      'muy corto y auto-stop', (tester) async {
    await pumpScreen(tester);

    // --- Render inicial ---
    expect(find.text('Clonar Voz'), findsOneWidget);
    expect(find.text('Cómo funciona'), findsOneWidget);
    expect(find.text('Texto de ejemplo'), findsOneWidget);
    expect(find.text('Grabar'), findsOneWidget);
    // Sin grabación todavía: no hay nombre, consentimiento ni botón de envío
    expect(find.text('Clonar voz'), findsNothing);
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(tester.takeException(), isNull);

    // --- Escenario 1: grabar 6s, detener, consentimiento habilita envío ---
    await tapVisible(tester, find.text('Grabar'));

    expect(recordCalls, contains('start'));
    expect(find.text('Grabando… habla ahora'), findsOneWidget);
    expect(find.text('Detener'), findsOneWidget);

    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('6 / 15s'), findsOneWidget);

    await tapVisible(tester, find.text('Detener'));
    await tester.pumpAndSettle();

    expect(recordCalls, contains('stop'));
    expect(find.text('Muestra grabada: 6 segundos'), findsOneWidget);
    expect(find.text('Volver a grabar'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsOneWidget);

    final submitFinder = find.widgetWithText(ElevatedButton, 'Clonar voz');
    await tester.ensureVisible(submitFinder);
    expect(submitFinder, findsOneWidget);
    expect(tester.widget<ElevatedButton>(submitFinder).onPressed, isNull);

    await tapVisible(tester, find.byType(CheckboxListTile));
    expect(tester.widget<ElevatedButton>(submitFinder).onPressed, isNotNull);
    expect(tester.takeException(), isNull);

    // --- Escenario 2: re-grabar descarta la muestra y una grabación de
    // menos de 5s se rechaza ---
    recordCalls.clear();
    await tapVisible(tester, find.text('Volver a grabar'));
    await tester.pumpAndSettle();
    expect(find.text('Grabar'), findsOneWidget);
    expect(find.text('Clonar voz'), findsNothing);

    await tapVisible(tester, find.text('Grabar'));
    await tester.pump(const Duration(seconds: 2));

    await tapVisible(tester, find.text('Detener'));
    await tester.pumpAndSettle();

    expect(
      find.text('La grabación es muy corta. Graba al menos 5 segundos.'),
      findsOneWidget,
    );
    expect(find.text('Grabar'), findsOneWidget);
    expect(find.text('Clonar voz'), findsNothing);
    expect(tester.takeException(), isNull);

    // --- Escenario 3: se detiene automáticamente a los 15s ---
    recordCalls.clear();
    await tapVisible(tester, find.text('Grabar'));

    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpAndSettle();

    expect(recordCalls, contains('stop'));
    expect(find.text('Muestra grabada: 15 segundos'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Libera el semáforo global del plugin para tests posteriores
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
