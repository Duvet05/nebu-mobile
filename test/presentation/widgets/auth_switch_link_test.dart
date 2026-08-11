import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/presentation/widgets/auth_widgets.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('auth prompt and action are centered on separate lines', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: AuthSwitchLink(
              prompt: "Don't have an account?",
              action: 'Sign Up',
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    final prompt = find.text("Don't have an account?");
    final action = find.text('Sign Up');
    final promptRect = tester.getRect(prompt);
    final actionRect = tester.getRect(action);

    expect(actionRect.top, greaterThanOrEqualTo(promptRect.bottom));
    expect(actionRect.center.dx, closeTo(promptRect.center.dx, 0.5));

    await tester.tap(action);
    expect(tapped, isTrue);
    expect(tester.takeException(), isNull);
  });
}
