import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PushToTalkButton extends StatefulWidget {
  const PushToTalkButton({
    required this.onTalkStart,
    required this.onTalkEnd,
    required this.isTalking,
    required this.isEnabled,
    super.key,
  });

  final VoidCallback onTalkStart;
  final VoidCallback onTalkEnd;
  final bool isTalking;
  final bool isEnabled;

  @override
  State<PushToTalkButton> createState() => _PushToTalkButtonState();
}

class _PushToTalkButtonState extends State<PushToTalkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(PushToTalkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTalking && !oldWidget.isTalking) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isTalking && oldWidget.isTalking) {
      _pulseController
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor;
    final Color iconColor;

    if (!widget.isEnabled) {
      buttonColor = context.colors.grey700;
      iconColor = context.colors.grey500;
    } else if (widget.isTalking) {
      buttonColor = context.colors.primary;
      iconColor = context.colors.textOnFilled;
    } else {
      buttonColor = context.colors.grey800;
      iconColor = context.colors.primary;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: widget.isEnabled ? (_) => widget.onTalkStart() : null,
          onTapUp: widget.isEnabled ? (_) => widget.onTalkEnd() : null,
          onTapCancel: widget.isEnabled ? widget.onTalkEnd : null,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final scale = widget.isTalking ? _pulseAnimation.value : 1.0;
              return Transform.scale(
                scale: scale,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: buttonColor,
                    shape: BoxShape.circle,
                    boxShadow: widget.isTalking
                        ? [
                            BoxShadow(
                              color: context.colors.primary.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: context.colors.textNormal.withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                  ),
                  child: Icon(
                    widget.isTalking ? Icons.mic : Icons.mic_none,
                    size: 48,
                    color: iconColor,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: context.spacing.sectionTitleBottomMargin),
        Text(
          widget.isTalking
              ? 'walkie_talkie.talking'.tr()
              : 'walkie_talkie.hold_to_talk'.tr(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: widget.isTalking
                ? context.colors.primary
                : context.colors.grey400,
          ),
        ),
      ],
    );
  }
}
