import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../presentation/providers/auth_provider.dart';

bool _googleAuthInProgress = false;

/// Shared Google sign-in handler for login and signup screens.
Future<void> handleGoogleAuth(BuildContext context, WidgetRef ref) async {
  if (_googleAuthInProgress) {
    return;
  }
  _googleAuthInProgress = true;

  try {
    debugPrint('[GOOGLE_AUTH] Clearing stale credentials...');
    await GoogleSignIn.instance.signOut();
    debugPrint('[GOOGLE_AUTH] Starting authenticate()...');
    final googleUser = await GoogleSignIn.instance.authenticate();
    debugPrint('[GOOGLE_AUTH] authenticate() returned: ${googleUser.email}');

    if (!context.mounted) {
      debugPrint('[GOOGLE_AUTH] Context not mounted after authenticate');
      return;
    }

    final idToken = googleUser.authentication.idToken;
    debugPrint('[GOOGLE_AUTH] idToken present: ${idToken != null}');

    if (idToken == null) {
      throw Exception('auth.google_no_id_token'.tr());
    }

    debugPrint('[GOOGLE_AUTH] Calling loginWithGoogle...');
    await ref.read(authProvider.notifier).loginWithGoogle(idToken);
    debugPrint('[GOOGLE_AUTH] loginWithGoogle completed');
  } on GoogleSignInException catch (e) {
    debugPrint(
      '[GOOGLE_AUTH] GoogleSignInException: code=${e.code}, '
      'desc=${e.description}',
    );
    // Only suppress genuine user cancellations — NOT CredentialManager failures
    // like "[16] Account reauth failed" which are misclassified as canceled.
    final isRealCancel = e.code == GoogleSignInExceptionCode.canceled &&
        (e.description == null || !e.description!.contains('reauth failed'));
    if (isRealCancel) {
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.google_signin_failed_detail'.tr()),
        ),
      );
    }
  } on Exception catch (e) {
    debugPrint('[GOOGLE_AUTH] Exception: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('auth.google_signin_failed_detail'.tr())),
      );
    }
  } on Error catch (e) { // ignore: avoid_catching_errors
    debugPrint('[GOOGLE_AUTH] Error (non-Exception): $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('auth.google_signin_failed_detail'.tr())),
      );
    }
  } finally {
    _googleAuthInProgress = false;
  }
}
