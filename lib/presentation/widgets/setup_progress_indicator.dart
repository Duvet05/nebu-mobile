import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SetupProgressIndicator extends StatelessWidget {
  const SetupProgressIndicator({
    required this.currentStep,
    required this.totalSteps,
    super.key,
  });
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'setup_progress.step_of'.tr(
                args: ['$currentStep', '$totalSteps'],
              ),
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.grey400,
              ),
            ),
          ],
        ),
        SizedBox(height: context.spacing.titleBottomMarginSm),
        ClipRRect(
          borderRadius: context.radius.tile,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: context.colors.grey800,
            valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
          ),
        ),
      ],
    );
  }
}
