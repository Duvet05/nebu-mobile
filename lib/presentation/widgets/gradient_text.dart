import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradientColors,
    this.textAlign,
  });
  final String text;
  final TextStyle? style;
  final List<Color>? gradientColors;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => ShaderMask(
    shaderCallback: (bounds) => LinearGradient(
      colors:
          gradientColors ?? [context.colors.primary, context.colors.secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
    child: Text(
      text,
      style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      textAlign: textAlign,
    ),
  );
}
