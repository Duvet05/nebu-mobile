import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:integration_test/integration_test.dart';
import 'package:logger/logger.dart';
import 'package:nebu_mobile_flutter/core/constants/app_routes.dart';
import 'package:nebu_mobile_flutter/core/constants/storage_keys.dart';
import 'package:nebu_mobile_flutter/core/router/app_router.dart';
import 'package:nebu_mobile_flutter/core/utils/google_auth_helper.dart';
import 'package:nebu_mobile_flutter/data/models/user.dart';
import 'package:nebu_mobile_flutter/data/services/activity_migration_service.dart';
import 'package:nebu_mobile_flutter/data/services/auth_service.dart';
import 'package:nebu_mobile_flutter/data/services/firebase_push_service.dart';
import 'package:nebu_mobile_flutter/main.dart';
import 'package:nebu_mobile_flutter/presentation/providers/api_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/auth_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/bluetooth_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/toy_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  testWidgets('Google social login authenticates through the app flow', (
    tester,
  ) async {
    await EasyLocalization.ensureInitialized();

    const storage = FlutterSecureStorage();
    const googleIdToken = 'e2e-google-id-token';
    final fakeAuthService = _FakeAuthService(storage: storage);
    final googleButton = find.byKey(
      const ValueKey<String>('login.googleButton'),
    );

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
            secureStorageProvider.overrideWithValue(storage),
            authServiceProvider.overrideWith((ref) async => fakeAuthService),
            googleAuthClientProvider.overrideWithValue(
              const _FakeGoogleAuthClient(googleIdToken),
            ),
            activityMigrationServiceProvider.overrideWithValue(
              const _NoopActivityMigrationService(),
            ),
            firebasePushServiceProvider.overrideWithValue(
              const _NoopFirebasePushService(),
            ),
            hasLocalToysProvider.overrideWith((ref) async => true),
            setupSkippedProvider.overrideWith((ref) async => false),
            connectedDevicesProvider.overrideWith((ref) async => const []),
          ],
          child: const NebuApp(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    final appContext = tester.element(find.byType(NebuApp));
    final container = ProviderScope.containerOf(appContext);
    container.read(routerProvider).go(AppRoutes.login.path);
    await tester.pumpAndSettle();

    await tester.ensureVisible(googleButton);
    await tester.tap(googleButton);
    await tester.pumpAndSettle();

    final user = container.read(authProvider).value;

    expect(fakeAuthService.lastGoogleToken, googleIdToken);
    expect(user?.email, 'social.e2e@example.com');
    expect(user?.emailVerified, isTrue);
    expect(
      await storage.read(key: StorageKeys.accessToken),
      'e2e-access-token',
    );
    expect(
      await storage.read(key: StorageKeys.refreshToken),
      'e2e-refresh-token',
    );
    expect(find.text('Hello, Social Tester!'), findsOneWidget);
  });
}

class _FakeGoogleAuthClient implements GoogleAuthClient {
  const _FakeGoogleAuthClient(this.idToken);

  final String idToken;

  @override
  Future<String> authenticateIdToken() => Future<String>.value(idToken);
}

class _FakeAuthService extends AuthService {
  _FakeAuthService({required FlutterSecureStorage storage})
    : _secureStorage = storage,
      super(dio: Dio(), secureStorage: storage, logger: Logger());

  final FlutterSecureStorage _secureStorage;
  String? lastGoogleToken;

  @override
  Future<SocialAuthResult> googleLogin(String token) async {
    lastGoogleToken = token;
    const tokens = AuthTokens(
      accessToken: 'e2e-access-token',
      refreshToken: 'e2e-refresh-token',
    );
    await _secureStorage.write(
      key: StorageKeys.accessToken,
      value: tokens.accessToken,
    );
    await _secureStorage.write(
      key: StorageKeys.refreshToken,
      value: tokens.refreshToken,
    );

    return const SocialAuthResult(
      success: true,
      user: User(
        id: 'social-e2e-user',
        email: 'social.e2e@example.com',
        firstName: 'Social',
        lastName: 'Tester',
        emailVerified: false,
      ),
      tokens: tokens,
    );
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: StorageKeys.accessToken);
    return token != null && token.isNotEmpty;
  }
}

class _NoopActivityMigrationService implements ActivityMigrationService {
  const _NoopActivityMigrationService();

  @override
  Future<void> clearMigrationData() => Future<void>.value();

  @override
  Future<String?> getLocalUserIdForMigration() => Future<String?>.value();

  @override
  Future<bool> isMigrationCompleted() => Future<bool>.value(false);

  @override
  Future<int?> migrateIfNeeded(String newUserId) => Future<int?>.value();

  @override
  Future<void> resetMigrationState() => Future<void>.value();
}

class _NoopFirebasePushService implements FirebasePushService {
  const _NoopFirebasePushService();

  @override
  Future<String?> getToken() => Future<String?>.value();

  @override
  Future<void> initialize() => Future<void>.value();
}
