import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_colors.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

class QRScannerState {
  QRScannerState({
    required this.scannedCode,
    required this.isProcessing,
    required this.scannerController,
  });
  final String scannedCode;
  final bool isProcessing;
  final MobileScannerController scannerController;

  QRScannerState copyWith({
    String? scannedCode,
    bool? isProcessing,
    MobileScannerController? scannerController,
  }) => QRScannerState(
    scannedCode: scannedCode ?? this.scannedCode,
    isProcessing: isProcessing ?? this.isProcessing,
    scannerController: scannerController ?? this.scannerController,
  );
}

class QRScannerNotifier extends Notifier<QRScannerState> {
  @override
  QRScannerState build() {
    ref.onDispose(() {
      state.scannerController.dispose();
    });

    return QRScannerState(
      scannedCode: '',
      isProcessing: false,
      scannerController: MobileScannerController(),
    );
  }

  void handleQRCode(String? code, BuildContext context) {
    if (code == null || code.isEmpty || state.isProcessing) {
      return;
    }

    state = state.copyWith(isProcessing: true, scannedCode: code);

    _processQRCode(code, context);
  }

  Future<void> _processQRCode(String code, BuildContext context) async {
    final macRegex = RegExp(r'^([0-9A-Fa-f]{2}[:\-]){5}[0-9A-Fa-f]{2}$');
    final isMacAddress = macRegex.hasMatch(code.trim());

    if (isMacAddress) {
      await _assignToyByMac(code.trim(), context);
    } else {
      if (!context.mounted) {
        return;
      }
      await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('qr_scanner.scanned'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('qr_scanner.unrecognized_format'.tr()),
              SizedBox(height: context.spacing.titleBottomMarginSm),
              Text(
                code,
                style: context.theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                state = state.copyWith(isProcessing: false);
              },
              child: Text('qr_scanner.scan_again'.tr()),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _assignToyByMac(String macAddress, BuildContext context) async {
    final user = ref.read(authProvider).value;
    if (user == null) {
      state = state.copyWith(isProcessing: false);
      return;
    }

    try {
      final toyService = ref.read(toyServiceProvider);
      final result = await toyService.assignToy(
        macAddress: macAddress,
        userId: user.id,
      );

      if (!context.mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: Icon(Icons.check_circle, color: context.colors.success, size: 48),
          title: Text('qr_scanner.toy_assigned'.tr()),
          content: Text(
            'qr_scanner.toy_assigned_desc'.tr(
              args: [result.toy?.name ?? macAddress],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text('qr_scanner.done'.tr()),
            ),
          ],
        ),
      );
    } on Exception catch (e) {
      if (!context.mounted) {
        return;
      }
      final message = e.toString().replaceFirst('Exception: ', '');
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: Icon(Icons.error, color: context.colors.error, size: 48),
          title: Text('qr_scanner.assignment_failed'.tr()),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                state = state.copyWith(isProcessing: false);
              },
              child: Text('qr_scanner.scan_again'.tr()),
            ),
          ],
        ),
      );
    }
  }
}

final qrScannerProvider = NotifierProvider<QRScannerNotifier, QRScannerState>(
  QRScannerNotifier.new,
);
