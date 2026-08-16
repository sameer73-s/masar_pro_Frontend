import 'dart:math';
import 'package:flutter/widgets.dart';

class ResponsiveService {
  static late double _screenWidth;
  static late double _screenHeight;

  static const double _designWidth = 375.0;
  static const double _designHeight = 812.0;

  static void init(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _screenWidth = size.width;
    _screenHeight = size.height;
  }

  static double scaleWidth() => _screenWidth / _designWidth;
  static double scaleHeight() => _screenHeight / _designHeight;
  static double scaleRadius() => min(scaleWidth(), scaleHeight());
  static double scaleText() => min(scaleWidth(), scaleHeight());
}
