import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/google_signin_provider.dart';
import '../widgets/auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Clear any previous auth errors (e.g. from signup screen)
    ref.read(authProvider.notifier).clearError();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(authProvider.notifier).login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController(
      text: _identifierController.text.contains('@')
          ? _identifierController.text.trim()
          : '',
    );

    showDialog<void>(
      context: context,
      builder: (ctx) {
        var isSending = false;

        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text('auth.forgot_password_title'.tr()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('auth.forgot_password_body'.tr()),
                SizedBox(height: context.spacing.sectionTitleBottomMargin),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'auth.forgot_password_email_hint'.tr(),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('common.cancel'.tr()),
              ),
              TextButton(
                onPressed: isSending
                    ? null
                    : () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          return;
                        }

                        setDialogState(() => isSending = true);
                        final success = await ref
                            .read(authProvider.notifier)
                            .requestPasswordReset(email);
                        if (!ctx.mounted) {
                          return;
                        }
                        Navigator.pop(ctx);

                        if (mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'auth.forgot_password_success'.tr()),
                                backgroundColor: context.colors.success,
                              ),
                            );
                            _showResetPasswordDialog();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('auth.forgot_password_error'.tr()),
                                backgroundColor: context.colors.error,
                              ),
                            );
                          }
                        }
                      },
                child: isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('auth.forgot_password_send'.tr()),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResetPasswordDialog() {
    final tokenController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) {
        var isSubmitting = false;
        String? errorText;

        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text('auth.reset_password_title'.tr()),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('auth.reset_password_body'.tr()),
                  SizedBox(height: context.spacing.sectionTitleBottomMargin),
                  TextField(
                    controller: tokenController,
                    decoration: InputDecoration(
                      hintText: 'auth.reset_password_token_hint'.tr(),
                      prefixIcon: const Icon(Icons.key_outlined),
                    ),
                  ),
                  SizedBox(height: context.spacing.paragraphBottomMarginSm),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'auth.reset_password_new_password_hint'.tr(),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                  ),
                  SizedBox(height: context.spacing.paragraphBottomMarginSm),
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'auth.reset_password_confirm_hint'.tr(),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                  ),
                  if (errorText != null) ...[
                    SizedBox(height: context.spacing.paragraphBottomMarginSm),
                    Text(
                      errorText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.colors.error,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('common.cancel'.tr()),
              ),
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final token = tokenController.text.trim();
                        final password = passwordController.text;
                        final confirm = confirmController.text;

                        if (token.isEmpty) {
                          return;
                        }
                        if (password.length < 8) {
                          setDialogState(() {
                            errorText =
                                'auth.reset_password_too_short'.tr();
                          });
                          return;
                        }
                        if (password != confirm) {
                          setDialogState(() {
                            errorText =
                                'auth.reset_password_mismatch'.tr();
                          });
                          return;
                        }

                        setDialogState(() {
                          isSubmitting = true;
                          errorText = null;
                        });

                        final success = await ref
                            .read(authProvider.notifier)
                            .resetPassword(
                                token: token, newPassword: password);
                        if (!ctx.mounted) {
                          return;
                        }
                        Navigator.pop(ctx);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'auth.reset_password_success'.tr()
                                    : 'auth.reset_password_error'.tr(),
                              ),
                              backgroundColor:
                                  success ? context.colors.success : context.colors.error,
                            ),
                          );
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('auth.reset_password_submit'.tr()),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final googleSignIn = ref.read(googleSignInProvider);
      final googleUser = await googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('No ID token received from Google');
      }

      await ref.read(authProvider.notifier).loginWithGoogle(idToken);
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('auth.google_signin_failed_detail'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: context.spacing.pageEdgeInsets,
          child: Form(
            key: _formKey,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      AuthBackButton(onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.home.path);
                        }
                      }),
                      const SizedBox(height: 16),
                      Text(
                        'auth.welcome_back'.tr(),
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: context.colors.textNormal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'auth.sign_in_subtitle_long'.tr(),
                        style: textTheme.titleMedium?.copyWith(
                          color: context.colors.grey400,
                        ),
                      ),
                      SizedBox(height: context.spacing.largePageBottomMargin),
                      if (authState.hasError && !authState.isLoading)
                        AuthErrorBanner(
                          message: authState.error
                              .toString()
                              .replaceFirst('Exception: ', ''),
                        ),
                      SizedBox(height: context.spacing.titleBottomMargin),
                      AuthTextField(
                        controller: _identifierController,
                        label: 'auth.username_or_email'.tr(),
                        hintText: 'auth.username_or_email_hint'.tr(),
                        keyboardType: TextInputType.text,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'auth.username_or_email_required'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: context.spacing.titleBottomMargin),
                      AuthTextField(
                        controller: _passwordController,
                        label: 'auth.password'.tr(),
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixTap: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'auth.password_required'.tr();
                          }
                          if (value.length < 6) {
                            return 'auth.password_short'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: context.spacing.paragraphBottomMarginSm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _showForgotPasswordDialog,
                          child: Text(
                            'auth.forgot_password'.tr(),
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      const Spacer(),
                      SizedBox(height: context.spacing.panelPadding),
                      AuthPrimaryButton(
                        text: 'auth.sign_in'.tr(),
                        isLoading: authState.isLoading,
                        onPressed: _handleEmailLogin,
                      ),
                      SizedBox(height: context.spacing.panelPadding),
                      const AuthOrDivider(),
                      SizedBox(height: context.spacing.panelPadding),
                      AuthGoogleButton(
                        text: 'auth.continue_with_google'.tr(),
                        isLoading: authState.isLoading,
                        onPressed: _handleGoogleSignIn,
                      ),
                      SizedBox(height: context.spacing.paragraphBottomMargin),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${'auth.no_account'.tr()} ',
                            style: textTheme.bodyMedium?.copyWith(
                              color: context.colors.grey400,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.signUp.path),
                            child: Text(
                              'auth.sign_up'.tr(),
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.spacing.panelPadding),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
