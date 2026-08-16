import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:masar_pro/config/app_assets.dart';
import 'package:masar_pro/config/app_colors.dart';

class ClosedIcon extends StatelessWidget {
  const ClosedIcon({super.key, this.onTap, this.padding, this.boxShadow});
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final List<BoxShadow>? boxShadow;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          boxShadow:
              boxShadow ??
              [
                BoxShadow(
                  blurRadius: 3,
                  spreadRadius: 0,
                  color: AppColors.black.withValues(alpha: 0.2),
                  offset: Offset(-.5, 4),
                ),
              ],
        ),
        child: SvgPicture.asset(AppAssetsImages.icClose),
      ),
    );
  }
}
