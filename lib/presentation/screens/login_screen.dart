import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/validation_rules.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
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

  Future<void> _handleGoogleSignIn() async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        throw Exception('auth.google_no_id_token'.tr());
      }
      await ref.read(authProvider.notifier).loginWithGoogle(idToken);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.description ?? 'auth.google_signin_failed_detail'.tr(),
            ),
          ),
        );
      }
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
    final textTheme = context.theme.textTheme;

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
                        onPressed: () => context.canPop()
                            ? context.pop()
                            : context.go(AppRoutes.home.path),
                      ),
                      SizedBox(height: context.spacing.alertPadding),
                      Text(
                        'auth.welcome_back'.tr(),
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
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
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'auth.username_or_email_required'.tr()
                            : null,
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
                        onSuffixTap: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        validator: (v) =>
                            ValidationRules.validatePassword(v)?.tr(),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showForgotPasswordDialog(
                            context,
                            ref,
                            _identifierController.text,
                          ),
                          child: Text(
                            'auth.forgot_password'.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: context.theme.colorScheme.primary,
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
                      _SignUpLink(isLoading: authState.isLoading),
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

class _SignUpLink extends StatelessWidget {
  const _SignUpLink({required this.isLoading});
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        '${'auth.no_account'.tr()} ',
        style: TextStyle(color: context.colors.grey400),
      ),
      GestureDetector(
        onTap: isLoading ? null : () => context.push(AppRoutes.signUp.path),
        child: Text(
          'auth.sign_up'.tr(),
          style: TextStyle(
            color: isLoading
                ? context.colors.grey500
                : context.theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

void _showForgotPasswordDialog(
  BuildContext context,
  WidgetRef ref,
  String initialEmail,
) {
  final emailController = TextEditingController(text: initialEmail);
  var isLoading = false;

  showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: Text('auth.forgot_password_title'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'auth.forgot_password_body'.tr(),
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            SizedBox(height: ctx.spacing.panelPadding),
            AuthTextField(
              controller: emailController,
              label: 'auth.email'.tr(),
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: isLoading
                ? null
                : () async {
                    final email = emailController.text.trim();
                    if (email.isEmpty) {
                      return;
                    }

                    setDialogState(() => isLoading = true);

                    try {
                      final success = await ref
                          .read(authProvider.notifier)
                          .requestPasswordReset(email);

                      if (!ctx.mounted) {
                        return;
                      }
                      Navigator.pop(ctx);

                      if (success) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('auth.forgot_password_success'.tr()),
                          ),
                        );
                        _showResetPasswordDialog(ctx, ref, email);
                      } else {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('auth.forgot_password_error'.tr()),
                          ),
                        );
                      }
                    } on Exception {
                      if (ctx.mounted) {
                        setDialogState(() => isLoading = false);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('auth.forgot_password_error'.tr()),
                          ),
                        );
                      }
                    }
                  },
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('auth.forgot_password_send'.tr()),
          ),
        ],
      ),
    ),
  );
}

void _showResetPasswordDialog(
  BuildContext context,
  WidgetRef ref,
  String email,
) {
  final tokenController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  var isLoading = false;
  String? errorText;

  showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: Text('auth.reset_password_title'.tr()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'auth.reset_password_body'.tr(),
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              SizedBox(height: ctx.spacing.panelPadding),
              AuthTextField(
                controller: tokenController,
                label: 'auth.reset_password_token_hint'.tr(),
                prefixIcon: Icons.key_outlined,
              ),
              SizedBox(height: ctx.spacing.sectionTitleBottomMargin),
              AuthTextField(
                controller: passwordController,
                label: 'auth.reset_password_new_password_hint'.tr(),
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
              ),
              SizedBox(height: ctx.spacing.sectionTitleBottomMargin),
              AuthTextField(
                controller: confirmController,
                label: 'auth.reset_password_confirm_hint'.tr(),
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
              ),
              if (errorText != null) ...[
                SizedBox(height: ctx.spacing.labelBottomMargin),
                Text(
                  errorText!,
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: Theme.of(ctx).colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: isLoading
                ? null
                : () async {
                    final token = tokenController.text.trim();
                    final password = passwordController.text;
                    final confirm = confirmController.text;

                    if (token.isEmpty || password.isEmpty) {
                      return;
                    }

                    final passwordError =
                        ValidationRules.validatePassword(password);
                    if (passwordError != null) {
                      setDialogState(() {
                        errorText = passwordError.tr();
                      });
                      return;
                    }

                    if (password != confirm) {
                      setDialogState(() {
                        errorText = 'auth.reset_password_mismatch'.tr();
                      });
                      return;
                    }

                    setDialogState(() {
                      isLoading = true;
                      errorText = null;
                    });

                    try {
                      final success = await ref
                          .read(authProvider.notifier)
                          .resetPassword(token: token, newPassword: password);

                      if (!ctx.mounted) {
                        return;
                      }

                      if (success) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('auth.reset_password_success'.tr()),
                          ),
                        );
                      } else {
                        setDialogState(() {
                          isLoading = false;
                          errorText = 'auth.reset_password_error'.tr();
                        });
                      }
                    } on Exception {
                      if (ctx.mounted) {
                        setDialogState(() {
                          isLoading = false;
                          errorText = 'auth.reset_password_error'.tr();
                        });
                      }
                    }
                  },
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('auth.reset_password_submit'.tr()),
          ),
        ],
      ),
    ),
  );
}
