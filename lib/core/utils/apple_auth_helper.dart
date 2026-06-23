import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../presentation/providers/auth_provider.dart';

bool _appleAuthInProgress = false;

/// Shared Apple sign-in handler.
Future<void> handleAppleAuth(BuildContext context, WidgetRef ref) async {
  if (_appleAuthInProgress) {
    return;
  }
  _appleAuthInProgress = true;

  try {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    if (!context.mounted) {
      return;
    }

    // The identityToken is used by the backend to verify the user
    if (credential.identityToken != null) {
      await ref.read(authProvider.notifier).loginWithApple(credential.identityToken!);
    } else {
      throw Exception('Apple authentication returned no identity token');
    }
  } on Exception catch (e) {
    debugPrint('Apple sign-in failed: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('auth.apple_signin_failed'.tr())),
      );
    }
  } finally {
    _appleAuthInProgress = false;
  }
}
