import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

class PlatformDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String content,
    String? cancelLabel,
    String? confirmLabel,
    VoidCallback? onConfirm,
  }) {
    if (Platform.isIOS) {
      return showCupertinoDialog<T>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            if (cancelLabel != null)
              CupertinoDialogAction(
                child: Text(cancelLabel),
                onPressed: () => Navigator.pop(context),
              ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: onConfirm ?? () => Navigator.pop(context),
              child: Text(confirmLabel ?? 'OK'),
            ),
          ],
        ),
      );
    }

    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (cancelLabel != null)
            TextButton(
              child: Text(cancelLabel),
              onPressed: () => Navigator.pop(context),
            ),
          TextButton(
            onPressed: onConfirm ?? () => Navigator.pop(context),
            child: Text(confirmLabel ?? 'OK'),
          ),
        ],
      ),
    );
  }
}
