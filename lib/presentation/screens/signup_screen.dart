import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/validation_rules.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/google_auth_helper.dart';
import '../../data/models/user.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _authError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(authProvider.notifier)
        .register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final textTheme = context.theme.textTheme;

    ref.listen<AsyncValue<User?>>(authProvider, (prev, next) {
      if (!mounted) {
        return;
      }
      setState(() {
        _authError = next.hasError && !next.isLoading
            ? next.error.toString().replaceFirst('Exception: ', '')
            : null;
      });
    });

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
                        'auth.create_account'.tr(),
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: context.colors.textNormal,
                        ),
                      ),
                      SizedBox(height: context.spacing.labelBottomMargin),
                      Text(
                        'auth.create_account_subtitle'.tr(),
                        style: textTheme.titleMedium?.copyWith(
                          color: context.colors.grey400,
                        ),
                      ),

                      SizedBox(height: context.spacing.largePageBottomMargin),

                      // Error message
                      if (_authError != null) ...[
                        AuthErrorBanner(message: _authError!),
                        SizedBox(height: context.spacing.titleBottomMargin),
                      ],

                      // Email field
                      AuthTextField(
                        controller: _emailController,
                        label: 'auth.email'.tr(),
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline_rounded,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'auth.email_required'.tr();
                          }
                          if (!RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(value)) {
                            return 'auth.email_invalid'.tr();
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: context.spacing.titleBottomMargin),

                      // Password field
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
                          final error = ValidationRules.validatePassword(value);
                          return error?.tr();
                        },
                      ),

                      SizedBox(height: context.spacing.titleBottomMargin),

                      // Confirm Password field
                      AuthTextField(
                        controller: _confirmPasswordController,
                        label: 'auth.confirm_password'.tr(),
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixTap: () {
                          setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          );
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'auth.confirm_password_required'.tr();
                          }
                          if (value != _passwordController.text) {
                            return 'auth.passwords_dont_match'.tr();
                          }
                          return null;
                        },
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

                      // Sign up button
                      AuthPrimaryButton(
                        text: 'auth.create_account'.tr(),
                        isLoading: authState.isLoading,
                        onPressed: _handleEmailSignUp,
                      ),

                      SizedBox(height: context.spacing.paragraphBottomMargin),

                      // Sign in link
                      AuthSwitchLink(
                        prompt: 'auth.already_have_account'.tr(),
                        action: 'auth.sign_in'.tr(),
                        enabled: !authState.isLoading,
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.login.path);
                          }
                        },
                      ),

                      SizedBox(height: context.spacing.panelPadding),

                      // Divider
                      const AuthOrDivider(),

                      SizedBox(height: context.spacing.panelPadding),

                      // Google button
                      AuthGoogleButton(
                        text: 'auth.continue_with_google'.tr(),
                        isLoading: authState.isLoading,
                        onPressed: () => handleGoogleAuth(context, ref),
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
