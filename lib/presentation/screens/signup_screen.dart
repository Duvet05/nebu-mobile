import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/google_signin_provider.dart';
import '../widgets/auth_widgets.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Clear any previous auth errors (e.g. from login screen)
    ref.read(authProvider.notifier).clearError();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(authProvider.notifier).register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );
  }

  Future<void> _handleGoogleSignUp() async {
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
          SnackBar(content: Text('auth.google_signup_failed_detail'.tr())),
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
                        'auth.create_account'.tr(),
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: context.colors.textNormal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'auth.create_account_subtitle'.tr(),
                        style: textTheme.titleMedium?.copyWith(
                          color: context.colors.grey400,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Error message
                      if (authState.hasError && !authState.isLoading) ...[
                        AuthErrorBanner(
                          message: authState.error
                              .toString()
                              .replaceFirst('Exception: ', ''),
                        ),
                        SizedBox(height: context.spacing.titleBottomMargin),
                      ],

                      // First name
                      AuthTextField(
                        controller: _firstNameController,
                        label: 'auth.first_name'.tr(),
                        prefixIcon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'auth.required'.tr();
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: context.spacing.titleBottomMargin),

                      // Last name
                      AuthTextField(
                        controller: _lastNameController,
                        label: 'auth.last_name'.tr(),
                        prefixIcon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'auth.required'.tr();
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: context.spacing.titleBottomMargin),

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
                          if (!value.contains('@')) {
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
                          if (value == null || value.isEmpty) {
                            return 'auth.password_required'.tr();
                          }
                          if (value.length < 8) {
                            return 'auth.password_short'.tr();
                          }
                          return null;
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
                          setState(() =>
                              _obscureConfirmPassword = !_obscureConfirmPassword);
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

                      SizedBox(height: context.spacing.panelPadding),

                      // Divider
                      const AuthOrDivider(),

                      SizedBox(height: context.spacing.panelPadding),

                      // Google button
                      AuthGoogleButton(
                        text: 'auth.continue_with_google'.tr(),
                        isLoading: authState.isLoading,
                        onPressed: _handleGoogleSignUp,
                      ),

                      SizedBox(height: context.spacing.paragraphBottomMargin),

                      // Sign in link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${'auth.already_have_account'.tr()} ",
                            style: textTheme.bodyMedium?.copyWith(
                              color: context.colors.grey400,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoutes.login.path);
                              }
                            },
                            child: Text(
                              'auth.sign_in'.tr(),
                              style: textTheme.bodyMedium?.copyWith(
                                color: context.colors.primary,
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
