import 'package:flutter/material.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/utils/frame_utils.dart';

class AppInputDialog {
  static Future<String?> show({
    required BuildContext context,
    required String title,
    required String hint,
    String? initialValue,
    String confirmLabel = 'Save',
  }) async {
    final palette = context.palette;
    final controller = TextEditingController(text: initialValue);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: palette.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: palette.borderSubtle),
          ),
          title: Text(title, style: TextStyle(color: palette.textPrimary)),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: hint),
            onSubmitted: (value) {
              Navigator.of(dialogContext).pop(value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    await waitForNextFrame();
    controller.dispose();
    if (result == null || result.isEmpty) return null;
    return result;
  }
}
