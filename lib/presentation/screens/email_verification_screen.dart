import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/ui_helpers.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({this.email, super.key});

  /// Email passed from login rejection (when user is null in auth state).
  final String? email;

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isResending = false;
  bool _isLoggingOut = false;
  bool _isCheckingStatus = false;
  _ResendStatus _resendStatus = _ResendStatus.idle;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  String get _email =>
      widget.email ?? ref.read(authProvider).value?.email ?? '';

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleResend() async {
    final email = _email;
    if (_isResending || _cooldownSeconds > 0 || email.isEmpty) {
      return;
    }

    setState(() {
      _isResending = true;
      _resendStatus = _ResendStatus.idle;
    });

    bool success;
    try {
      success = await ref.read(authProvider.notifier).resendVerification(email);
    } on Exception {
      success = false;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isResending = false;
      _resendStatus = success ? _ResendStatus.success : _ResendStatus.error;
      if (success) {
        _cooldownSeconds = 60;
      }
    });

    if (success) {
      _startCooldown();
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _cooldownSeconds <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _cooldownSeconds--);
      if (_cooldownSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _handleCheckStatus() async {
    if (_isCheckingStatus) {
      return;
    }
    setState(() => _isCheckingStatus = true);

    final verified = await ref.read(authProvider.notifier).refreshUser();

    if (!mounted) {
      return;
    }

    setState(() => _isCheckingStatus = false);

    if (verified) {
      final user = ref.read(authProvider).value;
      if (user?.emailVerified ?? false) {
        // Router will automatically redirect away from verify screen
        return;
      }
    }

    context.showErrorSnackBar('auth.verify_email_not_yet'.tr());
  }

  Future<void> _handleLogout() async {
    if (_isLoggingOut) {
      return;
    }
    setState(() => _isLoggingOut = true);
    await ref.read(authProvider.notifier).logout();
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.welcome.path);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;
    final email = _email;

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: context.spacing.pageEdgeInsets,
          child: Column(
            children: [
              SizedBox(height: context.spacing.largePageBottomMargin),

              // Mail icon
              ExcludeSemantics(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    size: 48,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
              ),

              SizedBox(height: context.spacing.largePageBottomMargin),

              // Title
              Text(
                'auth.verify_email_title'.tr(),
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: context.colors.textNormal,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.spacing.titleBottomMargin),

              // Subtitle with email
              if (email.isNotEmpty)
                Text(
                  'auth.verify_email_subtitle'.tr(args: [email]),
                  style: textTheme.bodyLarge?.copyWith(
                    color: context.colors.grey400,
                  ),
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  'auth.verify_email_subtitle_no_email'.tr(),
                  style: textTheme.bodyLarge?.copyWith(
                    color: context.colors.grey400,
                  ),
                  textAlign: TextAlign.center,
                ),

              SizedBox(height: context.spacing.largePageBottomMargin),

              // Success banner
              if (_resendStatus == _ResendStatus.success) ...[
                Container(
                  padding: EdgeInsets.all(context.spacing.alertPadding),
                  decoration: BoxDecoration(
                    color: context.colors.successBg,
                    borderRadius: context.radius.tile,
                    border: Border.all(color: context.colors.success),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: context.colors.success,
                        size: 22,
                      ),
                      SizedBox(width: context.spacing.gapLg),
                      Expanded(
                        child: Text(
                          'auth.verify_email_resent'.tr(),
                          style: textTheme.bodyMedium?.copyWith(
                            color: context.colors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.spacing.titleBottomMargin),
              ],

              // Error banner
              if (_resendStatus == _ResendStatus.error) ...[
                AuthErrorBanner(message: 'auth.verify_email_resend_error'.tr()),
                SizedBox(height: context.spacing.titleBottomMargin),
              ],

              const Spacer(),

              // "I've already verified" button
              AuthPrimaryButton(
                text: 'auth.verify_email_check_status'.tr(),
                isLoading: _isCheckingStatus,
                onPressed: _handleCheckStatus,
              ),

              SizedBox(height: context.spacing.titleBottomMargin),

              // Resend button
              TextButton(
                onPressed: _cooldownSeconds > 0 || _isResending
                    ? null
                    : _handleResend,
                child: _isResending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.theme.colorScheme.primary,
                        ),
                      )
                    : Text(
                        _cooldownSeconds > 0
                            ? 'auth.verify_email_resend_countdown'.tr(
                                args: ['$_cooldownSeconds'],
                              )
                            : 'auth.verify_email_resend'.tr(),
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              SizedBox(height: context.spacing.paragraphBottomMargin),

              // Logout link
              AuthSwitchLink(
                prompt: 'auth.verify_email_wrong_email'.tr(),
                action: 'auth.verify_email_logout'.tr(),
                enabled: !_isLoggingOut,
                onTap: _handleLogout,
              ),

              SizedBox(height: context.spacing.panelPadding),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ResendStatus { idle, success, error }
