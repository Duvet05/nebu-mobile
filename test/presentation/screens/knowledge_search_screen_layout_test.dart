import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/data/models/voice_session.dart';
import 'package:nebu_mobile_flutter/presentation/providers/memory_provider.dart';
import 'package:nebu_mobile_flutter/presentation/screens/knowledge_search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _category = 'Ciência natural interdisciplinar avançada';
const _source = 'Enciclopédia Internacional de Conhecimento Infantil Revisada';

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'knowledge footer wraps long remote metadata on compact screens',
    (tester) async {
      final textScale = ValueNotifier<double>(1);
      addTearDown(textScale.dispose);
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            knowledgeSearchProvider.overrideWith(_FakeKnowledgeNotifier.new),
          ],
          child: EasyLocalization(
            supportedLocales: const [Locale('en'), Locale('es'), Locale('pt')],
            path: 'assets/translations',
            fallbackLocale: const Locale('pt'),
            startLocale: const Locale('pt'),
            saveLocale: false,
            child: _KnowledgeTestApp(textScale: textScale),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final scale in const <double>[1, 2]) {
        textScale.value = scale;
        await tester.pumpAndSettle();

        final scenario = '320x568, PT, ${scale}x text';
        final category = find.text(_category);
        final source = find.text(_source);
        expect(category, findsOneWidget, reason: scenario);
        expect(source, findsOneWidget, reason: scenario);
        expect(tester.takeException(), isNull, reason: scenario);

        for (final metadata in [category, source]) {
          final rect = tester.getRect(metadata);
          expect(rect.left, greaterThanOrEqualTo(0), reason: scenario);
          expect(rect.right, lessThanOrEqualTo(320), reason: scenario);
          final text = tester.widget<Text>(metadata);
          expect(text.maxLines, isNull, reason: scenario);
          expect(text.overflow, isNull, reason: scenario);
        }

        await tester.ensureVisible(source);
        await tester.pump();
        final visibleSourceRect = tester.getRect(source);
        expect(
          visibleSourceRect.top,
          greaterThanOrEqualTo(0),
          reason: scenario,
        );
        expect(
          visibleSourceRect.bottom,
          lessThanOrEqualTo(568),
          reason: scenario,
        );
        expect(source.hitTestable(), findsOneWidget, reason: scenario);
      }
    },
  );
}

class _FakeKnowledgeNotifier extends KnowledgeSearchNotifier {
  @override
  AsyncValue<List<KnowledgeEntry>> build() => const AsyncValue.data([
    KnowledgeEntry(
      id: 'knowledge-layout',
      content: 'Conteúdo breve para isolar o rodapé.',
      relevance: 98,
      metadata: {
        'topic': 'Tema',
        'category': _category,
        'verified': true,
        'source': _source,
      },
    ),
  ]);
}

class _KnowledgeTestApp extends StatelessWidget {
  const _KnowledgeTestApp({required this.textScale});

  final ValueNotifier<double> textScale;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<double>(
    valueListenable: textScale,
    builder: (context, scale, child) => MaterialApp(
      theme: AppTheme.lightTheme.copyWith(platform: TargetPlatform.iOS),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: const KnowledgeSearchScreen(),
    ),
  );
}
