import 'dart:async';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Animación del ícono (gatito bajando)
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _iconScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    _iconOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Animación del texto "FLOW"
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    _textOpacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    // Iniciar secuencia de animaciones
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    if (!mounted) {
      return;
    }
    await _iconController.forward();

    if (!mounted) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (!mounted) {
      return;
    }
    await _textController.forward();

    if (!mounted) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 600));

    unawaited(_navigateToNextScreen());
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) {
      return;
    }

    final authState = ref.read(authProvider);

    if (authState.value != null) {
      context.go(AppRoutes.home.path);
    } else {
      context.go(AppRoutes.welcome.path);
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.primary,
    body: SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono del gatito animado
            AnimatedBuilder(
              animation: _iconController,
              builder: (context, child) => Opacity(
                opacity: _iconOpacityAnimation.value,
                child: Transform.scale(
                  scale: _iconScaleAnimation.value,
                  child: Icon(
                    Icons.smart_toy,
                    size: 120,
                    color: context.colors.textOnFilled,
                  ),
                ),
              ),
            ),

            SizedBox(height: context.spacing.paragraphBottomMargin),

            // Texto "FLOW" animado
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) => SlideTransition(
                position: _textSlideAnimation,
                child: Opacity(
                  opacity: _textOpacityAnimation.value,
                  child: Text(
                    'splash.app_name'.tr(),
                    style: context.theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.textOnFilled,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(
                          color: context.colors.textNormal.withValues(
                            alpha: 0.25,
                          ),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: context.spacing.paragraphBottomMarginSm),

            // Subtítulo animado
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) => Opacity(
                opacity: _textOpacityAnimation.value,
                child: Text(
                  'splash.powered_by'.tr(),
                  style: context.theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: context.colors.textOnFilled.withValues(alpha: 0.85),
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
