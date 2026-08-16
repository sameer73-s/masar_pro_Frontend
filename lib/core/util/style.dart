import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masar_pro/config/app_colors.dart';

final myOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: AppColors.gray),
  borderRadius: BorderRadius.circular(10),
);

final labelWidgetStyle = GoogleFonts.cairo(
  fontSize: 14,
  fontWeight: FontWeight.w300,
  color: AppColors.labelTeal,
);
InputDecoration genralFieldDecoration({Widget? hint}) =>
    InputDecoration(hint: hint, filled: false);
