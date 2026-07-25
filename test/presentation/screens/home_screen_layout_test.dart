import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/data/models/user.dart';
import 'package:nebu_mobile_flutter/presentation/providers/auth_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/bluetooth_provider.dart';
import 'package:nebu_mobile_flutter/presentation/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _locales = <Locale>[Locale('en'), Locale('es'), Locale('pt')];

const _viewports = [
  (name: 'compact', size: Size(320, 568)),
  (name: 'regular', size: Size(390, 844)),
  (name: 'large-phone', size: Size(430, 932)),
  (name: 'tablet', size: Size(1024, 768)),
];

const _landmarks = <String, ({String title, String action})>{
  'en': (title: 'My Active Toys', action: 'Add Toy'),
  'es': (title: 'Juguetes Activos', action: 'Agregar Juguete'),
  'pt': (title: 'Meus Brinquedos Ativos', action: 'Adicionar Brinquedo'),
};

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  for (final locale in _locales) {
    testWidgets(
      'Home layout adapts across viewports in ${locale.languageCode}',
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
          ProviderScope(
            overrides: [
              authProvider.overrideWith(_LayoutAuthNotifier.new),
              connectedDevicesProvider.overrideWith(
                (ref) async => <fbp.BluetoothDevice>[],
              ),
            ],
            child: EasyLocalization(
              key: ValueKey('home-${locale.languageCode}'),
              supportedLocales: _locales,
              path: 'assets/translations',
              fallbackLocale: const Locale('en'),
              startLocale: locale,
              saveLocale: false,
              child: _HomeTestApp(textScale: textScale),
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

            final homeContext = tester.element(find.byType(HomeScreen));
            expect(
              Localizations.localeOf(homeContext).languageCode,
              locale.languageCode,
              reason: scenario,
            );
            expect(tester.takeException(), isNull, reason: scenario);

            final landmark = _landmarks[locale.languageCode]!;
            final title = find.text(landmark.title);
            final actionLabel = find.text(landmark.action);
            expect(title, findsOneWidget, reason: scenario);
            expect(actionLabel, findsOneWidget, reason: scenario);
            expect(
              find.text('home.my_active_toys'),
              findsNothing,
              reason: scenario,
            );

            final actionButton = find.ancestor(
              of: actionLabel,
              matching: find.byType(TextButton),
            );
            expect(actionButton, findsOneWidget, reason: scenario);

            final titleRect = tester.getRect(title);
            final actionRect = tester.getRect(actionButton);
            expect(titleRect.overlaps(actionRect), isFalse, reason: scenario);
            expect(
              titleRect.left,
              greaterThanOrEqualTo(-0.01),
              reason: scenario,
            );
            expect(
              titleRect.right,
              lessThanOrEqualTo(viewport.size.width + 0.01),
              reason: scenario,
            );
            expect(
              actionRect.left,
              greaterThanOrEqualTo(-0.01),
              reason: scenario,
            );
            expect(
              actionRect.right,
              lessThanOrEqualTo(viewport.size.width + 0.01),
              reason: scenario,
            );
            expect(
              actionRect.height,
              greaterThanOrEqualTo(kMinInteractiveDimension),
              reason: scenario,
            );

            if (viewport.name == 'tablet' && scale == 1) {
              expect(
                (titleRect.center.dy - actionRect.center.dy).abs(),
                lessThanOrEqualTo(1),
                reason: '$scenario should preserve the single-row header',
              );
              expect(
                actionRect.right,
                closeTo(viewport.size.width - 16, 1),
                reason: '$scenario should preserve space-between alignment',
              );
            }

            if (locale.languageCode == 'pt' &&
                viewport.name == 'compact' &&
                scale == 2) {
              expect(
                actionRect.top,
                greaterThanOrEqualTo(titleRect.bottom),
                reason: '$scenario should wrap the action below the title',
              );
            }

            await tester.ensureVisible(actionButton);
            await tester.pump();
            expect(
              actionButton.hitTestable(),
              findsOneWidget,
              reason: scenario,
            );

            await tester.ensureVisible(find.text(_quickAction(locale)));
            await tester.pump();
            final lastQuickAction = find.ancestor(
              of: find.text(_quickAction(locale)),
              matching: find.byType(InkWell),
            );
            expect(lastQuickAction, findsOneWidget, reason: scenario);
            expect(
              lastQuickAction.hitTestable(),
              findsOneWidget,
              reason: scenario,
            );
            expect(tester.takeException(), isNull, reason: scenario);
          }
        }
      },
    );
  }
}

String _quickAction(Locale locale) => switch (locale.languageCode) {
  'es' => 'Personalidades',
  'pt' => 'Personalidades',
  _ => 'Personalities',
};

class _LayoutAuthNotifier extends AuthNotifier {
  @override
  Future<User?> build() async => const User(
    id: 'layout-user',
    email: 'layout@example.com',
    fullName: 'Alexandra Montgomery',
    emailVerified: true,
  );
}

class _HomeTestApp extends StatelessWidget {
  const _HomeTestApp({required this.textScale});

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
      home: const HomeScreen(),
    ),
  );
}
