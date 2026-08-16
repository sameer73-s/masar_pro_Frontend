import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  /// Arabic → Tajawal, otherwise → Manrope (English / default).
  static bool isArabic([BuildContext? context]) {
    final locale = context != null
        ? Localizations.localeOf(context)
        : WidgetsBinding.instance.platformDispatcher.locale;
    return locale.languageCode == 'ar';
  }

  static TextStyle _font({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
    BuildContext? context,
    double? height,
  }) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.primary,
      height: height,
    );
    if (isArabic(context)) {
      return GoogleFonts.tajawal(textStyle: style);
    }
    return GoogleFonts.manrope(textStyle: style);
  }

  /// Display / Hero — ExtraBold (w800), 60
  static TextStyle display({Color? color, BuildContext? context}) => _font(
        fontSize: 60,
        fontWeight: FontWeight.w800,
        color: color,
        context: context,
      );

  /// Headline — ExtraBold (w800), 25
  static TextStyle headline({Color? color, BuildContext? context}) => _font(
        fontSize: 25,
        fontWeight: FontWeight.w800,
        color: color,
        context: context,
      );

  /// Body / Title — Bold (w700), 18
  static TextStyle bodyTitle({Color? color, BuildContext? context}) => _font(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
        context: context,
      );

  static TextStyle title({
    double fontSize = 18,
    Color? color,
    BuildContext? context,
  }) =>
      _font(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color,
        context: context,
      );

  static TextStyle body({
    double fontSize = 13,
    Color? color,
    BuildContext? context,
  }) =>
      _font(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: color,
        context: context,
      );

  static TextStyle caption({
    double fontSize = 12,
    Color? color,
    BuildContext? context,
  }) =>
      _font(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: color ?? Colors.grey,
        context: context,
      );

  static TextStyle button({
    double fontSize = 15,
    Color? color,
    BuildContext? context,
  }) =>
      _font(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.primary,
        context: context,
      );

  static TextStyle label({
    double fontSize = 12,
    Color? color,
    BuildContext? context,
  }) =>
      _font(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.primary,
        context: context,
      );

  /// Locale-aware [TextTheme] for [ThemeData].
  static TextTheme textTheme(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    ).textTheme;

    final themed = isArabic(context)
        ? GoogleFonts.tajawalTextTheme(base)
        : GoogleFonts.manropeTextTheme(base);

    return themed.copyWith(
      displayLarge: display(context: context),
      displayMedium: display(context: context),
      headlineLarge: headline(context: context),
      headlineMedium: headline(context: context),
      titleLarge: bodyTitle(context: context),
      titleMedium: title(fontSize: 16, context: context),
      titleSmall: title(fontSize: 14, context: context),
      bodyLarge: body(fontSize: 15, context: context),
      bodyMedium: body(fontSize: 13, context: context),
      bodySmall: caption(fontSize: 12, context: context),
      labelLarge: label(fontSize: 12, context: context),
      labelMedium: label(fontSize: 14, context: context),
    );
  }
}
