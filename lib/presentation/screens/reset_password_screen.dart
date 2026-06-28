import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/validation_rules.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({this.token, super.key});

  final String? token;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tokenController;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorText;

  bool get _hasLinkToken => widget.token?.trim().isNotEmpty ?? false;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.token?.trim() ?? '');
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() => _errorText = 'auth.reset_password_token_required'.tr());
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .resetPassword(token: token, newPassword: _passwordController.text);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('auth.reset_password_success'.tr())),
      );
      context.go(AppRoutes.login.path);
    } on Exception catch (e) {
      if (!mounted) {
        return;
      }
      final message = e.toString();
      setState(() {
        _isLoading = false;
        _errorText = message.contains('.')
            ? message.tr()
            : 'auth.reset_password_error'.tr();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: context.constrainedPageEdgeInsets,
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
                            : context.go(AppRoutes.login.path),
                      ),
                      SizedBox(height: context.spacing.alertPadding),
                      Text(
                        'auth.reset_password_title'.tr(),
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.textNormal,
                        ),
                      ),
                      SizedBox(height: context.spacing.labelBottomMargin),
                      Text(
                        (_hasLinkToken
                                ? 'auth.reset_password_body_link'
                                : 'auth.reset_password_body')
                            .tr(),
                        style: textTheme.titleMedium?.copyWith(
                          color: context.colors.grey400,
                        ),
                      ),
                      SizedBox(height: context.spacing.largePageBottomMargin),
                      if (_errorText != null) ...[
                        AuthErrorBanner(message: _errorText!),
                        SizedBox(height: context.spacing.titleBottomMargin),
                      ],
                      if (!_hasLinkToken) ...[
                        AuthTextField(
                          controller: _tokenController,
                          label: 'auth.reset_password_token_hint'.tr(),
                          prefixIcon: Icons.key_outlined,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'auth.reset_password_token_required'.tr()
                              : null,
                        ),
                        SizedBox(height: context.spacing.titleBottomMargin),
                      ],
                      AuthTextField(
                        controller: _passwordController,
                        label: 'auth.reset_password_new_password_hint'.tr(),
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixTap: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        validator: (value) =>
                            ValidationRules.validatePassword(value)?.tr(),
                      ),
                      SizedBox(height: context.spacing.titleBottomMargin),
                      AuthTextField(
                        controller: _confirmController,
                        label: 'auth.reset_password_confirm_hint'.tr(),
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixTap: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'auth.confirm_password_required'.tr();
                          }
                          if (value != _passwordController.text) {
                            return 'auth.reset_password_mismatch'.tr();
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
                      AuthPrimaryButton(
                        text: 'auth.reset_password_submit'.tr(),
                        isLoading: _isLoading,
                        onPressed: _handleResetPassword,
                      ),
                      SizedBox(height: context.spacing.paragraphBottomMargin),
                      AuthSwitchLink(
                        prompt: 'auth.already_have_account'.tr(),
                        action: 'auth.sign_in'.tr(),
                        enabled: !_isLoading,
                        onTap: () => context.go(AppRoutes.login.path),
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
