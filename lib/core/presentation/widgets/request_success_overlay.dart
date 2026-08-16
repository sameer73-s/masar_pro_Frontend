import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:masar_pro/config/app_assets.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/strings.dart';

abstract final class RequestSuccessOverlay {
  static Future<void> show(
    BuildContext context, {
    Duration duration = const Duration(seconds: 1),
    String? messageKey,
  }) async {
    if (!context.mounted) return;

    final completer = Completer<void>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, // مهم لارتفاع مخصص
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      isDismissible: false,
      enableDrag: false,
      builder: (sheetContext) {
        final screenHeight = MediaQuery.of(sheetContext).size.height;

        Timer(duration, () {
          if (!sheetContext.mounted) return;
          if (Navigator.of(sheetContext).canPop()) {
            Navigator.of(sheetContext).pop();
          }
          if (!completer.isCompleted) completer.complete();
        });

        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: SizedBox(
              width: double.infinity,
              height: screenHeight * 0.25, // ربع الشاشة
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppAssetsImages.icSuccessSvg,
                    height: 72,
                    width: 72,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      (messageKey ?? Strings.saveSuccessMessage).tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return completer.future;
  }
}
