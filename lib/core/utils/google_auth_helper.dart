import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../presentation/providers/auth_provider.dart';

bool _googleAuthInProgress = false;

const String _googleSignInConfigurationHint =
    'OAuth diagnostic: verify the Android package name, signing SHA-1/SHA-256, '
    'and web server client ID. Android Credential Manager can report an OAuth '
    'configuration failure as "canceled".';

const List<String> _googleSignInConfigurationMarkers = <String>[
  'certificate',
  'client configuration',
  'client id',
  'clientid',
  'configuration error',
  'developer error',
  'developer_error',
  'oauth',
  'package name',
  'server client',
  'serverclientid',
  'sha-1',
  'sha1',
];

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

/// Whether an exception should be surfaced to the user instead of being
/// treated as an intentional cancellation.
///
/// Android's Credential Manager may return [GoogleSignInExceptionCode.canceled]
/// for OAuth configuration failures. In debug builds, ambiguous cancellations
/// are therefore surfaced with a configuration checklist. Release builds keep
/// genuine-looking cancellations quiet, unless the exception itself contains
/// evidence of a configuration problem.
@visibleForTesting
bool shouldReportGoogleSignInException(
  GoogleSignInException exception, {
  bool debugDiagnostics = kDebugMode,
}) {
  if (exception.code != GoogleSignInExceptionCode.canceled) {
    return true;
  }

  return debugDiagnostics || _hasGoogleSignInConfigurationEvidence(exception);
}

bool _hasGoogleSignInConfigurationEvidence(GoogleSignInException exception) {
  if (exception.code == GoogleSignInExceptionCode.clientConfigurationError ||
      exception.code == GoogleSignInExceptionCode.providerConfigurationError) {
    return true;
  }

  final diagnosticText = <Object?>[
    exception.description,
    exception.details,
  ].whereType<Object>().join(' ').toLowerCase();

  return _googleSignInConfigurationMarkers.any(diagnosticText.contains);
}

void _logGoogleSignInException(GoogleSignInException exception) {
  final diagnostic = StringBuffer(
    'Google Sign-In ended with code=${exception.code.name}',
  );

  if (kDebugMode) {
    final description = exception.description?.trim();
    final details = exception.details;
    if (description != null && description.isNotEmpty) {
      diagnostic.write(', description=$description');
    }
    if (details != null) {
      diagnostic.write(', details=$details');
    }
    if (exception.code == GoogleSignInExceptionCode.canceled ||
        _hasGoogleSignInConfigurationEvidence(exception)) {
      diagnostic.write('. $_googleSignInConfigurationHint');
    }
  }

  debugPrint(diagnostic.toString());
}

String _googleSignInFailureMessage(GoogleSignInException exception) {
  final fallback = 'auth.google_signin_failed_detail'.tr();

  if (kDebugMode &&
      (exception.code == GoogleSignInExceptionCode.canceled ||
          _hasGoogleSignInConfigurationEvidence(exception))) {
    final description = exception.description?.trim();
    final pluginDetail = description == null || description.isEmpty
        ? ''
        : '\nPlugin detail: $description';
    return '$fallback\n$_googleSignInConfigurationHint$pluginDetail';
  }

  if (exception.code == GoogleSignInExceptionCode.canceled) {
    return fallback;
  }

  final description = exception.description?.trim();
  return description == null || description.isEmpty ? fallback : description;
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
    final shouldReport = shouldReportGoogleSignInException(e);
    if (!shouldReport) {
      return;
    }
    _logGoogleSignInException(e);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_googleSignInFailureMessage(e))));
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
