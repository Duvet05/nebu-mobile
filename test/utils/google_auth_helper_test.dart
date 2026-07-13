import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nebu_mobile_flutter/core/utils/google_auth_helper.dart';

void main() {
  group('Google Sign-In exception reporting', () {
    test('keeps a genuine-looking cancellation quiet in release mode', () {
      const exception = GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
      );

      expect(
        shouldReportGoogleSignInException(exception, debugDiagnostics: false),
        isFalse,
      );
    });

    test('reports an ambiguous cancellation in debug mode', () {
      const exception = GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
      );

      expect(shouldReportGoogleSignInException(exception), isTrue);
    });

    test(
      'reports canceled when the plugin includes configuration evidence',
      () {
        const exception = GoogleSignInException(
          code: GoogleSignInExceptionCode.canceled,
          description: 'OAuth client configuration error for package name',
        );

        expect(
          shouldReportGoogleSignInException(exception, debugDiagnostics: false),
          isTrue,
        );
      },
    );
  });

  testWidgets(
    'canceled logs and displays the Android OAuth diagnostic in debug',
    (tester) async {
      const exception = GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
        description: 'activity is cancelled by the user',
      );
      final logMessages = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        if (message != null) {
          logMessages.add(message);
        }
      };
      try {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              googleAuthClientProvider.overrideWithValue(
                const _ThrowingGoogleAuthClient(exception),
              ),
            ],
            child: const MaterialApp(home: _GoogleAuthTestScreen()),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(find.textContaining('signing SHA-1/SHA-256'), findsOneWidget);
        expect(
          logMessages,
          contains(
            allOf(
              contains('code=canceled'),
              contains('Android Credential Manager'),
              contains('signing SHA-1/SHA-256'),
            ),
          ),
        );
      } finally {
        debugPrint = originalDebugPrint;
      }
    },
  );
}

class _ThrowingGoogleAuthClient implements GoogleAuthClient {
  const _ThrowingGoogleAuthClient(this.exception);

  final GoogleSignInException exception;

  @override
  Future<String> authenticateIdToken() => Future<String>.error(exception);
}

class _GoogleAuthTestScreen extends ConsumerWidget {
  const _GoogleAuthTestScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: ElevatedButton(
      onPressed: () async {
        await handleGoogleAuth(context, ref);
      },
      child: const Text('Continue with Google'),
    ),
  );
}
