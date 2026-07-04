import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nebu_mobile_flutter/data/models/toy.dart';
import 'package:nebu_mobile_flutter/presentation/providers/esp32_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/toy_provider.dart';
import 'package:nebu_mobile_flutter/presentation/screens/toy_settings_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Toy settings updates voicePreference through the UI', (
    tester,
  ) async {
    await EasyLocalization.ensureInitialized();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const <Locale>[
          Locale('en'),
          Locale('es'),
          Locale('pt'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: ProviderScope(
          overrides: [
            toyProvider.overrideWith(_FakeToyNotifier.new),
            esp32VolumeProvider.overrideWithValue(50),
            esp32MuteProvider.overrideWithValue(false),
            esp32SetVolumeProvider.overrideWithValue((_) async => true),
            esp32SetMuteProvider.overrideWithValue(
              ({required mute}) async => true,
            ),
          ],
          child: const _ToySettingsTestApp(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final appContext = tester.element(find.byType(_ToySettingsTestApp));
    final fakeToyNotifier =
        ProviderScope.containerOf(appContext).read(toyProvider.notifier)
            as _FakeToyNotifier;

    expect(find.text('Nebu Lyra'), findsOneWidget);

    await tester.ensureVisible(find.text('Nebu Lyra'));
    await tester.tap(find.text('Nebu Lyra'));
    await tester.pumpAndSettle();

    expect(find.text('Change Voice'), findsOneWidget);

    await tester.tap(find.text('Nebu Orion'));
    await tester.pumpAndSettle();

    expect(fakeToyNotifier.lastSettings, isNotNull);
    expect(
      fakeToyNotifier.lastSettings,
      containsPair(
        'voicePreference',
        'default-oklrorszoxbwzfdj8zjhng__nebu_pirat',
      ),
    );
    expect(
      fakeToyNotifier.lastSettings,
      containsPair('enableVarietyEngine', true),
    );
    expect(find.text('Nebu Orion'), findsOneWidget);
    expect(find.text('Voice updated'), findsOneWidget);
  });
}

class _ToySettingsTestApp extends StatelessWidget {
  const _ToySettingsTestApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: context.localizationDelegates,
    home: const ToySettingsScreen(toy: _initialToy),
  );
}

const _initialToy = Toy(
  id: 'toy-e2e',
  name: 'Nebu',
  status: ToyStatus.active,
  model: 'Nebu',
  iotDeviceId: 'ESP32_E2E',
  settings: <String, dynamic>{
    'voicePreference': 'default-oklrorszoxbwzfdj8zjhng__nebu',
    'enableVarietyEngine': true,
  },
);

class _FakeToyNotifier extends ToyNotifier {
  Toy currentToy = _initialToy;
  Map<String, dynamic>? lastSettings;

  @override
  Future<List<Toy>> build() async => [currentToy];

  @override
  Future<Toy> getToyById(String id) async => currentToy;

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
    lastSettings = settings == null
        ? null
        : Map<String, dynamic>.from(settings);
    currentToy = currentToy.copyWith(
      name: name ?? currentToy.name,
      ownerId: ownerId ?? currentToy.ownerId,
      model: model ?? currentToy.model,
      manufacturer: manufacturer ?? currentToy.manufacturer,
      status: status ?? currentToy.status,
      firmwareVersion: firmwareVersion ?? currentToy.firmwareVersion,
      capabilities: capabilities ?? currentToy.capabilities,
      settings: settings ?? currentToy.settings,
      notes: notes ?? currentToy.notes,
      prompt: prompt ?? currentToy.prompt,
      personalityProfile: personalityProfile ?? currentToy.personalityProfile,
      greeting: greeting ?? currentToy.greeting,
    );
    state = AsyncValue.data([currentToy]);
    return currentToy;
  }
}
