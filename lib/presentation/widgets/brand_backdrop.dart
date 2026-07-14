import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class NebuBrandBackdrop extends StatelessWidget {
  const NebuBrandBackdrop({
    required this.child,
    super.key,
    this.backgroundColor,
    this.patternOpacity = 0.16,
  });

  final Widget child;
  final Color? backgroundColor;
  final double patternOpacity;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: backgroundColor ?? context.colors.primary,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final isShort = constraints.maxHeight < 480;

        return Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: isWide ? -35 : -55,
                    left: isWide ? -35 : -70,
                    child: Opacity(
                      opacity: isWide ? 0.36 : 0.30,
                      child: Image.asset(
                        'assets/images/decoration-blob-yellow.png',
                        width: isWide ? 300 : 220,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                  if (!isShort)
                    Positioned(
                      right: isWide ? -140 : -190,
                      bottom: constraints.maxHeight * 0.23,
                      child: Opacity(
                        opacity: isWide ? 0.30 : 0.26,
                        child: Image.asset(
                          'assets/images/decoration-blob-teal.png',
                          width: isWide ? 520 : 420,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ),
                  Positioned(
                    top: constraints.maxHeight * 0.38,
                    left: isWide ? 48 : -25,
                    child: Image.asset(
                      'assets/images/decoration-strokes-scattered.png',
                      width: isWide ? 177 : 145,
                      color: Colors.white.withValues(alpha: patternOpacity),
                      colorBlendMode: BlendMode.srcIn,
                      excludeFromSemantics: true,
                    ),
                  ),
                ],
              ),
            ),
            child,
          ],
        );
      },
    ),
  );
}
