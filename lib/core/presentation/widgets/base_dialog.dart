import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:masar_pro/config/strings.dart';

class BaseDialog extends StatelessWidget {
  const BaseDialog({
    required this.title,
    required this.content,
    this.actions,
    required this.dialogContext,
    super.key,
  });
  final Widget title;
  final Widget content;
  final List<Widget>? actions;
  final BuildContext dialogContext;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: title),
      content: content,
      actions:
          actions ??
          [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext, rootNavigator: true).pop();
              },
              child: Text(Strings.ok.tr()),
            ),
          ],
    );
  }
}
