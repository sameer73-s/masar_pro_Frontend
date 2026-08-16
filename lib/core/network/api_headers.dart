import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../config/secure_storage_service.dart';
import '../../config/shared_preference.dart';

class ApiHeaders {
  static String get _accessToken =>
      SharedPref.instance.getString(SharedPrefKeys.jwtToken) ?? '';

  static const _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'VersionNo': '4',
  };

  static Map<String, String> get guest => Map.of(_jsonHeaders);

  static Map<String, String> get authenticated => {
    ..._jsonHeaders,
    if (_accessToken.isNotEmpty) 'Authorization': 'Bearer $_accessToken',
  };

  static Map<String, String> get multipart => {
    'Accept': 'application/json',
    'Content-Type': 'multipart/form-data',
    if (_accessToken.isNotEmpty) 'Authorization': 'Bearer $_accessToken',
  };

  /// Resolves Bearer auth: Masar JWT (SharedPref → SecureStorage), else Firebase ID token.
  static Future<Map<String, String>> authenticatedAsync() async {
    final headers = Map<String, String>.of(_jsonHeaders);

    var jwt = _accessToken;
    if (jwt.isEmpty) {
      try {
        jwt = await SecureStorageService().getToken() ?? '';
        if (jwt.isNotEmpty) {
          // Keep SharedPref in sync for sync getters / legacy callers.
          await SharedPref.instance.setString(SharedPrefKeys.jwtToken, jwt);
        }
      } catch (e) {
        debugPrint('[ApiHeaders] SecureStorage token read failed: $e');
      }
    }

    if (jwt.isNotEmpty) {
      headers['Authorization'] = 'Bearer $jwt';
      debugPrint(
        '[ApiHeaders] Authorization attached (Masar JWT, len=${jwt.length})',
      );
      return headers;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        debugPrint(
          '[ApiHeaders] Authorization attached (Firebase ID token, '
          'uid=${user?.uid}, len=${token.length})',
        );
      } else {
        debugPrint(
          '[ApiHeaders] WARNING: no Bearer token '
          '(signedIn=${user != null}, jwt empty)',
        );
      }
    } catch (e) {
      debugPrint('[ApiHeaders] Failed to resolve Firebase ID token: $e');
    }
    return headers;
  }
}
