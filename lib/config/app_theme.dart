import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'typography.dart';

/// Shape radii from the Figma design system.
class AppShapes {
  AppShapes._();

  static const double cardRadius = 14.0;
  static const double buttonRadius = 24.0;
  static const double secondaryContainerRadius = 13.0;
}

/// Custom elevations using [AppColors.shadowColor] at 15% opacity.
class AppShadows {
  AppShadows._();

  static Color get _shadow => AppColors.shadowColor.withValues(alpha: 0.15);

  /// Subtle cards — offset (0, 4), blur 10
  static List<BoxShadow> get subtleCard => [
        BoxShadow(
          color: _shadow,
          offset: const Offset(0, 4),
          blurRadius: 10,
        ),
      ];

  /// Floating elements — offset (30, 20), blur 50
  static List<BoxShadow> get floating => [
        BoxShadow(
          color: _shadow,
          offset: const Offset(30, 20),
          blurRadius: 50,
        ),
      ];
}

ThemeData appTheme(BuildContext context) {
  final isArabic = AppTypography.isArabic(context);
  final fontFamily = isArabic
      ? GoogleFonts.tajawal().fontFamily
      : GoogleFonts.manrope().fontFamily;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    focusColor: AppColors.surfacePurple,
    cardColor: AppColors.background,
    dividerColor: Colors.grey,
    hintColor: AppColors.hint,
    fontFamily: fontFamily,
    tabBarTheme: const TabBarThemeData(
      indicatorColor: AppColors.accentPurple,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accentPurple,
      tertiary: AppColors.accentYellow,
      brightness: Brightness.light,
      surface: AppColors.background,
      error: AppColors.error,
      secondaryContainer: AppColors.surfacePurple,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.primary,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: AppTypography.title(fontSize: 17, context: context),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.background,
      shadowColor: AppColors.shadowColor.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
      ),
    ),
    dialogTheme: DialogThemeData(
      elevation: 0,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
      ),
    ),
    textTheme: AppTypography.textTheme(context),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentPurple,
        foregroundColor: AppColors.white,
        elevation: 0,
        textStyle: AppTypography.button(context: context, color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
        ),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accentPurple,
        foregroundColor: AppColors.white,
        elevation: 0,
        textStyle: AppTypography.button(context: context, color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        textStyle: AppTypography.button(context: context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accentPurple,
        textStyle: AppTypography.button(context: context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
        ),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.accentPurple,
      selectionHandleColor: AppColors.accentPurple,
      selectionColor: AppColors.surfacePurple,
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.all(AppColors.background),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accentPurple;
        }
        return null;
      }),
      side: WidgetStateBorderSide.resolveWith(
        (_) => const BorderSide(width: 1.5, color: AppColors.primary),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(AppShapes.secondaryContainerRadius),
        borderSide: BorderSide(color: AppColors.gray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(AppShapes.secondaryContainerRadius),
        borderSide: BorderSide(color: AppColors.gray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(AppShapes.secondaryContainerRadius),
        borderSide: const BorderSide(color: AppColors.accentPurple),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(AppShapes.secondaryContainerRadius),
        borderSide: BorderSide(color: AppColors.error),
      ),
      hintStyle: AppTypography.body(color: AppColors.gray, context: context),
      errorStyle: const TextStyle(fontSize: 12),
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: const WidgetStatePropertyAll(AppColors.background),
      elevation: const WidgetStatePropertyAll(0),
      constraints: const BoxConstraints(minHeight: 40),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          side: BorderSide(color: AppColors.gray, width: .5),
          borderRadius:
              BorderRadius.circular(AppShapes.secondaryContainerRadius),
        ),
      ),
      hintStyle: WidgetStatePropertyAll(
        AppTypography.body(color: AppColors.hint, context: context),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
      ),
      headerBackgroundColor: AppColors.primary,
      headerForegroundColor: AppColors.background,
      subHeaderForegroundColor: AppColors.primary,
      todayForegroundColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.background;
        }
        return AppColors.primary;
      }),
      todayBackgroundColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.background;
      }),
      dayBackgroundColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.background;
      }),
      yearBackgroundColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.background;
      }),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: AppColors.background,
      dialHandColor: AppColors.accentPurple,
      dialBackgroundColor: AppColors.surfacePurple,
      hourMinuteTextColor: AppColors.background,
      hourMinuteColor: AppColors.primary,
      dayPeriodColor: AppColors.accentPurple.withValues(alpha: 0.8),
      dayPeriodTextColor: AppColors.primary,
      timeSelectorSeparatorColor: const WidgetStatePropertyAll(
        AppColors.primary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppShapes.cardRadius),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      contentTextStyle: const TextStyle(color: AppColors.background),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
      ),
      backgroundColor: AppColors.primary.withAlpha(200),
    ),
  );
}
