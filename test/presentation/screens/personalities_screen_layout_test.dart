import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/data/models/personality.dart';
import 'package:nebu_mobile_flutter/presentation/providers/personality_provider.dart';
import 'package:nebu_mobile_flutter/presentation/screens/personalities_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _voice = 'Voz brasileira extraordinariamente longa para acessibilidade';
const _language = 'Português brasileiro internacional com descrição extensa';
const _style = 'Conversacional, educativo, imaginativo e muito detalhado';

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('personality cards and metadata adapt on compact screens', (
    tester,
  ) async {
    final textScale = ValueNotifier<double>(1);
    addTearDown(textScale.dispose);
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          personalitiesProvider.overrideWith(_FakePersonalitiesNotifier.new),
        ],
        child: EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('es'), Locale('pt')],
          path: 'assets/translations',
          fallbackLocale: const Locale('pt'),
          startLocale: const Locale('pt'),
          saveLocale: false,
          child: _PersonalitiesTestApp(textScale: textScale),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final scale in const <double>[1, 2]) {
      textScale.value = scale;
      await tester.pumpAndSettle();

      final scenario = '320x568, PT, ${scale}x text';
      final cardTitle = find.text('Lumi');
      expect(cardTitle, findsOneWidget, reason: scenario);
      expect(tester.takeException(), isNull, reason: scenario);

      final card = find.ancestor(of: cardTitle, matching: find.byType(InkWell));
      expect(card, findsOneWidget, reason: scenario);
      final cardRect = tester.getRect(card);
      expect(cardRect.left, greaterThanOrEqualTo(0), reason: scenario);
      expect(cardRect.right, lessThanOrEqualTo(320), reason: scenario);

      await tester.tap(cardTitle);
      await tester.pumpAndSettle();

      for (final value in [_voice, _language, _style]) {
        final metadata = find.text(value);
        expect(metadata, findsOneWidget, reason: scenario);
        final rect = tester.getRect(metadata);
        expect(rect.left, greaterThanOrEqualTo(0), reason: scenario);
        expect(rect.right, lessThanOrEqualTo(320), reason: scenario);
      }

      final lastSetting = find.text(_style);
      await tester.ensureVisible(lastSetting);
      await tester.pump();
      final lastSettingRect = tester.getRect(lastSetting);
      expect(lastSettingRect.top, greaterThanOrEqualTo(0), reason: scenario);
      expect(lastSettingRect.bottom, lessThanOrEqualTo(568), reason: scenario);

      final selectAction = find.text('Selecionar');
      await tester.ensureVisible(selectAction);
      await tester.pump();
      expect(selectAction.hitTestable(), findsOneWidget, reason: scenario);
      expect(tester.takeException(), isNull, reason: scenario);

      Navigator.of(tester.element(find.byType(PersonalitiesScreen))).pop();
      await tester.pumpAndSettle();
    }

    tester.view.physicalSize = const Size(390, 844);
    textScale.value = 1;
    await tester.pumpAndSettle();

    final grid = find.descendant(
      of: find.byType(PersonalitiesScreen),
      matching: find.byType(GridView),
    );
    expect(grid, findsOneWidget);
    final delegate =
        tester.widget<GridView>(grid).gridDelegate
            as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 2);
    expect(tester.takeException(), isNull);
  });
}

class _FakePersonalitiesNotifier extends PersonalitiesNotifier {
  @override
  Future<List<Personality>> build() async => const [
    Personality(
      id: 'personality-layout',
      name: 'Lumi',
      description: 'Uma personalidade de teste.',
      category: 'general',
      settings: PersonalitySettings(
        voice: _voice,
        speed: 1,
        language: _language,
        style: _style,
      ),
    ),
  ];
}

class _PersonalitiesTestApp extends StatelessWidget {
  const _PersonalitiesTestApp({required this.textScale});

  final ValueNotifier<double> textScale;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<double>(
    valueListenable: textScale,
    builder: (context, scale, child) => MaterialApp(
      theme: AppTheme.lightTheme.copyWith(platform: TargetPlatform.iOS),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: const PersonalitiesScreen(),
    ),
  );
}
