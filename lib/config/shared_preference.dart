import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefKeys {
  SharedPrefKeys._();
  static const String jwtToken = 'jwt_token';

  /// Saved from [ServerSettingForm] — required for auth API `Value` bodies.
  static const String serverBaseUrlKey = 'server_base_url_key';
  static const String unitNoKey = 'unit_no_key';
  static const String yearNoKey = 'year_no_key';
  static const String languageNmKey = 'language_nm_key';
  static const String employeeNoKey = 'employee_no_key';

  /// FCM or push token for auth API bodies when persisted.
  static const String deviceTokenKey = 'device_token_key';
  static const String shwApprvScrKey = 'shw_apprv_scr_key';
  static const String userNoKey = 'user_no';
}

class SharedPref {
  SharedPref._();
  static final SharedPref instance = SharedPref._();

  SharedPreferences? _prefs;
  bool get isInitialized => _prefs != null;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _requirePrefs {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError(
        'SharedPref has not been initialized. '
        'Call await SharedPref.instance.initialize() in main() before runApp().',
      );
    }
    return prefs;
  }

  String? getString(String key) => _prefs?.getString(key);
  bool? getBool(String key) => _prefs?.getBool(key);
  int? getInt(String key) => _prefs?.getInt(key);

  Future<bool> setString(String key, String value) async {
    await initialize();
    return _requirePrefs.setString(key, value);
  }

  Future<bool> setBool(String key, bool value) async {
    await initialize();
    return _requirePrefs.setBool(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    await initialize();
    return _requirePrefs.setInt(key, value);
  }

  Future<bool> remove(String key) async {
    await initialize();
    return _requirePrefs.remove(key);
  }

  Future<bool> clear() async {
    await initialize();
    return _requirePrefs.clear();
  }
}
