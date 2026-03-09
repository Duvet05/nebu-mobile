import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({required this.onPressed, super.key});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onPressed,
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: context.colors.textNormal,
        ),
      );
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller, required this.label, required this.prefixIcon, super.key,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      textCapitalization: textCapitalization,
      style: textTheme.bodyLarge?.copyWith(color: context.colors.textNormal),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: textTheme.bodyMedium?.copyWith(color: context.colors.grey500),
        labelStyle: textTheme.bodyMedium?.copyWith(color: context.colors.grey400),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: context.colors.grey500,
          size: 22,
        ),
        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixTap,
                child: Icon(
                  suffixIcon,
                  color: context.colors.grey500,
                  size: 22,
                ),
              )
            : null,
        filled: true,
        fillColor: context.colors.grey900,
        border: OutlineInputBorder(
          borderRadius: context.radius.panel,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: context.radius.panel,
          borderSide: BorderSide(color: context.colors.grey700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: context.radius.panel,
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: context.radius.panel,
          borderSide: BorderSide(color: context.colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: context.radius.panel,
          borderSide: BorderSide(color: context.colors.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.text, required this.onPressed, super.key,
    this.isLoading = false,
  });
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: context.radius.panel,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.colors.primary100, context.colors.primary],
            ),
            borderRadius: context.radius.panel,
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(context.colors.textOnFilled),
                    ),
                  )
                : Text(
                    text,
                    style: textTheme.titleMedium?.copyWith(
                      color: context.colors.textOnFilled,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({
    required this.text, required this.onPressed, super.key,
    this.isLoading = false,
  });
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: context.radius.panel,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: context.colors.bgPrimary,
            borderRadius: context.radius.panel,
            border: Border.all(color: context.colors.grey700, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/google_logo.png',
                height: 22,
                width: 22,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.g_mobiledata,
                  size: 28,
                  color: context.colors.grey300,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: textTheme.titleMedium?.copyWith(
                  color: context.colors.grey200,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(child: Divider(color: context.colors.grey700, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'auth.or'.tr(),
            style: textTheme.bodySmall?.copyWith(
              color: context.colors.grey500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: context.colors.grey700, thickness: 1)),
      ],
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({required this.message, super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(context.spacing.alertPadding),
      decoration: BoxDecoration(
        color: context.colors.errorBg,
        borderRadius: context.radius.tile,
        border: Border.all(color: context.colors.error),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: context.colors.error, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: context.colors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
