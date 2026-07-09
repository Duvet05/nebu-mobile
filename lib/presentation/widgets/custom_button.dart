import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum ButtonVariant { primary, secondary, outline, text, danger, dangerOutline }

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.text,
    super.key,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height,
    this.borderRadius,
  });
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final effectiveRadius = borderRadius ?? context.radius.button;
    final filledForeground = variant == ButtonVariant.danger
        ? Colors.white
        : context.colors.textOnFilled;

    final spinnerColor = switch (variant) {
      ButtonVariant.danger || ButtonVariant.dangerOutline =>
        variant == ButtonVariant.danger ? Colors.white : context.colors.error,
      _ => filledForeground,
    };

    final Widget buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
            ),
          )
        else ...[
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Flexible(child: Text(text, textAlign: TextAlign.center)),
        ],
      ],
    );

    final buttonWidth = width ?? (isFullWidth ? double.infinity : null);
    final buttonHeight = height ?? 56.0;

    switch (variant) {
      case ButtonVariant.primary:
        return Container(
          width: buttonWidth,
          height: buttonHeight,
          decoration: BoxDecoration(
            color: context.colors.primary,
            borderRadius: effectiveRadius,
            boxShadow: onPressed != null && !isLoading
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: filledForeground,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.gapXxl,
                vertical: context.spacing.gapXl,
              ),
            ),
            child: buttonChild,
          ),
        );

      case ButtonVariant.secondary:
        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.surface,
              foregroundColor: context.colors.textNormal,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.gapXxl,
                vertical: context.spacing.gapXl,
              ),
            ),
            child: buttonChild,
          ),
        );

      case ButtonVariant.outline:
        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.textNormal,
              side: BorderSide(color: colorScheme.primary, width: 2),
              shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.gapXxl,
                vertical: context.spacing.gapXl,
              ),
            ),
            child: buttonChild,
          ),
        );

      case ButtonVariant.text:
        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: context.colors.textNormal,
              shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.gapXl,
                vertical: context.spacing.gapMd,
              ),
            ),
            child: buttonChild,
          ),
        );

      case ButtonVariant.danger:
        return Container(
          width: buttonWidth,
          height: buttonHeight,
          decoration: BoxDecoration(
            color: context.colors.error,
            borderRadius: effectiveRadius,
            boxShadow: onPressed != null && !isLoading
                ? [
                    BoxShadow(
                      color: context.colors.error.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: filledForeground,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.gapXxl,
                vertical: context.spacing.gapXl,
              ),
            ),
            child: buttonChild,
          ),
        );

      case ButtonVariant.dangerOutline:
        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.error,
              side: BorderSide(color: context.colors.error),
              shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.gapXxl,
                vertical: context.spacing.gapXl,
              ),
            ),
            child: buttonChild,
          ),
        );
    }
  }
}
