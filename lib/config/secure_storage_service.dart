import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'shared_preference.dart';
import '../core/data/model/user_model.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._();
  factory SecureStorageService() => _instance;
  SecureStorageService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _keyToken = 'jwt_token';
  static const _keyUser = 'user';

  Future<void> saveToken(String token) =>
      _storage.write(key: _keyToken, value: token);

  Future<String?> getToken() => _storage.read(key: _keyToken);

  Future<void> deleteToken() => _storage.delete(key: _keyToken);

  Future<void> saveUser(UserModel user) async {
    await SharedPref.instance.setString(
      SharedPrefKeys.jwtToken,
      user.token ?? '',
    );
    await _storage.write(key: _keyUser, value: jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final json = await _storage.read(key: _keyUser);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> deleteUser() => _storage.delete(key: _keyUser);

  Future<void> clearAll() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUser);
    await SharedPref.instance.remove(SharedPrefKeys.jwtToken);
    await SharedPref.instance.remove(SharedPrefKeys.userNoKey);
    await SharedPref.instance.remove(SharedPrefKeys.shwApprvScrKey);
  }

  // Future<void> saveUserInfo(UserInfo userInfo) async {
  //   await _storage.write(
  //     key: _keyUserInfo,
  //     value: jsonEncode(UserInfoModel.fromEntity(userInfo).toJson()),
  //   );
  // }

  // Future<UserInfo?> getUserInfo() async {
  //   final json = await _storage.read(key: _keyUserInfo);
  //   if (json == null) return null;
  //   return UserInfoModel.fromJson(
  //     jsonDecode(json) as Map<String, dynamic>,
  //   ).toEntity();
  // }

  // Future<void> deleteUserInfo() async {
  //   await _storage.delete(key: _keyUserInfo);
  // }

  Future<void> setString({required String data, required String key}) async {
    await _storage.write(key: key, value: data);
  }

  Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}
