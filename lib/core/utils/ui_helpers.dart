import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

extension SnackBarExtension on BuildContext {
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: colors.success),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: colors.error),
    );
  }

  void showInfoSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String? confirmText,
  bool destructive = false,
    }) async =>
    await showDialog<bool>(
      context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('common.cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: destructive
                  ? TextButton.styleFrom(foregroundColor: context.colors.error)
                  : null,
              child: Text(confirmText ?? 'common.delete'.tr()),
            ),
          ],
        ),
      ) ??
      false;
