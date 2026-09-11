import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/data/models/toy.dart';
import 'package:nebu_mobile_flutter/presentation/providers/api_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/walkie_talkie_provider.dart';
import 'package:nebu_mobile_flutter/presentation/screens/walkie_talkie_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/localization_test_helper.dart';

const _compactViewport = Size(320, 568);
const _portuguese = Locale('pt');
const _supportedLocales = <Locale>[Locale('en'), Locale('es'), _portuguese];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  for (final scenario in [
    (
      name: 'iOS',
      platform: TargetPlatform.iOS,
      viewport: _compactViewport,
      systemPadding: EdgeInsets.zero,
    ),
    (
      name: 'Android gesture navigation',
      platform: TargetPlatform.android,
      viewport: _compactViewport,
      systemPadding: const EdgeInsets.only(top: 24, bottom: 24),
    ),
    (
      name: 'Android three-button navigation',
      platform: TargetPlatform.android,
      viewport: _compactViewport,
      systemPadding: const EdgeInsets.only(top: 24, bottom: 48),
    ),
    (
      name: 'Android landscape with a cutout and side navigation',
      platform: TargetPlatform.android,
      viewport: const Size(568, 320),
      systemPadding: const EdgeInsets.only(left: 32, top: 24, right: 48),
    ),
  ]) {
    final systemPadding = scenario.systemPadding;
    testWidgets(
      'Walkie-talkie controls remain reachable with large text on ${scenario.name}',
      (tester) async {
        tester.view
          ..devicePixelRatio = 1
          ..physicalSize = scenario.viewport;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        const permissionChannel = MethodChannel(
          'flutter.baseflow.com/permissions/methods',
        );
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(permissionChannel, (call) async {
              if (call.method == 'requestPermissions') {
                return <int, int>{7: 1};
              }
              return null;
            });
        addTearDown(
          () => TestDefaultBinaryMessengerBinding
              .instance
              .defaultBinaryMessenger
              .setMockMethodCallHandler(permissionChannel, null),
        );

        await tester.pumpWidget(
          EasyLocalization(
            supportedLocales: _supportedLocales,
            path: 'assets/translations',
            assetLoader: const TestJsonAssetLoader(),
            fallbackLocale: const Locale('en'),
            startLocale: _portuguese,
            saveLocale: false,
            child: ProviderScope(
              overrides: [
                walkieTalkieProvider.overrideWith(
                  _LayoutWalkieTalkieNotifier.new,
                ),
                loggerProvider.overrideWithValue(Logger()),
              ],
              child: _LargeTextTestApp(
                platform: scenario.platform,
                systemPadding: systemPadding,
                home: const WalkieTalkieScreen(
                  toy: Toy(
                    id: 'toy-1',
                    name: 'Nebu',
                    status: ToyStatus.connected,
                    iotDeviceId: 'iot-1',
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.descendant(
            of: find.byType(WalkieTalkieScreen),
            matching: find.byType(Scrollable),
          ),
          findsOneWidget,
        );

        final endLabel = find.text('Encerrar Sessão');
        expect(endLabel, findsOneWidget);
        await tester.ensureVisible(endLabel);
        await tester.pumpAndSettle();

        final endButton = find.ancestor(
          of: endLabel,
          matching: find.byType(OutlinedButton),
        );
        expect(endButton, findsOneWidget);
        expect(endButton.hitTestable(), findsOneWidget);
        final endButtonRect = tester.getRect(endButton);
        expect(endButtonRect.left, greaterThanOrEqualTo(systemPadding.left));
        expect(
          endButtonRect.right,
          lessThanOrEqualTo(scenario.viewport.width - systemPadding.right),
        );
        expect(endButtonRect.top, greaterThanOrEqualTo(systemPadding.top));
        expect(
          endButtonRect.bottom,
          lessThanOrEqualTo(scenario.viewport.height - systemPadding.bottom),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}

class _LargeTextTestApp extends StatelessWidget {
  const _LargeTextTestApp({
    required this.home,
    required this.platform,
    required this.systemPadding,
  });

  final Widget home;
  final TargetPlatform platform;
  final EdgeInsets systemPadding;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.lightTheme.copyWith(platform: platform),
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: context.localizationDelegates,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(2),
        padding: systemPadding,
        viewPadding: systemPadding,
        disableAnimations: true,
      ),
      child: child!,
    ),
    home: home,
  );
}

class _LayoutWalkieTalkieNotifier extends WalkieTalkieNotifier {
  @override
  WalkieTalkieState build() => const WalkieTalkieState(
    phase: WalkieTalkiePhase.connected,
    isRemoteConnected: true,
    remoteParticipantName: 'Nebu',
    roomName: 'room-1',
  );

  @override
  Future<void> startSession(Toy toy) async {}

  @override
  Future<void> endSession() async {}
}
