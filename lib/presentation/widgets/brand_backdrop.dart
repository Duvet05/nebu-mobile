import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class NebuBrandBackdrop extends StatelessWidget {
  const NebuBrandBackdrop({
    required this.child,
    super.key,
    this.backgroundColor,
    this.showBlobs = true,
    this.patternOpacity = 0.12,
  });

  final Widget child;
  final Color? backgroundColor;
  final bool showBlobs;
  final double patternOpacity;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: backgroundColor ?? context.colors.primary,
    child: Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: patternOpacity,
              child: Image.asset(
                'assets/images/decoration-strokes-scattered.png',
                alignment: Alignment.topLeft,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
        ),
        if (showBlobs) ...[
          Positioned(
            top: -72,
            right: -84,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.38,
                child: Image.asset(
                  'assets/images/decoration-blob-teal.png',
                  width: 220,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -72,
            left: -64,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.32,
                child: Image.asset(
                  'assets/images/decoration-blob-yellow.png',
                  width: 190,
                ),
              ),
            ),
          ),
        ],
        child,
      ],
    ),
  );
}
