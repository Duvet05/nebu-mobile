import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../presentation/providers/auth_provider.dart';

bool _googleAuthInProgress = false;

abstract interface class GoogleAuthClient {
  Future<String> authenticateIdToken();
}

final googleAuthClientProvider = Provider<GoogleAuthClient>(
  (_) => const GoogleSignInAuthClient(),
);

class GoogleSignInAuthClient implements GoogleAuthClient {
  const GoogleSignInAuthClient();

  @override
  Future<String> authenticateIdToken() async {
    final googleUser = await GoogleSignIn.instance.authenticate();
    final idToken = googleUser.authentication.idToken;

    if (idToken == null) {
      throw Exception('Google authentication returned no ID token');
    }

    return idToken;
  }
}

/// Shared Google sign-in handler for login and signup screens.
Future<void> handleGoogleAuth(BuildContext context, WidgetRef ref) async {
  if (_googleAuthInProgress) {
    return;
  }
  _googleAuthInProgress = true;

  try {
    final idToken = await ref
        .read(googleAuthClientProvider)
        .authenticateIdToken();

    if (!context.mounted) {
      return;
    }

    await ref.read(authProvider.notifier).loginWithGoogle(idToken);
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled) {
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.description ?? 'auth.google_signin_failed_detail'.tr(),
          ),
        ),
      );
    }
  } on Exception catch (e) {
    debugPrint('Google sign-in failed: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('auth.google_signin_failed_detail'.tr())),
      );
    }
  } finally {
    _googleAuthInProgress = false;
  }
}
