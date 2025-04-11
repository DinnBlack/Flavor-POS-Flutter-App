import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback? onConfirm;
  final String confirmText;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.onConfirm,
    this.confirmText = "Xóa",
  });

  @override
  Widget build(BuildContext context) {
    return BasicDialogAlert(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        if (onConfirm != null)
          BasicDialogAction(
            title: Text(confirmText),
            onPressed: () {
              onConfirm?.call();
              Navigator.of(context).pop();
            },
          ),
        BasicDialogAction(
          title: const Text("Hủy"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
