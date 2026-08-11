import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/utils/google_auth_helper.dart';
import 'auth_widgets.dart';
import 'google_web_sign_in_button.dart' as web;

/// Uses Google's SDK-rendered button on web and the native platform flow on
/// Android/iOS. Google Identity Services does not support authenticate() from
/// an application-rendered button in browsers.
class GoogleAuthButton extends ConsumerStatefulWidget {
  const GoogleAuthButton({
    required this.text,
    required this.isLoading,
    super.key,
  });

  final String text;
  final bool isLoading;

  @override
  ConsumerState<GoogleAuthButton> createState() => _GoogleAuthButtonState();
}

class _GoogleAuthButtonState extends ConsumerState<GoogleAuthButton> {
  StreamSubscription<GoogleSignInAuthenticationEvent>? _webAuthSubscription;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _webAuthSubscription = GoogleSignIn.instance.authenticationEvents.listen(
        _handleWebAuthenticationEvent,
        onError: _handleWebAuthenticationError,
      );
    }
  }

  void _handleWebAuthenticationEvent(GoogleSignInAuthenticationEvent event) {
    if (event case GoogleSignInAuthenticationEventSignIn()) {
      unawaited(
        handleGoogleIdToken(context, ref, event.user.authentication.idToken),
      );
    }
  }

  void _handleWebAuthenticationError(Object error, StackTrace stackTrace) {
    handleGoogleAuthenticationError(context, error);
  }

  @override
  void dispose() {
    unawaited(_webAuthSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return AuthGoogleButton(
        text: widget.text,
        isLoading: widget.isLoading,
        onPressed: () => handleGoogleAuth(context, ref),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = constraints.maxWidth.clamp(200.0, 400.0);
        return IgnorePointer(
          ignoring: widget.isLoading,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: widget.isLoading ? 0.55 : 1,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: Center(
                child: web.renderGoogleWebSignInButton(
                  minimumWidth: buttonWidth,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
