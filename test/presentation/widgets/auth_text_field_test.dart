import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nebu_mobile_flutter/core/theme/app_theme.dart';
import 'package:nebu_mobile_flutter/presentation/widgets/auth_widgets.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('password feedback wraps and keeps password-manager support', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: _passwordStem());
    addTearDown(controller.dispose);
    const errorMessage =
        'Incluye al menos una mayúscula, una minúscula y un número. '
        'No necesitas un símbolo.';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: AuthTextField(
                controller: controller,
                label: 'Contraseña',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                autofillHints: const [AutofillHints.newPassword],
                autocorrect: false,
                enableSuggestions: false,
                helperText:
                    'Usa mayúscula, minúscula y número. No requiere símbolo.',
                validator: (_) => errorMessage,
              ),
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration!.errorMaxLines, 3);
    expect(field.decoration!.helperMaxLines, 3);
    expect(field.autofillHints, contains(AutofillHints.newPassword));
    expect(field.autocorrect, isFalse);
    expect(field.enableSuggestions, isFalse);
    expect(field.enableInteractiveSelection, isTrue);

    final renderedError = tester.widget<Text>(find.text(errorMessage));
    expect(renderedError.maxLines, 3);
    expect(tester.takeException(), isNull);
  });
}

String _passwordStem() => <String>['Nebu', 'Nebu'].join();
