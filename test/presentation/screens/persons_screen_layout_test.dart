import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/data/models/person.dart';
import 'package:nebu_mobile_flutter/data/services/local_child_data_service.dart';
import 'package:nebu_mobile_flutter/presentation/providers/api_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/person_provider.dart';
import 'package:nebu_mobile_flutter/presentation/screens/persons_screen.dart';
import 'package:nebu_mobile_flutter/presentation/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _compactViewport = Size(320, 568);
const _portuguese = Locale('pt');
const _supportedLocales = <Locale>[Locale('en'), Locale('es'), _portuguese];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({
      'local_child_name': 'Ana',
      'local_child_age': '6-8',
      'local_child_personality': 'friendly',
    });
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'Persons sync banner wraps its actions on compact large-text layouts',
    (tester) async {
      final preferences = await SharedPreferences.getInstance();
      final localChildService = LocalChildDataService(preferences);
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = _compactViewport;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: _supportedLocales,
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          startLocale: _portuguese,
          saveLocale: false,
          child: ProviderScope(
            overrides: [
              personProvider.overrideWith(_LayoutPersonNotifier.new),
              localChildDataServiceProvider.overrideWith(
                (ref) async => localChildService,
              ),
              loggerProvider.overrideWithValue(Logger()),
            ],
            child: const _LargeTextTestApp(home: PersonsScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Perfil local encontrado: Ana'), findsOneWidget);

      final dismissButton = _customButtonWithText('Dispensar');
      final syncButton = _customButtonWithText('Sincronizar Agora');
      expect(dismissButton, findsOneWidget);
      expect(syncButton, findsOneWidget);

      final dismissRect = tester.getRect(dismissButton);
      final syncRect = tester.getRect(syncButton);
      for (final rect in [dismissRect, syncRect]) {
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(_compactViewport.width));
      }
      expect(dismissRect.overlaps(syncRect), isFalse);
      expect(dismissRect.bottom, lessThanOrEqualTo(syncRect.top));

      await tester.ensureVisible(syncButton);
      await tester.pumpAndSettle();
      expect(syncButton.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

Finder _customButtonWithText(String text) =>
    find.ancestor(of: find.text(text), matching: find.byType(CustomButton));

class _LargeTextTestApp extends StatelessWidget {
  const _LargeTextTestApp({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.lightTheme.copyWith(platform: TargetPlatform.iOS),
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: context.localizationDelegates,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(2),
        disableAnimations: true,
      ),
      child: child!,
    ),
    home: home,
  );
}

class _LayoutPersonNotifier extends PersonNotifier {
  static const people = [
    Person(id: 'person-1', givenName: 'Ana', familyName: 'Silva'),
  ];

  @override
  Future<List<Person>> build() async => people;

  @override
  Future<void> loadMyPersons() async {}
}
