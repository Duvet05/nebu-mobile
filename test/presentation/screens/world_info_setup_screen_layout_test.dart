import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/presentation/screens/setup/world_info_setup_screen.dart';
import 'package:nebu_mobile_flutter/presentation/widgets/setup_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _locales = <Locale>[Locale('en'), Locale('es'), Locale('pt')];

const _viewports = [
  (name: 'compact', size: Size(320, 568)),
  (name: 'regular', size: Size(390, 844)),
];

const _landmarks =
    <
      String,
      ({
        String title,
        String device,
        String profile,
        String preferences,
        String action,
      })
    >{
      'en': (
        title: 'All Set!',
        device: 'Device connected',
        profile: 'Profile configured',
        preferences: 'Preferences saved',
        action: 'Start Using Nebu',
      ),
      'es': (
        title: '¡Todo Listo!',
        device: 'Dispositivo conectado',
        profile: 'Perfil configurado',
        preferences: 'Preferencias guardadas',
        action: 'Comenzar a Usar Nebu',
      ),
      'pt': (
        title: 'Tudo Pronto!',
        device: 'Dispositivo conectado',
        profile: 'Perfil configurado',
        preferences: 'Preferências salvas',
        action: 'Começar a Usar o Nebu',
      ),
    };

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  for (final locale in _locales) {
    testWidgets(
      'World info setup remains reachable in ${locale.languageCode}',
      (tester) async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final textScale = ValueNotifier<double>(1);
        addTearDown(textScale.dispose);
        tester.view
          ..devicePixelRatio = 1
          ..physicalSize = _viewports.first.size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          EasyLocalization(
            key: ValueKey('world-info-${locale.languageCode}'),
            supportedLocales: _locales,
            path: 'assets/translations',
            fallbackLocale: const Locale('en'),
            startLocale: locale,
            saveLocale: false,
            child: ProviderScope(
              child: _WorldInfoTestApp(textScale: textScale),
            ),
          ),
        );
        await tester.pumpAndSettle();

        for (final viewport in _viewports) {
          for (final scale in const <double>[1, 2]) {
            final scenario =
                '${locale.languageCode}, ${viewport.name}, ${scale}x text';
            tester.view.physicalSize = viewport.size;
            textScale.value = scale;
            await tester.pumpAndSettle();

            final scrollable = tester.state<ScrollableState>(
              find.byType(Scrollable).first,
            );
            scrollable.position.jumpTo(0);
            await tester.pump();

            final screenContext = tester.element(
              find.byType(WorldInfoSetupScreen),
            );
            expect(
              Localizations.localeOf(screenContext).languageCode,
              locale.languageCode,
              reason: scenario,
            );
            expect(tester.takeException(), isNull, reason: scenario);

            final landmark = _landmarks[locale.languageCode]!;
            expect(find.text(landmark.title), findsOneWidget, reason: scenario);
            for (final feature in [
              landmark.device,
              landmark.profile,
              landmark.preferences,
            ]) {
              final featureText = find.text(feature);
              expect(featureText, findsOneWidget, reason: scenario);
              final rect = tester.getRect(featureText);
              expect(rect.left, greaterThanOrEqualTo(-0.01), reason: scenario);
              expect(
                rect.right,
                lessThanOrEqualTo(viewport.size.width + 0.01),
                reason: scenario,
              );
            }

            final actionLabel = find.text(landmark.action);
            final actionButton = find.ancestor(
              of: actionLabel,
              matching: find.byType(SetupPrimaryButton),
            );
            expect(actionButton, findsOneWidget, reason: scenario);

            if (viewport.name == 'compact') {
              await tester.ensureVisible(actionButton);
              await tester.pump();
            } else if (scale == 1) {
              expect(
                scrollable.position.pixels,
                0,
                reason: '$scenario should not require scrolling',
              );
              expect(
                actionButton.hitTestable(),
                findsOneWidget,
                reason: '$scenario should show the CTA without scrolling',
              );
            } else {
              scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
              await tester.pump();
            }

            expect(
              tester.getRect(actionButton).height,
              greaterThanOrEqualTo(56),
              reason: scenario,
            );
            expect(
              actionButton.hitTestable(),
              findsOneWidget,
              reason: scenario,
            );
            expect(tester.takeException(), isNull, reason: scenario);
          }
        }
      },
    );
  }

  testWidgets('SetupPrimaryButton exposes one label and invokes its callback', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final semantics = tester.ensureSemantics();

    var tapCount = 0;
    const label = 'Começar a usar o Nebu com segurança';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SetupPrimaryButton(text: label, onPressed: () => tapCount++),
          ),
        ),
      ),
    );
    await tester.pump();

    final button = find.byType(SetupPrimaryButton);
    expect(button, findsOneWidget);
    expect(button.hitTestable(), findsOneWidget);
    expect(tester.getRect(button).height, greaterThanOrEqualTo(56));
    expect(tester.takeException(), isNull);

    final semanticsData = tester.getSemantics(button).getSemanticsData();
    final semanticsLabel = semanticsData.label;
    final isButton = semanticsData.flagsCollection.isButton;
    final isEnabled = semanticsData.flagsCollection.isEnabled.toBoolOrNull();
    final hasTapAction = semanticsData.hasAction(SemanticsAction.tap);
    semantics.dispose();

    expect(semanticsLabel, label);
    expect(isButton, isTrue);
    expect(isEnabled, isTrue);
    expect(hasTapAction, isTrue);

    final text = tester.widget<Text>(find.text(label));
    expect(text.textAlign, TextAlign.center);

    await tester.tap(button);
    await tester.pump();
    expect(tapCount, 1);
  });
}

class _WorldInfoTestApp extends StatelessWidget {
  const _WorldInfoTestApp({required this.textScale});

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
      home: const WorldInfoSetupScreen(),
    ),
  );
}
