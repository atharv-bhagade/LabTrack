import 'package:flutter/material.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/utils/frame_utils.dart';

/// Result of the unsaved device name prompt.
enum UnsavedNameChoice { save, discard, cancel }

class AppUnsavedNameDialog {
  static Future<UnsavedNameChoice> show(BuildContext context) async {
    final palette = context.palette;
    final result = await showDialog<UnsavedNameChoice>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: palette.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: palette.borderSubtle),
          ),
          title: Text(
            'Unsaved changes',
            style: TextStyle(color: palette.textPrimary),
          ),
          content: Text(
            'You have unsaved name changes.\nSave before closing?',
            style: TextStyle(color: palette.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(UnsavedNameChoice.cancel),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(UnsavedNameChoice.discard),
              child: const Text('Discard'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(UnsavedNameChoice.save),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    await waitForNextFrame();
    return result ?? UnsavedNameChoice.cancel;
  }
}
