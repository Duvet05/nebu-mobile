import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/brand_backdrop.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final mascotHeight = MediaQuery.sizeOf(context).height < 700
        ? 132.0
        : 168.0;

    return Scaffold(
      body: NebuBrandBackdrop(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.panelPadding,
            ),
            child: Column(
              children: [
                const Spacer(),

                Image.asset(
                  'assets/images/renders/nebu-dino-render.png',
                  height: mascotHeight,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.smart_toy,
                    size: mascotHeight * 0.58,
                    color: AppColors.flowInk,
                  ),
                ),

                SizedBox(height: context.spacing.alertPadding),

                // Título
                Text(
                  'welcome.title'.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.flowInk,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: context.spacing.sectionTitleBottomMargin),

                // Subtítulo
                Text(
                  'welcome.subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.flowInk.withValues(alpha: 0.72),
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
                TextButton(
                  onPressed: () => context.push(AppRoutes.connectionSetup.path),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    foregroundColor: AppColors.flowInk,
                  ),
                  child: Text(
                    'welcome.continue_without_account'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.flowInk.withValues(alpha: 0.68),
                      fontWeight: FontWeight.w500,
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
  const _PrimaryButton({required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: Semantics(
      button: true,
      label: text,
      child: InkWell(
        onTap: onPressed,
        borderRadius: context.radius.panel,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: context.colors.bgPrimary,
            borderRadius: context.radius.panel,
            border: Border.all(
              color: AppColors.flowInk.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.flowInk.withValues(alpha: 0.16),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: context.textTheme.bodyLarge?.copyWith(
                color: AppColors.flowInk,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// Botón secundario con borde
class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: Semantics(
      button: true,
      label: text,
      child: InkWell(
        onTap: onPressed,
        borderRadius: context.radius.panel,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: context.radius.panel,
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.18),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: context.textTheme.bodyLarge?.copyWith(
                color: AppColors.flowInk,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
