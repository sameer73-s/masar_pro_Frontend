import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_assets.dart';
import 'package:masar_pro/config/app_colors.dart';

class CustomSnackBar extends SnackBar {
  final Widget widget;
  CustomSnackBar({super.key, required this.widget, super.width, super.duration})
    : super(
        backgroundColor: AppColors.black.withAlpha(180),
        padding: .symmetric(horizontal: 18, vertical: 7),
        content: Row(
          children: [
            Image.asset(AppAssetsImages.myIcLogo, width: 30, height: 30),
            SizedBox(width: 5),
            Expanded(child: widget),
          ],
        ),
        margin: width == null
            ? const EdgeInsets.only(bottom: 65, left: 20, right: 20)
            : null,
      );
}
