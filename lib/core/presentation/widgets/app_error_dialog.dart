import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/strings.dart';
import 'package:masar_pro/config/typography.dart';
import 'package:masar_pro/core/presentation/widgets/primary_button.dart';

class AppErrorDialog extends StatelessWidget {
  const AppErrorDialog({
    super.key,
    required this.message,
    required this.onOk,
    this.title,
    this.okButtonText,
    this.secondaryButtonText,
    this.onSecondaryAction,
  });

  final String message;
  final String? title;
  final VoidCallback onOk;
  final String? okButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryAction;

  static const double _designWidth = 375.0;
  static const double _designHeight = 812.0;

  /// Shows a modal [AppErrorDialog]. Returns when the dialog is dismissed.
  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    String? okButtonText,
    VoidCallback? onOk,
    String? secondaryButtonText,
    VoidCallback? onSecondaryAction,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AppErrorDialog(
        message: message,
        title: title,
        okButtonText: okButtonText,
        onOk: () {
          Navigator.of(dialogContext).pop();
          onOk?.call();
        },
        secondaryButtonText: secondaryButtonText,
        onSecondaryAction: onSecondaryAction == null
            ? null
            : () {
                Navigator.of(dialogContext).pop();
                onSecondaryAction();
              },
      ),
    );
  }

  void _copyMessage(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scaleW = size.width / _designWidth;
    final scaleH = size.height / _designHeight;
    final scale = min(scaleW, scaleH);

    double w(num v) => scaleW * v;
    double h(num v) => scaleH * v;
    double r(num v) => scale * v;
    double sp(num v) => scale * v;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(r(15)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(w(24), h(28), w(24), h(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: w(64),
              height: w(64),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.darkerRed.withValues(alpha: 0.12),
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColors.darkerRed,
                size: sp(40),
              ),
            ),
            SizedBox(height: h(16)),
            Text(
              title ?? Strings.error.tr(),
              style: AppTypography.title(fontSize: 16, color: AppColors.black),
            ),
            SizedBox(height: h(8)),
            // Show up to 8 lines so real backend `detail` messages are readable;
            // tap still copies the full untruncated message.
            InkWell(
              onTap: () => _copyMessage(context),
              borderRadius: BorderRadius.circular(r(8)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w(4), vertical: h(4)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        maxLines: 8,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(
                          fontSize: 14,
                          color: AppColors.grayStatus,
                        ),
                      ),
                    ),
                    SizedBox(width: w(6)),
                    Icon(
                      Icons.copy_rounded,
                      size: sp(16),
                      color: AppColors.grayStatus,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: h(20)),
            PrimaryButton(
              text: okButtonText ?? Strings.ok.tr(),
              onPressed: onOk,
              width: double.infinity,
              height: h(40),
              borderRadius: r(8),
              backgroundColor: AppColors.darkerRed,
            ),
            if (secondaryButtonText != null && onSecondaryAction != null) ...[
              SizedBox(height: h(12)),
              TextButton(
                onPressed: onSecondaryAction,
                style: TextButton.styleFrom(
                  minimumSize: Size(double.infinity, h(36)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(r(8)),
                  ),
                  foregroundColor: AppColors.grayStatus,
                ),
                child: Text(
                  secondaryButtonText!,
                  style: AppTypography.body(
                    fontSize: 14,
                    color: AppColors.grayStatus,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
