import 'package:flutter/material.dart';
import 'package:hello_flutter/theme/app_palette.dart';
import 'package:hello_flutter/utils/frame_utils.dart';

class ReportProblemDialog {
  /// Returns trimmed problem text, or `null` if cancelled / empty.
  static Future<String?> show({
    required BuildContext context,
    String title = 'Report Problem',
    String? initialValue,
  }) async {
    final palette = context.palette;
    final controller = TextEditingController(text: initialValue ?? '');

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
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
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Describe the issue',
              alignLabelWithHint: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.of(dialogContext).pop(text);
              },
              child: const Text('Report Problem'),
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
