import 'dart:convert';
import 'dart:typed_data';

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
import 'package:nebu_mobile_flutter/data/services/activity_migration_service.dart';
import 'package:nebu_mobile_flutter/data/services/bluetooth_service.dart';
import 'package:nebu_mobile_flutter/data/services/firebase_push_service.dart';
import 'package:nebu_mobile_flutter/main.dart';
import 'package:nebu_mobile_flutter/presentation/providers/api_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/auth_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/bluetooth_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/toy_provider.dart';
import 'package:nebu_mobile_flutter/presentation/screens/email_verification_screen.dart';
import 'package:nebu_mobile_flutter/presentation/screens/privacy_settings_screen.dart';
import 'package:nebu_mobile_flutter/presentation/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _email = 'account.lifecycle.e2e@example.com';
final _testCredential = <String>['Lifecycle', '42', '!'].join();
const _accessToken = 'account-lifecycle-access-token';
const _refreshToken = 'account-lifecycle-refresh-token';
const _verificationToken = 'account-lifecycle-verification-token';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  testWidgets(
    'creates, verifies, and permanently deletes an account through the app',
    (tester) async {
      await EasyLocalization.ensureInitialized();

      const storage = FlutterSecureStorage();
      final backend = _AccountLifecycleBackend();
      final authDio = Dio()..httpClientAdapter = backend;
      final apiDio = Dio()..httpClientAdapter = backend;

      addTearDown(() {
        authDio.close(force: true);
        apiDio.close(force: true);
      });

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
              authDioProvider.overrideWithValue(authDio),
              dioProvider.overrideWithValue(apiDio),
              activityMigrationServiceProvider.overrideWithValue(
                const _NoopActivityMigrationService(),
              ),
              firebasePushServiceProvider.overrideWithValue(
                const _NoopFirebasePushService(),
              ),
              bluetoothServiceProvider.overrideWithValue(
                _NoopBluetoothService(),
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
      void go(String location) => container.read(routerProvider).go(location);

      go(AppRoutes.signUp.path);
      await tester.pumpAndSettle();

      await _enterText(tester, 'signup.firstNameField', 'Lifecycle');
      await _enterText(tester, 'signup.lastNameField', 'Tester');
      await _enterText(tester, 'signup.emailField', _email);
      await _enterText(tester, 'signup.passwordField', _testCredential);
      await _enterText(tester, 'signup.confirmPasswordField', _testCredential);

      final submit = find.byKey(const ValueKey<String>('signup.submitButton'));
      await tester.ensureVisible(submit);
      await tester.tap(submit);

      await _pumpUntil(
        tester,
        () =>
            backend.registered &&
            find.byType(EmailVerificationScreen).evaluate().isNotEmpty,
        reason: 'registration did not reach the email verification gate',
      );

      expect(backend.registrationBody, containsPair('email', _email));
      expect(
        backend.registrationBody,
        containsPair('password', _testCredential),
      );
      expect(backend.registrationBody, containsPair('firstName', 'Lifecycle'));
      expect(backend.registrationBody, containsPair('lastName', 'Tester'));
      expect(container.read(authProvider).value?.emailVerified, isFalse);
      expect(await storage.read(key: StorageKeys.accessToken), _accessToken);
      expect(await storage.read(key: StorageKeys.refreshToken), _refreshToken);

      go('${AppRoutes.verifyEmail.path}?token=$_verificationToken');
      await _pumpUntil(
        tester,
        () =>
            backend.verified &&
            (container.read(authProvider).value?.emailVerified ?? false),
        reason: 'verification deep link did not activate the account',
      );

      expect(backend.verificationToken, _verificationToken);
      expect(backend.profileAuthorization, 'Bearer $_accessToken');

      go(AppRoutes.privacySettings.path);
      await _pumpUntil(
        tester,
        () => find.byType(PrivacySettingsScreen).evaluate().isNotEmpty,
        reason: 'verified account could not open privacy settings',
      );

      final deleteTile = find.byKey(
        const ValueKey<String>('privacy.deleteAccountTile'),
      );
      await tester.scrollUntilVisible(
        deleteTile,
        300,
        scrollable: find
            .descendant(
              of: find.byType(PrivacySettingsScreen),
              matching: find.byType(Scrollable),
            )
            .first,
        maxScrolls: 10,
      );
      await tester.pumpAndSettle();
      expect(deleteTile, findsOneWidget);
      await tester.tap(deleteTile);
      await _pumpUntil(
        tester,
        () => find
            .byKey(const ValueKey<String>('privacy.deleteAccountWarningDialog'))
            .evaluate()
            .isNotEmpty,
        reason: 'delete-account warning dialog did not open',
      );

      expect(
        find.byKey(
          const ValueKey<String>('privacy.deleteAccountWarningDialog'),
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(
          const ValueKey<String>('privacy.deleteAccountContinueButton'),
        ),
      );
      await tester.pumpAndSettle();

      await _enterText(tester, 'privacy.deleteConfirmationField', 'DELETE');
      await _enterText(tester, 'privacy.deletePasswordField', _testCredential);
      await tester.tap(
        find.byKey(const ValueKey<String>('privacy.deleteAccountSubmitButton')),
      );

      await _pumpUntil(
        tester,
        () =>
            backend.deleted &&
            container.read(authProvider).value == null &&
            find.byType(WelcomeScreen).evaluate().isNotEmpty,
        reason: 'account deletion did not clear the session and return home',
      );

      expect(backend.deletionBody, containsPair('password', _testCredential));
      expect(backend.deletionAuthorization, 'Bearer $_accessToken');
      expect(await storage.read(key: StorageKeys.accessToken), isNull);
      expect(await storage.read(key: StorageKeys.refreshToken), isNull);
      expect(await storage.read(key: StorageKeys.user), isNull);

      final authService = await container.read(authServiceProvider.future);
      final deletedLogin = await authService.login(
        identifier: _email,
        password: _testCredential,
      );
      expect(deletedLogin.success, isFalse);
      expect(backend.loginAttemptsAfterDeletion, 1);
    },
  );
}

Future<void> _enterText(
  WidgetTester tester,
  String parentKey,
  String value,
) async {
  final parent = find.byKey(ValueKey<String>(parentKey));
  await tester.ensureVisible(parent);
  await tester.pump();
  final input = find.descendant(
    of: parent,
    matching: find.byType(TextFormField),
  );
  expect(input, findsOneWidget);
  await tester.enterText(input, value);
  await tester.pump();
}

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  required String reason,
}) async {
  for (var attempt = 0; attempt < 120; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (condition()) {
      return;
    }
  }
  throw TestFailure(reason);
}

// Stateful HTTP boundary for a deterministic device E2E. Production registration
// requires an external email link, so using it here could leave orphaned accounts.
class _AccountLifecycleBackend implements HttpClientAdapter {
  bool registered = false;
  bool verified = false;
  bool deleted = false;
  int loginAttemptsAfterDeletion = 0;
  String? verificationToken;
  String? profileAuthorization;
  String? deletionAuthorization;
  Map<String, dynamic> registrationBody = <String, dynamic>{};
  Map<String, dynamic> deletionBody = <String, dynamic>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final method = options.method.toUpperCase();
    final path = options.path;

    if (method == 'POST' && path == '/auth/register') {
      registrationBody = _body(options.data);
      registered = true;
      return _jsonResponse(<String, dynamic>{
        'accessToken': _accessToken,
        'refreshToken': _refreshToken,
        'expiresIn': 3600,
        'user': _userJson(emailVerified: false),
      }, 201);
    }

    if (method == 'POST' && path == '/auth/verify-email') {
      verificationToken = options.queryParameters['token'] as String?;
      if (!registered || verificationToken != _verificationToken) {
        return _jsonResponse(<String, dynamic>{'error': 'Invalid token'}, 400);
      }
      verified = true;
      return _jsonResponse(<String, dynamic>{'message': 'Email verified'}, 200);
    }

    if (method == 'GET' && path == '/users/me') {
      profileAuthorization = options.headers['Authorization'] as String?;
      if (!registered || !verified || deleted) {
        return _jsonResponse(<String, dynamic>{'error': 'Unauthorized'}, 401);
      }
      return _jsonResponse(_userJson(emailVerified: true), 200);
    }

    if (method == 'DELETE' && path == '/users/me') {
      deletionAuthorization = options.headers['Authorization'] as String?;
      deletionBody = _body(options.data);
      if (!verified ||
          deletionAuthorization != 'Bearer $_accessToken' ||
          deletionBody['password'] != _testCredential) {
        return _jsonResponse(<String, dynamic>{'error': 'Unauthorized'}, 401);
      }
      deleted = true;
      return _jsonResponse(<String, dynamic>{
        'message': 'Account deleted',
      }, 200);
    }

    if (method == 'POST' && path == '/auth/logout') {
      return _jsonResponse(<String, dynamic>{'message': 'Session closed'}, 200);
    }

    if (method == 'POST' && path == '/auth/login') {
      if (deleted) {
        loginAttemptsAfterDeletion++;
      }
      return _jsonResponse(<String, dynamic>{
        'error': 'Account deleted',
        'errorCode': 'UNAUTHORIZED',
      }, 401);
    }

    return _jsonResponse(<String, dynamic>{
      'error': 'Unexpected request $method $path',
    }, 404);
  }

  @override
  void close({bool force = false}) {}

  Map<String, dynamic> _userJson({required bool emailVerified}) =>
      <String, dynamic>{
        'id': 'account-lifecycle-user',
        'email': _email,
        'firstName': 'Lifecycle',
        'lastName': 'Tester',
        'username': 'lifecycle_tester',
        'status': emailVerified ? 'active' : 'pending',
        'emailVerified': emailVerified,
        'preferredLanguage': 'en',
      };
}

Map<String, dynamic> _body(Object? data) {
  if (data is Map<String, dynamic>) {
    return Map<String, dynamic>.from(data);
  }
  if (data is Map) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }
  if (data is String && data.isNotEmpty) {
    return jsonDecode(data) as Map<String, dynamic>;
  }
  return <String, dynamic>{};
}

ResponseBody _jsonResponse(Object payload, int statusCode) =>
    ResponseBody.fromString(
      jsonEncode(payload),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );

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

class _NoopBluetoothService extends BluetoothService {
  _NoopBluetoothService() : super(logger: Logger());

  @override
  Future<void> stopScan() => Future<void>.value();

  @override
  Future<void> disconnect() => Future<void>.value();
}
