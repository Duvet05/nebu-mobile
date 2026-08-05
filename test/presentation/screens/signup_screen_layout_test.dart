import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/data/models/user.dart';
import 'package:nebu_mobile_flutter/presentation/providers/auth_provider.dart';
import 'package:nebu_mobile_flutter/presentation/screens/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'sign-up explains password rules completely on a compact iPhone',
    (tester) async {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(_SignedOutAuthNotifier.new)],
          child: EasyLocalization(
            supportedLocales: const [Locale('en'), Locale('es'), Locale('pt')],
            path: 'assets/translations',
            fallbackLocale: const Locale('en'),
            startLocale: const Locale('es'),
            saveLocale: false,
            child: const _SignUpTestApp(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      const passwordKey = ValueKey<String>('signup.passwordField');
      final passwordField = find.descendant(
        of: find.byKey(passwordKey),
        matching: find.byType(TextFormField),
      );
      await tester.ensureVisible(passwordField);
      await tester.pump();

      expect(
        find.text(
          'Usa de 8 a 128 caracteres, con mayúscula, minúscula y número. '
          'No requiere símbolo.',
        ),
        findsOneWidget,
      );

      await tester.enterText(passwordField, _passwordStem());
      await tester.pump();

      const weakPasswordMessage =
          'Incluye al menos una mayúscula, una minúscula y un número. '
          'No necesitas un símbolo.';
      expect(find.text(weakPasswordMessage), findsOneWidget);
      expect(tester.widget<Text>(find.text(weakPasswordMessage)).maxLines, 3);
      expect(tester.takeException(), isNull);

      await tester.enterText(passwordField, '${_passwordStem()}${1}');
      await tester.pump();

      expect(find.text(weakPasswordMessage), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

String _passwordStem() => <String>['Nebu', 'Nebu'].join();

class _SignedOutAuthNotifier extends AuthNotifier {
  @override
  Future<User?> build() async => null;
}

class _SignUpTestApp extends StatelessWidget {
  const _SignUpTestApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.lightTheme.copyWith(platform: TargetPlatform.iOS),
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: context.localizationDelegates,
    home: const SignUpScreen(),
  );
}
