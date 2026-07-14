import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/brand_backdrop.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      body: NebuBrandBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showArtwork = constraints.maxHeight >= 480;
              final artworkHeight = (constraints.maxHeight * 0.45 - 100).clamp(
                96.0,
                320.0,
              );

              return SingleChildScrollView(
                padding: context.constrainedPageEdgeInsets,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: context.spacing.gapLg),
                        child: Column(
                          children: [
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
                            SizedBox(
                              height: context.spacing.sectionTitleBottomMargin,
                            ),
                            Text(
                              'welcome.subtitle'.tr(),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: context.colors.textOnFilled.withValues(
                                  alpha: 0.8,
                                ),
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showArtwork)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: context.spacing.gapMd,
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/dino.svg',
                            width: 280,
                            height: artworkHeight,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                            excludeFromSemantics: true,
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: context.spacing.panelPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _PrimaryButton(
                              text: 'welcome.sign_in'.tr(),
                              onPressed: () =>
                                  context.push(AppRoutes.login.path),
                            ),
                            SizedBox(
                              height: context.spacing.sectionTitleBottomMargin,
                            ),
                            _SecondaryButton(
                              text: 'welcome.sign_up'.tr(),
                              onPressed: () =>
                                  context.push(AppRoutes.signUp.path),
                            ),
                            SizedBox(
                              height: context.spacing.paragraphBottomMargin,
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.push(AppRoutes.connectionSetup.path),
                              style: TextButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                foregroundColor: context.colors.textOnFilled,
                              ),
                              child: Text(
                                'welcome.continue_without_account'.tr(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: context.colors.textOnFilled.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
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
            ).colorScheme.onPrimary.withValues(alpha: 0.1),
            borderRadius: context.radius.panel,
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onPrimary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.textOnFilled.withValues(alpha: 0.95),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
