import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({
    required this.phase,
    required this.isRemoteConnected,
    this.remoteName,
    super.key,
  });

  final String phase;
  final bool isRemoteConnected;
  final String? remoteName;

  @override
  Widget build(BuildContext context) {
    final (Color dotColor, String statusText) = switch (phase) {
      'connected' => (context.colors.success, 'walkie_talkie.connected'.tr()),
      'connecting' => (context.colors.warning, 'walkie_talkie.connecting'.tr()),
      'error' => (context.colors.error, 'walkie_talkie.error'.tr()),
      _ => (context.colors.grey400, 'walkie_talkie.disconnected'.tr()),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: context.spacing.gapMd),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: dotColor,
              ),
            ),
          ],
        ),
        SizedBox(height: context.spacing.gapXs),
        Text(
          isRemoteConnected
              ? 'walkie_talkie.toy_connected'.tr()
              : 'walkie_talkie.waiting_for_toy'.tr(),
          style: TextStyle(
            fontSize: 12,
            color: context.colors.grey400,
          ),
        ),
      ],
    );
  }
}
