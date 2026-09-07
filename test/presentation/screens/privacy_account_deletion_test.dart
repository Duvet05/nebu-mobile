import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nebu_mobile_flutter/core/constants/app_routes.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/data/models/user.dart';
import 'package:nebu_mobile_flutter/data/services/user_service.dart';
import 'package:nebu_mobile_flutter/presentation/providers/api_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/auth_provider.dart';
import 'package:nebu_mobile_flutter/presentation/screens/privacy_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/localization_test_helper.dart';

const _localUser = User(id: 'deletion-user', email: 'local@example.test');
const _oauthUser = User(
  id: 'deletion-user',
  email: 'oauth@example.test',
  requiresPasswordForDeletion: false,
);
const _otherUser = User(id: 'other-user', email: 'other@example.test');
const _permissionChannel = MethodChannel(
  'flutter.baseflow.com/permissions/methods',
);

Finder _key(String name) => find.byKey(ValueKey<String>('privacy.$name'));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_permissionChannel, (call) async => 0);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_permissionChannel, null);
  });

  testWidgets('refreshes the account and shows its email in both dialogs', (
    tester,
  ) async {
    final fixture = await _pumpScreen(tester, signedIn: _localUser);

    await _openDeletion(tester);

    expect(fixture.service.profileCalls, 1);
    expect(_key('deleteAccountWarningDialog'), findsOneWidget);
    expect(find.textContaining(_oauthUser.email), findsOneWidget);
    expect(find.textContaining(_localUser.email), findsNothing);

    await _continueDeletion(tester);

    expect(_key('deleteAccountConfirmDialog'), findsOneWidget);
    expect(find.textContaining(_oauthUser.email), findsOneWidget);
    expect(_key('deleteConfirmationField'), findsOneWidget);
    expect(_key('deletePasswordField'), findsNothing);
    expect(fixture.service.passwords, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'OAuth requires DELETE and logs out only after deletion succeeds',
    (tester) async {
      final deletion = Completer<String>();
      final fixture = await _pumpScreen(tester);
      fixture.service.deletionResult = deletion.future;
      await _openConfirmation(tester);

      await _submit(tester);
      expect(fixture.service.passwords, isEmpty);
      await _enter(tester, 'deleteConfirmationField', 'KEEP');
      await _submit(tester);
      expect(fixture.service.passwords, isEmpty);
      expect(_key('deleteAccountConfirmDialog'), findsOneWidget);

      await _enter(tester, 'deleteConfirmationField', 'DELETE');
      await tester.tap(_key('deleteAccountSubmitButton'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(fixture.service.passwords, <String?>[null]);
      expect(fixture.service.expectedUserIds, [_oauthUser.id]);
      expect(fixture.auth.logoutCalls, 0);
      expect(find.byKey(const ValueKey('deletion-welcome')), findsNothing);

      deletion.complete('Deleted');
      await tester.pumpAndSettle();

      expect(fixture.auth.logoutCalls, 1);
      expect(fixture.container.read(authProvider).value, isNull);
      expect(find.byKey(const ValueKey('deletion-welcome')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('local accounts require and forward a password by default', (
    tester,
  ) async {
    final fixture = await _pumpScreen(
      tester,
      signedIn: _localUser,
      profile: _localUser,
    );
    await _openConfirmation(tester);

    expect(_key('deletePasswordField'), findsOneWidget);
    expect(_key('deleteConfirmationField'), findsOneWidget);
    await _enter(tester, 'deleteConfirmationField', 'DELETE');
    await _submit(tester);
    expect(fixture.service.passwords, isEmpty);
    expect(fixture.auth.logoutCalls, 0);
    expect(_key('deleteAccountConfirmDialog'), findsOneWidget);

    const password = 'fixture-only-password';
    await _enter(tester, 'deletePasswordField', password);
    await _submit(tester);

    expect(fixture.service.passwords, <String?>[password]);
    expect(fixture.service.expectedUserIds, [_localUser.id]);
    expect(fixture.auth.logoutCalls, 1);
    expect(find.byKey(const ValueKey('deletion-welcome')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'OAuth deletion remains usable on a compact screen with a long email',
    (tester) async {
      const user = User(
        id: 'compact-deletion-user',
        email: 'long-account-identity-for-confirmation@reviewer.example.test',
        requiresPasswordForDeletion: false,
      );
      final fixture = await _pumpScreen(
        tester,
        signedIn: user,
        profile: user,
        size: const Size(320, 568),
      );
      await _openDeletion(tester);
      expect(find.text(user.email), findsOneWidget);
      expect(_key('deleteAccountContinueButton').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _continueDeletion(tester);
      expect(find.text(user.email), findsOneWidget);
      expect(_key('deleteConfirmationField').hitTestable(), findsOneWidget);
      expect(_key('deletePasswordField'), findsNothing);
      await _enter(tester, 'deleteConfirmationField', 'DELETE');
      expect(_key('deleteAccountSubmitButton').hitTestable(), findsOneWidget);
      await _submit(tester);

      expect(fixture.service.passwords, <String?>[null]);
      expect(fixture.auth.logoutCalls, 1);
      expect(find.byKey(const ValueKey('deletion-welcome')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final confirmation in [false, true]) {
    testWidgets(
      'cancel ${confirmation ? 'confirmation' : 'warning'} never deletes or logs out',
      (tester) async {
        final fixture = await _pumpScreen(tester);
        await _openDeletion(tester);
        if (confirmation) {
          await _continueDeletion(tester);
          await _enter(tester, 'deleteConfirmationField', 'DELETE');
        }

        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
        await tester.pumpAndSettle();

        expect(fixture.service.passwords, isEmpty);
        expect(fixture.auth.logoutCalls, 0);
        expect(_key('deleteAccountWarningDialog'), findsNothing);
        expect(_key('deleteAccountConfirmDialog'), findsNothing);
        expect(fixture.container.read(authProvider).value?.id, _oauthUser.id);
      },
    );
  }

  testWidgets('backend rejection keeps the account signed in', (tester) async {
    final fixture = await _pumpScreen(tester);
    fixture.service.deletionError = Exception(
      'Deletion rejected for this test',
    );
    await _openConfirmation(tester);
    await _enter(tester, 'deleteConfirmationField', 'DELETE');
    await _submit(tester);

    expect(fixture.service.passwords, <String?>[null]);
    expect(fixture.auth.logoutCalls, 0);
    expect(fixture.container.read(authProvider).value?.id, _oauthUser.id);
    expect(find.byType(PrivacySettingsScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('deletion-welcome')), findsNothing);
    expect(find.text('Deletion rejected for this test'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile failure cannot open a deletion confirmation', (
    tester,
  ) async {
    final fixture = await _pumpScreen(tester);
    fixture.service.profileError = Exception(
      'Profile unavailable for this test',
    );
    await _openDeletion(tester);

    expect(fixture.service.profileCalls, 1);
    _expectDeletionBlocked(fixture);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a signed-out account cannot request a deletion profile', (
    tester,
  ) async {
    final fixture = await _pumpScreen(tester, signedIn: null);
    await _openDeletion(tester);

    expect(fixture.service.profileCalls, 0);
    _expectDeletionBlocked(fixture);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a refreshed profile for a different account is rejected', (
    tester,
  ) async {
    final fixture = await _pumpScreen(tester, profile: _otherUser);
    await _openDeletion(tester);

    expect(fixture.service.profileCalls, 1);
    _expectDeletionBlocked(fixture);
    expect(find.textContaining(_otherUser.email), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a session change while refreshing blocks the old account', (
    tester,
  ) async {
    final profile = Completer<User>();
    final fixture = await _pumpScreen(tester);
    fixture.service.profileResult = profile.future;
    await tester.ensureVisible(_key('deleteAccountTile'));
    await tester.tap(_key('deleteAccountTile'));
    await tester.pump();
    expect(fixture.service.profileCalls, 1);

    fixture.auth.changeSession(_otherUser);
    profile.complete(_oauthUser);
    await tester.pumpAndSettle();

    _expectDeletionBlocked(fixture);
    expect(fixture.container.read(authProvider).value?.id, _otherUser.id);
    expect(tester.takeException(), isNull);
  });

  for (final nextUser in <User?>[_otherUser, null]) {
    testWidgets(
      '${nextUser == null ? 'lost' : 'changed'} session before final confirmation cannot delete',
      (tester) async {
        final fixture = await _pumpScreen(tester);
        await _openConfirmation(tester);
        await _enter(tester, 'deleteConfirmationField', 'DELETE');

        fixture.auth.changeSession(nextUser);
        await tester.pump();
        await _submit(tester);

        expect(fixture.service.passwords, isEmpty);
        expect(fixture.auth.logoutCalls, 0);
        expect(fixture.container.read(authProvider).value?.id, nextUser?.id);
        expect(find.byKey(const ValueKey('deletion-welcome')), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'deletion finishing after a session switch never logs out the new account',
    (tester) async {
      final deletion = Completer<String>();
      final fixture = await _pumpScreen(tester);
      fixture.service.deletionResult = deletion.future;
      await _openConfirmation(tester);
      await _enter(tester, 'deleteConfirmationField', 'DELETE');
      await tester.tap(_key('deleteAccountSubmitButton'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(fixture.service.expectedUserIds, [_oauthUser.id]);
      expect(fixture.service.passwords, <String?>[null]);
      expect(fixture.auth.logoutCalls, 0);

      fixture.auth.changeSession(_otherUser);
      await tester.pump();
      deletion.complete('Deleted');
      await tester.pumpAndSettle();

      expect(fixture.service.expectedUserIds, [_oauthUser.id]);
      expect(fixture.auth.logoutCalls, 0);
      expect(fixture.container.read(authProvider).value, _otherUser);
      expect(find.byKey(const ValueKey('deletion-welcome')), findsNothing);
      expect(find.byType(PrivacySettingsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

void _expectDeletionBlocked(_Fixture fixture) {
  expect(_key('deleteAccountWarningDialog'), findsNothing);
  expect(_key('deleteAccountConfirmDialog'), findsNothing);
  expect(fixture.service.passwords, isEmpty);
  expect(fixture.auth.logoutCalls, 0);
  expect(find.byKey(const ValueKey('deletion-welcome')), findsNothing);
}

Future<void> _openDeletion(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    _key('deleteAccountTile'),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(_key('deleteAccountTile'));
  await tester.pumpAndSettle();
}

Future<void> _continueDeletion(WidgetTester tester) async {
  await tester.tap(_key('deleteAccountContinueButton'));
  await tester.pumpAndSettle();
}

Future<void> _openConfirmation(WidgetTester tester) async {
  await _openDeletion(tester);
  await _continueDeletion(tester);
}

Future<void> _enter(WidgetTester tester, String key, String text) async {
  final field = find.descendant(
    of: _key(key),
    matching: find.byType(TextFormField),
  );
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pump();
}

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(_key('deleteAccountSubmitButton'));
  await tester.pumpAndSettle();
}

Future<_Fixture> _pumpScreen(
  WidgetTester tester, {
  User? signedIn = _oauthUser,
  User profile = _oauthUser,
  Size size = const Size(800, 1800),
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  final service = _FakeUserService(profile);
  final auth = _FakeAuthNotifier(signedIn);
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(() => auth),
      userServiceProvider.overrideWithValue(service),
    ],
  );
  await container.read(authProvider.future);
  final router = GoRouter(
    initialLocation: AppRoutes.privacySettings.path,
    routes: [
      GoRoute(
        path: AppRoutes.privacySettings.path,
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome.path,
        builder: (context, state) => const Scaffold(
          body: Text('Welcome', key: ValueKey('deletion-welcome')),
        ),
      ),
    ],
  );
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    router.dispose();
    container.dispose();
  });

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es'), Locale('pt')],
        path: 'assets/translations',
        assetLoader: const TestJsonAssetLoader(),
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        saveLocale: false,
        child: _DeletionTestApp(router),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _Fixture(service, auth, container);
}

class _Fixture {
  const _Fixture(this.service, this.auth, this.container);

  final _FakeUserService service;
  final _FakeAuthNotifier auth;
  final ProviderContainer container;
}

class _FakeUserService extends Fake implements UserService {
  _FakeUserService(this.profile);

  final User profile;
  int profileCalls = 0;
  final passwords = <String?>[];
  final expectedUserIds = <String>[];
  Future<User>? profileResult;
  Future<String>? deletionResult;
  Exception? profileError;
  Exception? deletionError;

  @override
  Future<User> getCurrentUserProfile() async {
    profileCalls++;
    if (profileError != null) {
      throw profileError!;
    }
    return profileResult == null ? profile : await profileResult!;
  }

  @override
  Future<String> deleteOwnAccount({
    required String expectedUserId,
    String? password,
    String? reason,
  }) async {
    expectedUserIds.add(expectedUserId);
    passwords.add(password);
    if (deletionError != null) {
      throw deletionError!;
    }
    return deletionResult == null ? 'Deleted' : await deletionResult!;
  }
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this.initialUser);

  final User? initialUser;
  int logoutCalls = 0;

  @override
  Future<User?> build() async => initialUser;

  void changeSession(User? user) => state = AsyncData(user);

  @override
  Future<void> logout() async {
    logoutCalls++;
    state = const AsyncData(null);
  }
}

class _DeletionTestApp extends StatelessWidget {
  const _DeletionTestApp(this.router);

  final GoRouter router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    theme: AppTheme.lightTheme,
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: context.localizationDelegates,
    routerConfig: router,
  );
}
