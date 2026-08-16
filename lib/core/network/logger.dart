import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
class AppLogger {
  static void info(Object? object) {
    if (kDebugMode) debugPrint(object.toString());
  }

  static void error(Object? object) {
    if (kDebugMode) {
      debugPrint('══════ ERROR ══════');
      debugPrint(object.toString());
      debugPrint('═══════════════════');
    }
  }

  static void success(Object? object) {
    if (kDebugMode) debugPrint('\x1B[32m$object\x1B[0m');
  }

  static void warning(Object? object) {
    if (kDebugMode) debugPrint('\x1B[33m$object\x1B[0m');
  }
}
