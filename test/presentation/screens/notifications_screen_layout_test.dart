import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/data/models/app_notification.dart';
import 'package:nebu_mobile_flutter/data/services/api_service.dart';
import 'package:nebu_mobile_flutter/data/services/notification_service.dart';
import 'package:nebu_mobile_flutter/presentation/providers/api_provider.dart';
import 'package:nebu_mobile_flutter/presentation/screens/notifications_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'notifications app bar action fits a compact Portuguese viewport',
    (tester) async {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final service = _FakeNotificationService();
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('es'), Locale('pt')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          startLocale: const Locale('pt'),
          saveLocale: false,
          child: ProviderScope(
            overrides: [notificationServiceProvider.overrideWithValue(service)],
            child: _NotificationsTestApp(navigatorKey: navigatorKey),
          ),
        ),
      );
      await tester.pumpAndSettle();
      unawaited(
        navigatorKey.currentState!.push<void>(
          MaterialPageRoute<void>(
            builder: (context) => const NotificationsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      const tooltip = 'Marcar todas como lidas';
      expect(find.byTooltip(tooltip), findsOneWidget);
      final action = find.widgetWithIcon(IconButton, Icons.done_all);
      expect(action, findsOneWidget);
      expect(action.hitTestable(), findsOneWidget);
      final actionRect = tester.getRect(action);
      expect(actionRect.width, greaterThanOrEqualTo(kMinInteractiveDimension));
      expect(actionRect.height, greaterThanOrEqualTo(kMinInteractiveDimension));
      expect(actionRect.right, lessThanOrEqualTo(320));
      final semantics = tester.ensureSemantics();
      await tester.pump();
      try {
        final semanticsData = tester
            .getSemantics(find.byTooltip(tooltip))
            .getSemanticsData();
        expect(semanticsData.tooltip, tooltip);
        expect(semanticsData.flagsCollection.isButton, isTrue);
        expect(semanticsData.flagsCollection.isEnabled.toBoolOrNull(), isTrue);
      } finally {
        semantics.dispose();
      }
      expect(tester.takeException(), isNull);

      await tester.tap(action);
      await tester.pumpAndSettle();

      expect(service.markAllCalled, isTrue);
      expect(find.byTooltip(tooltip), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

class _NotificationsTestApp extends StatelessWidget {
  const _NotificationsTestApp({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: navigatorKey,
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
    home: const Scaffold(body: SizedBox.shrink()),
  );
}

class _FakeNotificationService extends NotificationService {
  _FakeNotificationService()
    : super(apiService: _FakeApiService(), logger: Logger());

  bool markAllCalled = false;

  @override
  Future<List<AppNotification>> getMyNotifications() async => [
    AppNotification(
      id: 'notification-1',
      title: 'Atualização',
      message: 'Há uma atualização disponível.',
      createdAt: DateTime(2026),
    ),
  ];

  @override
  Future<void> markAllAsRead() async {
    markAllCalled = true;
  }
}

class _FakeApiService extends Fake implements ApiService {}
