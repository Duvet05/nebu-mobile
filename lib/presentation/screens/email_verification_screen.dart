import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isResending = false;
  bool _resendSuccess = false;
  int _cooldownSeconds = 0;

  Future<void> _handleResend() async {
    if (_isResending || _cooldownSeconds > 0) {
      return;
    }

    final user = ref.read(authProvider).value;
    if (user == null) {
      return;
    }

    setState(() {
      _isResending = true;
      _resendSuccess = false;
    });

    final success = await ref
        .read(authProvider.notifier)
        .resendVerification(user.email);

    if (!mounted) {
      return;
    }

    setState(() {
      _isResending = false;
      _resendSuccess = success;
      if (success) {
        _cooldownSeconds = 60;
      }
    });

    if (success) {
      _startCooldown();
    }
  }

  void _startCooldown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _cooldownSeconds <= 0) {
        return;
      }
      setState(() => _cooldownSeconds--);
      if (_cooldownSeconds > 0) {
        _startCooldown();
      }
    });
  }

  Future<void> _handleLogout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.welcome.path);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;
    final user = ref.watch(authProvider).value;
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: context.spacing.pageEdgeInsets,
          child: Column(
            children: [
              SizedBox(height: context.spacing.largePageBottomMargin),

              // Mail icon
              Container(
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
              Text(
                'auth.verify_email_subtitle'.tr(args: [email]),
                style: textTheme.bodyLarge?.copyWith(
                  color: context.colors.grey400,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.spacing.largePageBottomMargin),

              // Success banner
              if (_resendSuccess) ...[
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

              const Spacer(),

              // Resend button
              AuthPrimaryButton(
                text: _cooldownSeconds > 0
                    ? 'auth.verify_email_resend_countdown'
                        .tr(args: ['$_cooldownSeconds'])
                    : 'auth.verify_email_resend'.tr(),
                isLoading: _isResending,
                onPressed: _cooldownSeconds > 0 ? null : _handleResend,
              ),

              SizedBox(height: context.spacing.paragraphBottomMargin),

              // Logout link
              AuthSwitchLink(
                prompt: 'auth.verify_email_wrong_email'.tr(),
                action: 'auth.verify_email_logout'.tr(),
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
