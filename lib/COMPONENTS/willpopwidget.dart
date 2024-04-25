      import 'package:flutter/material.dart';

class WidgetUtils{
  /// display alert dialog with 3 option button
  static Future<void> alertDialog3(
      {required BuildContext context,
      required String title,
      required Widget body,
      Alignment titleAlignment = Alignment.center,
      String cancelText = "cancel",
      String primaryText = "confirm 1",
      String secondaryText = "confirm 2",
      bool disposeOnCancel = true,
      bool disposeOnPrimary = true,
      bool disposeOnSecondary = true,
      Function? onPrimary,
      Function? onSecondary,
      Function? onCancel,
      bool showPrimaryButton = true,
      bool showSecondaryButton = true,
      bool isPrimaryDanger = false,
      bool isSecondaryDanger = false}) {
    return showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          scrollable: true,
          title: Align(alignment: titleAlignment, child: Text(title)),
          content: body,
          actions: [
            TextButton(
              child: Text(
                cancelText,
                style: const TextStyle(color: Colors.grey),
              ),
              onPressed: () async {
                if (onCancel != null) {
                  onCancel();
                }
                if (disposeOnCancel) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(dialogContext);
                }
              },
            ),
            if (showSecondaryButton)
              TextButton(
                child: Text(
                  secondaryText,
                  style: TextStyle(
                      color: isSecondaryDanger
                          ? Colors.red.shade800
                          : Colors.grey.shade800),
                ),
                onPressed: () async {
                  if (disposeOnSecondary) {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(dialogContext);
                  }
                  if (onSecondary != null) {
                    onSecondary();
                  }
                },
              ),
            if (showPrimaryButton)
              TextButton(
                child: Text(
                  primaryText,
                  style: TextStyle(
                      color:
                          isPrimaryDanger ? Colors.red.shade800 : Colors.black),
                ),
                onPressed: () {
                  if (disposeOnPrimary) {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(dialogContext);
                  }
                  if (onPrimary != null) {
                      onPrimary();
                  }
                },
              ),
          ],
        );
      },
    );
  }
}