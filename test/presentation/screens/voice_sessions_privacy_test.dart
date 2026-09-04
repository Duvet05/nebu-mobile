import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/data/models/voice_session.dart';
import 'package:nebu_mobile_flutter/presentation/providers/voice_session_provider.dart';
import 'package:nebu_mobile_flutter/presentation/screens/voice_sessions_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/localization_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('distinguishes purged, expired, and genuinely empty sessions', (
    tester,
  ) async {
    final purgedSession = _session(
      id: 'session-purged',
      summary: 'Resumen con detalle purgado',
      messageCount: 4,
      metadata: {'rawConversationPurgedAt': '2026-09-04T12:00:00.000Z'},
    );
    final expiredSession = _session(
      id: 'session-expired',
      summary: 'Sesión vencida',
      messageCount: 8,
      metadata: {'retentionCleanedAt': '2026-09-04T12:00:00.000Z'},
    );
    final emptySession = _session(
      id: 'session-empty',
      summary: 'Sesión sin mensajes',
    );

    await _pumpScreen(tester, [purgedSession, expiredSession, emptySession]);
    await _expandSession(tester, 'Resumen con detalle purgado');

    expect(
      find.text(
        'Por privacidad, el detalle de esta conversación ya no se conserva. '
        'El resumen y las métricas siguen disponibles.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);

    await _expandSession(tester, 'Sesión vencida');
    expect(
      find.text(
        'Esta sesión superó el plazo de conservación. El detalle y el resumen '
        'ya no se conservan; solo quedan métricas generales.',
      ),
      findsOneWidget,
    );

    await _expandSession(tester, 'Sesión sin mensajes');
    expect(find.text('Sin mensajes en esta sesión'), findsOneWidget);
    expect(find.byIcon(Icons.privacy_tip_outlined), findsNWidgets(2));
  });
}

VoiceSession _session({
  required String id,
  required String summary,
  int messageCount = 0,
  Map<String, dynamic>? metadata,
}) => VoiceSession(
  id: id,
  status: 'ended',
  startedAt: DateTime(2026, 9, 4, 10),
  durationSeconds: 120,
  messageCount: messageCount,
  summary: summary,
  topics: const ['amistad'],
  emotion: 'alegre',
  metadata: metadata,
);

Future<void> _pumpScreen(
  WidgetTester tester,
  List<VoiceSession> sessions,
) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(800, 1800);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('es'), Locale('pt')],
      path: 'assets/translations',
      assetLoader: const TestJsonAssetLoader(),
      fallbackLocale: const Locale('es'),
      startLocale: const Locale('es'),
      saveLocale: false,
      child: ProviderScope(
        overrides: [
          voiceMetricsProvider.overrideWith(_FakeVoiceMetricsNotifier.new),
          userVoiceSessionsProvider.overrideWith(
            () => _FakeVoiceSessionsNotifier(sessions),
          ),
          sessionConversationsProvider.overrideWith(
            (ref, sessionId) async => const <AiConversation>[],
          ),
        ],
        child: const _VoiceSessionsTestApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _expandSession(WidgetTester tester, String summary) async {
  final title = find.text(summary);
  await tester.ensureVisible(title);
  await tester.tap(title);
  await tester.pumpAndSettle();
}

class _FakeVoiceMetricsNotifier extends VoiceMetricsNotifier {
  @override
  Future<VoiceMetrics> build() async => const VoiceMetrics(
    totalSessions: 3,
    totalConversations: 12,
    averageSessionDuration: 120,
  );
}

class _FakeVoiceSessionsNotifier extends UserVoiceSessionsNotifier {
  _FakeVoiceSessionsNotifier(this.sessions);

  final List<VoiceSession> sessions;

  @override
  Future<List<VoiceSession>> build() async => sessions;
}

class _VoiceSessionsTestApp extends StatelessWidget {
  const _VoiceSessionsTestApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.lightTheme.copyWith(platform: TargetPlatform.iOS),
    locale: context.locale,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: context.localizationDelegates,
    home: const VoiceSessionsScreen(),
  );
}
