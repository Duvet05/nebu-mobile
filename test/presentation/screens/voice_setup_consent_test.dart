import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/mockito.dart';
import 'package:nebu_mobile_flutter/core/constants/storage_keys.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/data/models/parental_consent.dart';
import 'package:nebu_mobile_flutter/data/models/user.dart';
import 'package:nebu_mobile_flutter/data/services/user_setup_service.dart';
import 'package:nebu_mobile_flutter/presentation/providers/api_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/auth_provider.dart';
import 'package:nebu_mobile_flutter/presentation/screens/setup/voice_setup_screen.dart';
import 'package:nebu_mobile_flutter/presentation/widgets/nebu_voice_options.dart';
import 'package:nebu_mobile_flutter/presentation/widgets/setup_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/mocks.dart';

const _adult = User(id: 'user-1', email: 'adult@example.test');

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('applies consent rules without disrupting current users', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      StorageKeys.setupVoicePreference: nebuVoiceOptions.first.id,
    });
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(600, 1400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final currentApi = MockApiService();
    when(
      currentApi.get<Map<String, dynamic>>('/users/user-1/setup'),
    ).thenAnswer(
      (_) async => <String, dynamic>{
        'parentalConsent': <String, dynamic>{
          'parentOrGuardianDeclaration': true,
          'childDataProcessing': true,
          'sensitiveDataProcessing': true,
          'privacyVersion': ParentalConsent.currentPrivacyVersion,
          'authenticatedUserId': _adult.id,
        },
      },
    );
    final scenario = ValueNotifier<_VoiceScenario>(
      _VoiceScenario(name: 'current', apiService: currentApi, user: _adult),
    );
    addTearDown(scenario.dispose);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es'), Locale('pt')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('es'),
        saveLocale: false,
        child: _VoiceScenarioHost(scenario: scenario),
      ),
    );
    await _settleAndRevealConsent(tester);

    expect(find.byKey(const ValueKey('voiceConsent.current')), findsOneWidget);
    expect(find.byKey(const ValueKey('voiceConsent.required')), findsNothing);
    expect(_primaryButton(tester).isEnabled, isTrue);
    verify(
      currentApi.get<Map<String, dynamic>>('/users/user-1/setup'),
    ).called(1);

    final newAccountApi = MockApiService();
    when(
      newAccountApi.get<Map<String, dynamic>>('/users/user-1/setup'),
    ).thenAnswer((_) async => <String, dynamic>{'parentalConsent': null});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      StorageKeys.setupParentalConsentUserId,
      'another-user',
    );
    scenario.value = _VoiceScenario(
      name: 'new-account',
      apiService: newAccountApi,
      user: _adult,
    );

    await _settleAndRevealConsent(tester);

    expect(find.byKey(const ValueKey('voiceConsent.required')), findsOneWidget);
    expect(_primaryButton(tester).isEnabled, isFalse);
    expect(
      tester
          .widget<CheckboxListTile>(
            find.byKey(const ValueKey('voiceConsent.guardian')),
          )
          .value,
      isFalse,
    );

    for (final key in const <String>[
      'voiceConsent.guardian',
      'voiceConsent.childData',
      'voiceConsent.sensitiveData',
    ]) {
      final checkbox = find.byKey(ValueKey<String>(key));
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pump();
    }

    expect(_primaryButton(tester).isEnabled, isTrue);
    expect(tester.takeException(), isNull);

    final failingApi = MockApiService();
    when(
      failingApi.get<Map<String, dynamic>>('/users/user-1/setup'),
    ).thenThrow(Exception('network unavailable'));
    scenario.value = _VoiceScenario(
      name: 'lookup-failure',
      apiService: failingApi,
      user: _adult,
    );

    await _settleAndRevealConsent(tester);

    expect(find.byKey(const ValueKey('voiceConsent.required')), findsOneWidget);
    expect(
      find.text(
        'No pudimos verificar un consentimiento previo. '
        'Confirma estas declaraciones para continuar de forma segura.',
      ),
      findsOneWidget,
    );
    expect(_primaryButton(tester).isEnabled, isFalse);

    final guestApi = MockApiService();
    scenario.value = _VoiceScenario(
      name: 'guest',
      apiService: guestApi,
      user: null,
    );

    await _settleAndRevealConsent(tester);

    expect(
      find.byKey(const ValueKey('voiceConsent.guestNotice')),
      findsOneWidget,
    );
    expect(_primaryButton(tester).isEnabled, isTrue);
    verifyNever(guestApi.get<Map<String, dynamic>>(any));
  });
}

SetupPrimaryButton _primaryButton(WidgetTester tester) =>
    tester.widget<SetupPrimaryButton>(find.byType(SetupPrimaryButton));

Future<void> _settleAndRevealConsent(WidgetTester tester) async {
  await tester.pumpAndSettle();

  final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
  scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
  await tester.pump();
}

class _VoiceScenario {
  const _VoiceScenario({
    required this.name,
    required this.apiService,
    required this.user,
  });

  final String name;
  final MockApiService apiService;
  final User? user;
}

class _VoiceScenarioHost extends StatelessWidget {
  const _VoiceScenarioHost({required this.scenario});

  final ValueNotifier<_VoiceScenario> scenario;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<_VoiceScenario>(
    valueListenable: scenario,
    builder: (context, value, child) {
      final service = UserSetupService(
        apiService: value.apiService,
        logger: MockLogger(),
      );
      return ProviderScope(
        key: ValueKey<String>(value.name),
        overrides: [
          authProvider.overrideWith(() => _TestAuthNotifier(value.user)),
          userSetupServiceProvider.overrideWithValue(service),
        ],
        child: const _VoiceTestApp(),
      );
    },
  );
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this.user);

  final User? user;

  @override
  Future<User?> build() async => user;
}

class _VoiceTestApp extends StatelessWidget {
  const _VoiceTestApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.lightTheme.copyWith(platform: TargetPlatform.iOS),
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: context.localizationDelegates,
    home: const VoiceSetupScreen(),
  );
}
