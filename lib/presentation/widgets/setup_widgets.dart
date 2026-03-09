import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class SetupBackButton extends StatelessWidget {
  const SetupBackButton({this.previousRoute, super.key});

  final String? previousRoute;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return GestureDetector(
      onTap: () {
        final route = previousRoute;
        if (route != null) {
          context.go(route);
        } else {
          context.pop();
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: context.radius.tile,
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class SetupStepIndicator extends StatelessWidget {
  const SetupStepIndicator({
    required this.current, required this.total, super.key,
  });
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(total, (index) {
          final isActive = index < current;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? context.colors.primary
                  : context.colors.primary.withValues(alpha: 0.2),
              borderRadius: context.radius.checkbox,
            ),
          );
        }),
      );
}

class SetupHeader extends StatelessWidget {
  const SetupHeader({
    required this.currentStep, required this.totalSteps, super.key,
    this.previousRoute,
  });
  final int currentStep;
  final int totalSteps;
  final String? previousRoute;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
        SetupBackButton(previousRoute: previousRoute),
        const Spacer(),
            SetupStepIndicator(current: currentStep, total: totalSteps),
            const Spacer(),
            const SizedBox(width: 44),
          ],
        ),
      );
}

class SetupPrimaryButton extends StatelessWidget {
  const SetupPrimaryButton({
    required this.text, required this.onPressed, super.key,
    this.isEnabled = true,
    this.isLoading = false,
  });
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = isEnabled && !isLoading;

    return GestureDetector(
      onTap: effectiveEnabled ? onPressed : null,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: effectiveEnabled
              ? LinearGradient(
                  colors: [
                    context.colors.primary100,
                    context.colors.primary,
                  ],
                ) null,
          color: effectiveEnabled
              ? ? null
              : context.theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5),
          borderRadius: context.radius.panel,
          boxShadow: effectiveEnabled
              ? [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.colors.textOnFilled,
                    ),
                  ),
                )
              : Text(
                  text,
            style: context.theme.textTheme.titleMedium?.copyWith(
                        color: effectiveEnabled
                            ? context.colors.textOnFilled
                            : context.theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
        ),
      ),
    );
  }
}

class SetupSkipButton extends StatelessWidget {
  const SetupSkipButton({required this.onTap, super.key});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'setup.connection.skip_setup'.tr(),
            style: context.theme.textTheme.bodyMedium?.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      );
}
