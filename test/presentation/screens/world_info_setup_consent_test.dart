import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/mockito.dart';
import 'package:nebu_mobile_flutter/core/constants/app_routes.dart';
import 'package:nebu_mobile_flutter/core/constants/storage_keys.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/data/models/parental_consent.dart';
import 'package:nebu_mobile_flutter/data/models/user.dart';
import 'package:nebu_mobile_flutter/data/services/user_setup_service.dart';
import 'package:nebu_mobile_flutter/presentation/providers/api_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/auth_provider.dart';
import 'package:nebu_mobile_flutter/presentation/screens/setup/world_info_setup_screen.dart';
import 'package:nebu_mobile_flutter/presentation/widgets/nebu_voice_options.dart';
import 'package:nebu_mobile_flutter/presentation/widgets/setup_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/localization_test_helper.dart';
import '../../services/mocks.dart';

const _adult = User(id: 'user-1', email: 'adult@example.test');

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('current consent is rechecked without overwriting user setup', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      StorageKeys.setupVoicePreference: nebuVoiceOptions.first.id,
    });
    final apiService = MockApiService();
    when(
      apiService.get<Map<String, dynamic>>('/users/user-1/setup'),
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
    final setupService = UserSetupService(
      apiService: apiService,
      logger: MockLogger(),
    );
    final router = GoRouter(
      initialLocation: AppRoutes.worldInfoSetup.path,
      routes: [
        GoRoute(
          path: AppRoutes.worldInfoSetup.path,
          builder: (_, _) => const WorldInfoSetupScreen(),
        ),
        GoRoute(
          path: AppRoutes.home.path,
          builder: (_, _) => const Scaffold(
            body: Text('safe-home', key: ValueKey('safe-home')),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es'), Locale('pt')],
        path: 'assets/translations',
        assetLoader: const TestJsonAssetLoader(),
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('es'),
        saveLocale: false,
        child: ProviderScope(
          overrides: [
            authProvider.overrideWith(_SignedInAuthNotifier.new),
            userSetupServiceProvider.overrideWithValue(setupService),
            loggerProvider.overrideWithValue(MockLogger()),
          ],
          child: _WorldInfoTestApp(router: router),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final finishButton = find.byType(SetupPrimaryButton);
    await tester.ensureVisible(finishButton);
    await tester.tap(finishButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('safe-home')), findsOneWidget);
    verify(
      apiService.get<Map<String, dynamic>>('/users/user-1/setup'),
    ).called(1);
    verifyNoMoreInteractions(apiService);
  });
}

class _SignedInAuthNotifier extends AuthNotifier {
  @override
  Future<User?> build() async => _adult;
}

class _WorldInfoTestApp extends StatelessWidget {
  const _WorldInfoTestApp({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    theme: AppTheme.lightTheme.copyWith(platform: TargetPlatform.iOS),
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: context.localizationDelegates,
    routerConfig: router,
  );
}
