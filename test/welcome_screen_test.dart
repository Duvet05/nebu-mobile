import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/presentation/screens/welcome_screen.dart';
import 'package:nebu_mobile_flutter/presentation/widgets/brand_backdrop.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('adapts the branded welcome artwork to each viewport', (
    tester,
  ) async {
    await _pumpWelcome(tester, const Size(390, 844));

    expect(find.byType(NebuBrandBackdrop), findsOneWidget);

    final dino = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(
      dino.colorFilter,
      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );
    expect(
      _assetImages(tester),
      containsAll({
        'assets/images/decoration-blob-teal.png',
        'assets/images/decoration-blob-yellow.png',
        'assets/images/decoration-strokes-scattered.png',
      }),
    );
    expect(tester.takeException(), isNull);

    await _resize(tester, const Size(390, 460));

    expect(find.byType(SvgPicture), findsNothing);
    expect(
      _assetImages(tester),
      isNot(contains('assets/images/decoration-blob-teal.png')),
    );
    expect(tester.takeException(), isNull);

    await _resize(tester, const Size(1440, 900));

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(
      _assetImages(tester),
      containsAll({
        'assets/images/decoration-blob-teal.png',
        'assets/images/decoration-blob-yellow.png',
        'assets/images/decoration-strokes-scattered.png',
      }),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('compiled release exposes the expected entry actions', (
    tester,
  ) async {
    await _pumpWelcome(
      tester,
      const Size(390, 844),
      startLocale: const Locale('en'),
    );

    const minimumRelease = bool.fromEnvironment('MINIMAL_IOS_RELEASE');
    if (minimumRelease) {
      expect(find.text('Sign In'), findsNothing);
      expect(find.text('Sign Up'), findsNothing);
      expect(find.text('Continue without an account'), findsNothing);
      expect(find.text('Continue'), findsOneWidget);
    } else {
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Continue without an account'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    }
  });
}

Future<void> _pumpWelcome(
  WidgetTester tester,
  Size size, {
  Locale startLocale = const Locale('es'),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    EasyLocalization(
      key: ValueKey<String>(startLocale.languageCode),
      supportedLocales: const [Locale('en'), Locale('es'), Locale('pt')],
      path: 'assets/translations',
      fallbackLocale: const Locale('es'),
      startLocale: startLocale,
      child: _TestApp(treeKey: startLocale.languageCode),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _resize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  await tester.pump();
}

Set<String> _assetImages(WidgetTester tester) => tester
    .widgetList<Image>(find.byType(Image))
    .map((image) => image.image)
    .whereType<AssetImage>()
    .map((image) => image.assetName)
    .toSet();

class _TestApp extends StatelessWidget {
  const _TestApp({required this.treeKey});

  final String treeKey;

  @override
  Widget build(BuildContext context) => MaterialApp(
    key: ValueKey<String>(treeKey),
    theme: AppTheme.lightTheme,
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: context.localizationDelegates,
    home: const WelcomeScreen(),
  );
}
