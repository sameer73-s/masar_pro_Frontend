import 'package:flutter/material.dart';
import '../core/util/responsive_service.dart';
import 'app_colors.dart';

// --- Responsive sizing ---
extension SizeExtension on num {
  double get w => ResponsiveService.scaleWidth() * this;
  double get h => ResponsiveService.scaleHeight() * this;
  double get r => ResponsiveService.scaleRadius() * this;
  double get sp => ResponsiveService.scaleText() * this;
}

// --- Color helpers ---
extension ColorX on Color {
  Color lighter(int percent) {
    assert(percent >= 1 && percent <= 100);
    final amount = (percent / 100 * 255).round();
    return Color.fromARGB(
      alpha.toInt(),
      (red.toInt() + amount).clamp(0, 255),
      (green.toInt() + amount).clamp(0, 255),
      (blue.toInt() + amount).clamp(0, 255),
    );
  }

  Color darker(int percent) {
    assert(percent >= 1 && percent <= 100);
    final amount = (percent / 100 * 255).round();
    return Color.fromARGB(
      alpha.toInt(),
      (red.toInt() - amount).clamp(0, 255),
      (green.toInt() - amount).clamp(0, 255),
      (blue.toInt() - amount).clamp(0, 255),
    );
  }
}

// --- TextStyle helpers ---
extension TextStyleX on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  TextStyle get underlined => copyWith(decoration: TextDecoration.underline);
  TextStyle get ellipsis => copyWith(overflow: TextOverflow.ellipsis);
  TextStyle withHeight(double h) => copyWith(height: h);
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

// --- Widget helpers ---
extension WidgetX on Widget {
  Widget withRipple({required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: this,
      ),
    );
  }

  Widget withPadding(EdgeInsetsGeometry padding) =>
      Padding(padding: padding, child: this);
}

// --- String helpers ---
extension StringX on String {
  bool get isValidEmail => RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  ).hasMatch(this);
}
