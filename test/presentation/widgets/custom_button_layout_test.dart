import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/presentation/widgets/custom_button.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  for (final variant in ButtonVariant.values) {
    testWidgets(
      'CustomButton ${variant.name} grows and stays tappable at 2x text',
      (tester) async {
        tester.view
          ..devicePixelRatio = 1
          ..physicalSize = const Size(320, 568);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        var tapCount = 0;
        const label = 'Executar uma ação deliberadamente longa';

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                  text: label,
                  onPressed: () => tapCount++,
                  variant: variant,
                  isFullWidth: true,
                  icon: Icons.check,
                  height: 40,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final button = _materialButtonFor(variant);
        expect(button, findsOneWidget);
        expect(
          tester.getRect(button).height,
          greaterThanOrEqualTo(kMinInteractiveDimension),
        );
        expect(button.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(button);
        await tester.pump();
        expect(tapCount, 1);
      },
    );
  }
}

Finder _materialButtonFor(ButtonVariant variant) => switch (variant) {
  ButtonVariant.primary ||
  ButtonVariant.secondary ||
  ButtonVariant.danger => find.byType(ElevatedButton),
  ButtonVariant.outline ||
  ButtonVariant.dangerOutline => find.byType(OutlinedButton),
  ButtonVariant.text => find.byType(TextButton),
};
