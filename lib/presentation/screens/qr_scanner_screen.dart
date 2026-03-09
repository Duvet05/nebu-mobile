import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';

import '../../core/theme/app_colors.dart';
import '../providers/qr_scanner_provider.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final notifier = ref.read(qrScannerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('qr_scanner.title'.tr())),
      body: Stack(
        children: [
          QRCodeDartScanView(
            onCapture: (result) {
              notifier.handleQRCode(result.text, context);
            },
          ),
          _buildScannerOverlay(),
          _buildInstructions(theme),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() => Center(
    child: Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.primary, width: 3),
        borderRadius: context.radius.bottomSheet,
      ),
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, child: _buildCorner(true, true)),
          Positioned(top: 0, right: 0, child: _buildCorner(true, false)),
          Positioned(bottom: 0, left: 0, child: _buildCorner(false, true)),
          Positioned(bottom: 0, right: 0, child: _buildCorner(false, false)),
        ],
      ),
    ),
  );

  Widget _buildCorner(bool top, bool left) => Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(
      border: Border(
        top: top
            ? BorderSide(color: context.colors.primary, width: 4)
            : BorderSide.none,
        left: left
            ? BorderSide(color: context.colors.primary, width: 4)
            : BorderSide.none,
        bottom: !top
            ? BorderSide(color: context.colors.primary, width: 4)
            : BorderSide.none,
        right: !left
            ? BorderSide(color: context.colors.primary, width: 4)
            : BorderSide.none,
      ),
    ),
  );

  Widget _buildInstructions(ThemeData theme) => Positioned(
    bottom: 50,
    left: 0,
    right: 0,
    child: Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.spacing.paragraphBottomMargin,
      ),
      padding: EdgeInsets.all(context.spacing.alertPadding),
      decoration: BoxDecoration(
        color: context.colors.textNormal.withValues(alpha: 0.7),
        borderRadius: context.radius.tile,
      ),
      child: Text(
        'qr_scanner.scan_hint'.tr(),
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: context.colors.textOnFilled,
        ),
      ),
    ),
  );
}
