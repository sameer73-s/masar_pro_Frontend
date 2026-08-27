import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/strings.dart';
import 'package:masar_pro/config/typography.dart';
import 'package:masar_pro/core/presentation/widgets/primary_button.dart';

class AppSuccessDialog extends StatelessWidget {
  const AppSuccessDialog({
    super.key,
    required this.message,
    required this.onOk,
    this.title,
    this.okButtonText,
  });

  final String message;
  final String? title;
  final VoidCallback onOk;
  final String? okButtonText;

  static const double _designWidth = 375.0;
  static const double _designHeight = 812.0;

  /// Shows a modal [AppSuccessDialog]. Returns when the dialog is dismissed.
  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    String? okButtonText,
    VoidCallback? onOk,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AppSuccessDialog(
        message: message,
        title: title,
        okButtonText: okButtonText,
        onOk: () {
          Navigator.of(dialogContext).pop();
          onOk?.call();
        },
      ),
    );
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
                color: AppColors.success.withValues(alpha: 0.12),
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: sp(40),
              ),
            ),
            SizedBox(height: h(16)),
            Text(
              title ?? 'successTitle'.tr(),
              style: AppTypography.title(fontSize: 16, color: AppColors.black),
            ),
            SizedBox(height: h(8)),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                fontSize: 14,
                color: AppColors.grayStatus,
              ),
            ),
            SizedBox(height: h(20)),
            PrimaryButton(
              text: okButtonText ?? Strings.ok.tr(),
              onPressed: onOk,
              width: double.infinity,
              height: h(40),
              borderRadius: r(8),
              backgroundColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}
