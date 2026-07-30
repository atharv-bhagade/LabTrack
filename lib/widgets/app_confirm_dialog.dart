import 'package:flutter/material.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/utils/frame_utils.dart';

class AppConfirmDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final palette = context.palette;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: palette.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: palette.borderSubtle),
          ),
          title: Text(
            title,
            style: TextStyle(color: palette.textPrimary),
          ),
          content: Text(
            message,
            style: TextStyle(color: palette.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelLabel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    isDestructive ? palette.defective : palette.accent,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    await waitForNextFrame();
    return result ?? false;
  }
}
