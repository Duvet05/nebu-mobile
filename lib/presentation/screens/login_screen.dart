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
  bool _isGoogleSigningIn = false;

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

    await ref
        .read(authProvider.notifier)
        .login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );
  }

  Future<void> _showForgotPasswordDialog() async {
    final success = await showDialog<bool>(
      context: context,
      builder: (_) => _ForgotPasswordDialog(
        initialEmail: _identifierController.text.contains('@')
            ? _identifierController.text.trim()
            : '',
      ),
    );

    if ((success ?? false) && mounted) {
      await showDialog<void>(
        context: context,
        builder: (_) => const _ResetPasswordDialog(),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleSigningIn = true);
    try {
      final googleSignIn = ref.read(googleSignInProvider);
      final googleUser = await googleSignIn.authenticate();
      if (!mounted) {
        return;
      }

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
    } finally {
      if (mounted) {
        setState(() => _isGoogleSigningIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final textTheme = context.theme.textTheme;
    final colorScheme = context.theme.colorScheme;

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
                      SizedBox(height: context.spacing.labelBottomMargin),
                      AuthBackButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.home.path);
                          }
                        },
                      ),
                      SizedBox(height: context.spacing.alertPadding),
                      Text(
                        'auth.welcome_back'.tr(),
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: context.colors.textNormal,
                        ),
                      ),
                      SizedBox(height: context.spacing.labelBottomMargin),
                      Text(
                        'auth.sign_in_subtitle_long'.tr(),
                        style: textTheme.titleMedium?.copyWith(
                          color: context.colors.grey400,
                        ),
                      ),
                      SizedBox(height: context.spacing.largePageBottomMargin),
                      if (authState.hasError && !authState.isLoading)
                        AuthErrorBanner(
                          message: authState.error.toString().replaceFirst(
                            'Exception: ',
                            '',
                          ),
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
                        onPressed: _isGoogleSigningIn
                            ? null
                            : _handleEmailLogin,
                      ),
                      SizedBox(height: context.spacing.panelPadding),
                      const AuthOrDivider(),
                      SizedBox(height: context.spacing.panelPadding),
                      AuthGoogleButton(
                        text: 'auth.continue_with_google'.tr(),
                        isLoading: _isGoogleSigningIn || authState.isLoading,
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
                            onTap: authState.isLoading || _isGoogleSigningIn
                                ? null
                                : () => context.push(AppRoutes.signUp.path),
                            child: Text(
                              'auth.sign_up'.tr(),
                              style: textTheme.bodyMedium?.copyWith(
                                color: authState.isLoading || _isGoogleSigningIn
                                    ? context.colors.grey500
                                    : colorScheme.primary,
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

// ─── Forgot Password Dialog ───

class _ForgotPasswordDialog extends ConsumerStatefulWidget {
  const _ForgotPasswordDialog({required this.initialEmail});
  final String initialEmail;

  @override
  ConsumerState<_ForgotPasswordDialog> createState() =>
      _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<_ForgotPasswordDialog> {
  late final TextEditingController _emailController;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) return;

    setState(() => _isSending = true);
    final success = await ref
        .read(authProvider.notifier)
        .requestPasswordReset(email);
    if (!mounted) return;

    Navigator.pop(context, success);

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'auth.forgot_password_success'.tr()
              : 'auth.forgot_password_error'.tr(),
        ),
        backgroundColor: success
            ? context.colors.success
            : context.colors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('auth.forgot_password_title'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('auth.forgot_password_body'.tr()),
          SizedBox(height: context.spacing.sectionTitleBottomMargin),
          TextField(
            controller: _emailController,
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
          onPressed: () => Navigator.pop(context),
          child: Text('common.cancel'.tr()),
        ),
        TextButton(
          onPressed: _isSending ? null : _submit,
          child: _isSending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('auth.forgot_password_send'.tr()),
        ),
      ],
    );
  }
}

// ─── Reset Password Dialog ───

class _ResetPasswordDialog extends ConsumerStatefulWidget {
  const _ResetPasswordDialog();

  @override
  ConsumerState<_ResetPasswordDialog> createState() =>
      _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends ConsumerState<_ResetPasswordDialog> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final token = _tokenController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (token.isEmpty) return;
    if (password.length < 8) {
      setState(() => _errorText = 'auth.reset_password_too_short'.tr());
      return;
    }
    if (password != confirm) {
      setState(() => _errorText = 'auth.reset_password_mismatch'.tr());
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final success = await ref
        .read(authProvider.notifier)
        .resetPassword(token: token, newPassword: password);
    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'auth.reset_password_success'.tr()
              : 'auth.reset_password_error'.tr(),
        ),
        backgroundColor: success
            ? context.colors.success
            : context.colors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('auth.reset_password_title'.tr()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('auth.reset_password_body'.tr()),
            SizedBox(height: context.spacing.sectionTitleBottomMargin),
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                hintText: 'auth.reset_password_token_hint'.tr(),
                prefixIcon: const Icon(Icons.key_outlined),
              ),
            ),
            SizedBox(height: context.spacing.paragraphBottomMarginSm),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'auth.reset_password_new_password_hint'.tr(),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            SizedBox(height: context.spacing.paragraphBottomMarginSm),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'auth.reset_password_confirm_hint'.tr(),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            if (_errorText != null) ...[
              SizedBox(height: context.spacing.paragraphBottomMarginSm),
              Text(
                _errorText!,
                style: context.theme.textTheme.bodySmall?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('common.cancel'.tr()),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('auth.reset_password_submit'.tr()),
        ),
      ],
    );
  }
}
