import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Nebu's lightweight loading treatment, ported from the three-dot loader
/// used by the web frontend.
class NebuDotsLoader extends StatefulWidget {
  const NebuDotsLoader({
    super.key,
    this.color,
    this.dotSize = 8,
    this.gap = 8,
    this.semanticLabel,
  });

  final Color? color;
  final double dotSize;
  final double gap;
  final String? semanticLabel;

  @override
  State<NebuDotsLoader> createState() => _NebuDotsLoaderState();
}

class _NebuDotsLoaderState extends State<NebuDotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return Semantics(
      label: widget.semanticLabel,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final phase = (_controller.value - (index * 0.12)) % 1;
              final bounce = (math.sin(phase * math.pi * 2) + 1) / 2;

              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : widget.gap),
                child: Transform.translate(
                  offset: Offset(0, -3 * bounce),
                  child: Opacity(
                    opacity: 0.45 + (0.55 * bounce),
                    child: Container(
                      key: ValueKey('nebu-loader-dot-$index'),
                      width: widget.dotSize,
                      height: widget.dotSize,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
