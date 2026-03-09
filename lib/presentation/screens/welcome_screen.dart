import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.primary100,
              context.colors.primary,
              context.colors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Título
                Text(
                  'welcome.title'.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: context.colors.textOnFilled,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: context.spacing.sectionTitleBottomMargin),

                // Subtítulo
                Text(
                  'welcome.subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: context.colors.textOnFilled.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),

                const Spacer(flex: 3),

                // Botones
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sign In - Botón principal
                    _PrimaryButton(
                      text: 'welcome.sign_in'.tr(),
                      onPressed: () => context.push(AppRoutes.login.path),
                    ),

                    SizedBox(height: context.spacing.sectionTitleBottomMargin),

                    // Sign Up - Botón secundario
                    _SecondaryButton(
                      text: 'welcome.sign_up'.tr(),
                      onPressed: () => context.push(AppRoutes.signUp.path),
                    ),
                  ],
                ),

                SizedBox(height: context.spacing.paragraphBottomMargin),

                // Continuar sin cuenta
                GestureDetector(
                  onTap: () => context.push(AppRoutes.connectionSetup.path),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'welcome.continue_without_account'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.colors.textOnFilled.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: context.spacing.panelPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Botón primario con efecto glass
class _PrimaryButton extends StatelessWidget {

  const _PrimaryButton({
    required this.text,
    required this.onPressed,
  });
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: context.radius.panel,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: context.colors.bgPrimary,
            borderRadius: context.radius.panel,
            boxShadow: [
              BoxShadow(
                color: context.colors.textNormal.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: context.colors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
}

// Botón secundario con borde
class _SecondaryButton extends StatelessWidget {

  const _SecondaryButton({
    required this.text,
    required this.onPressed,
  });
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: context.radius.panel,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: context.colors.textOnFilled.withValues(alpha: 0.1),
            borderRadius: context.radius.panel,
            border: Border.all(
              color: context.colors.textOnFilled.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: context.colors.textOnFilled.withValues(alpha: 0.95),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
}
