import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_theme.dart';
import '../../../config/typography.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final String? iconAsset;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final double elevation;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius = AppShapes.buttonRadius,
    this.iconAsset,
    this.icon,
    this.padding,
    this.textStyle,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final hasFixedHeight = height != null;
    final foreground = textColor ?? AppColors.white;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.accentPurple,
          foregroundColor: foreground,
          elevation: elevation,
          shadowColor: elevation == 0 ? Colors.transparent : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          disabledBackgroundColor: AppColors.grayHint,
          padding: padding,
          minimumSize: hasFixedHeight
              ? Size(width ?? double.infinity, height!)
              : const Size(0, 48),
          tapTargetSize: hasFixedHeight
              ? MaterialTapTargetSize.shrinkWrap
              : null,
          visualDensity: hasFixedHeight ? VisualDensity.compact : null,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foreground),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: foreground),
                    const SizedBox(width: 8),
                  ] else if (iconAsset != null) ...[
                    Image.asset(iconAsset!, height: 20, width: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style:
                        textStyle ??
                        AppTypography.button(
                          color: foreground,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}
