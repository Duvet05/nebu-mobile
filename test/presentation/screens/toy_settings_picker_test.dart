import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/data/models/personality.dart';
import 'package:nebu_mobile_flutter/data/models/toy.dart';
import 'package:nebu_mobile_flutter/presentation/providers/personality_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/toy_provider.dart';
import 'package:nebu_mobile_flutter/presentation/screens/toy_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/localization_test_helper.dart';

const _existingClone = <String, dynamic>{
  'id': 'existing-cloned-voice',
  'name': 'Voz existente de demostración',
};

const _toy = Toy(
  id: 'toy-picker-test',
  name: 'Nebu Demo',
  model: 'Nebu',
  status: ToyStatus.active,
  personalityProfile: 'personality-0',
  settings: <String, dynamic>{
    'voicePreference': 'preset-before-test',
    'clonedVoice': _existingClone,
    'enableVarietyEngine': true,
  },
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'MVP pickers preserve existing choices, scroll above navigation and hide new cloning',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      for (final scenario in const [
        (size: Size(384, 832), scale: 1.1),
        (size: Size(320, 568), scale: 2.0),
      ]) {
        tester.view.physicalSize = scenario.size;
        final fakeToys = _FakeToyNotifier();
        final container = ProviderContainer(
          overrides: [
            toyProvider.overrideWith(() => fakeToys),
            personalitiesProvider.overrideWith(_FakePersonalitiesNotifier.new),
          ],
        );
        await container.read(toyProvider.future);
        await container.read(personalitiesProvider.future);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: EasyLocalization(
              supportedLocales: const [
                Locale('en'),
                Locale('es'),
                Locale('pt'),
              ],
              path: 'assets/translations',
              assetLoader: const TestJsonAssetLoader(),
              fallbackLocale: const Locale('es'),
              startLocale: const Locale('es'),
              saveLocale: false,
              child: _PickerTestApp(textScale: scenario.scale),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final screenContext = tester.element(find.byType(ToySettingsScreen));
        if (screenContext.locale != const Locale('es')) {
          await screenContext.setLocale(const Locale('es'));
          await tester.pumpAndSettle();
        }

        final reason = '${scenario.size}, ${scenario.scale}x text';
        expect(tester.takeException(), isNull, reason: reason);
        expect(find.textContaining('{name}'), findsNothing, reason: reason);
        expect(
          find.text('Nebu Demo Personalidad 1'),
          findsOneWidget,
          reason: reason,
        );

        await tester.ensureVisible(find.text('Voz actual'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Voz actual'));
        await tester.pumpAndSettle();

        expect(find.text('Cambiar Voz'), findsOneWidget, reason: reason);
        expect(find.text('Clonar una voz nueva'), findsNothing, reason: reason);
        expect(find.textContaining('Graba una muestra'), findsNothing);
        expect(tester.takeException(), isNull, reason: reason);

        final voiceScroll = find.descendant(
          of: find.byKey(const ValueKey('toySettings.voicePickerScroll')),
          matching: find.byType(Scrollable),
        );
        final existingVoice = find.text(_existingClone['name']! as String);
        await tester.scrollUntilVisible(
          existingVoice,
          100,
          scrollable: voiceScroll,
        );
        await tester.pumpAndSettle();
        expect(existingVoice.hitTestable(), findsOneWidget, reason: reason);
        final voiceRect = tester.getRect(existingVoice);
        expect(
          voiceRect.bottom,
          lessThanOrEqualTo(scenario.size.height - 48),
          reason: 'Existing voice must be above system navigation: $reason',
        );
        expect(tester.takeException(), isNull, reason: reason);

        await tester.tap(existingVoice);
        await tester.pumpAndSettle();
        expect(
          fakeToys.current.settings?['voicePreference'],
          _existingClone['id'],
        );
        expect(fakeToys.current.settings?['clonedVoice'], _existingClone);
        expect(fakeToys.current.settings?['enableVarietyEngine'], isTrue);
        expect(fakeToys.removeCalls, 0);

        await tester.ensureVisible(find.text('Personalidad actual'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Personalidad actual'));
        await tester.pumpAndSettle();

        expect(
          find.text('Cambiar Personalidad'),
          findsOneWidget,
          reason: reason,
        );
        expect(find.textContaining('{name}'), findsNothing, reason: reason);
        final personalityScroll = find.descendant(
          of: find.byKey(const ValueKey('toySettings.personalityPickerScroll')),
          matching: find.byType(Scrollable),
        );
        final lastPersonality = find.text('Nebu Demo Personalidad 18');
        await tester.scrollUntilVisible(
          lastPersonality,
          180,
          scrollable: personalityScroll,
        );
        await tester.pumpAndSettle();
        expect(lastPersonality.hitTestable(), findsOneWidget, reason: reason);
        expect(
          tester.getRect(lastPersonality).bottom,
          lessThanOrEqualTo(scenario.size.height - 48),
          reason: 'Last personality must be above system navigation: $reason',
        );
        expect(tester.takeException(), isNull, reason: reason);

        await tester.tap(lastPersonality);
        await tester.pumpAndSettle();
        expect(fakeToys.current.personalityProfile, 'personality-17');
        expect(fakeToys.current.settings?['clonedVoice'], _existingClone);
        expect(fakeToys.removeCalls, 0);
        expect(tester.takeException(), isNull, reason: reason);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        container.dispose();
      }
    },
  );
}

class _FakeToyNotifier extends ToyNotifier {
  Toy current = _toy;
  int removeCalls = 0;

  @override
  Future<List<Toy>> build() async => [current];

  @override
  Future<Toy> getToyById(String id) async => current;

  @override
  Future<Toy> updateToy({
    required String id,
    String? name,
    String? ownerId,
    String? model,
    String? manufacturer,
    ToyStatus? status,
    String? firmwareVersion,
    Map<String, dynamic>? capabilities,
    Map<String, dynamic>? settings,
    String? notes,
    String? prompt,
    String? personalityProfile,
    String? greeting,
  }) async {
    current = current.copyWith(
      name: name ?? current.name,
      settings: settings ?? current.settings,
      personalityProfile: personalityProfile ?? current.personalityProfile,
    );
    state = AsyncData([current]);
    return current;
  }

  @override
  Future<Toy> removeClonedVoice(String toyId) async {
    removeCalls++;
    return current;
  }
}

class _FakePersonalitiesNotifier extends PersonalitiesNotifier {
  @override
  Future<List<Personality>> build() async => List.generate(
    18,
    (index) => Personality(
      id: 'personality-$index',
      name: '{name} Personalidad ${index + 1}',
      description: 'Historias y juegos educativos para {name}.',
    ),
  );
}

class _PickerTestApp extends StatelessWidget {
  const _PickerTestApp({required this.textScale});

  final double textScale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.lightTheme.copyWith(platform: TargetPlatform.android),
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: context.localizationDelegates,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        padding: const EdgeInsets.only(top: 24, bottom: 48),
        viewPadding: const EdgeInsets.only(top: 24, bottom: 48),
        disableAnimations: true,
      ),
      child: child!,
    ),
    home: const ToySettingsScreen(toy: _toy),
  );
}
