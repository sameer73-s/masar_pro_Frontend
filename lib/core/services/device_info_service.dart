import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:masar_pro/config/shared_preference.dart';
import 'package:masar_pro/core/errors/app_failure.dart';
import 'package:masar_pro/core/errors/either.dart';
import 'package:masar_pro/config/strings.dart';
import 'package:masar_pro/core/network/logger.dart';

abstract class DeviceInfoService {
  Future<Either<AppFailure, String>> getMobileSerial();
  Future<Either<AppFailure, String>> getMobileOsApiCode();
  Future<String?> getOldMobileSerial();
  Future<bool> setOldMobileSerial(String oldSerial);
}

final class DeviceInfoServiceImpl implements DeviceInfoService {
  const DeviceInfoServiceImpl({required this.plugin});

  final DeviceInfoPlugin plugin;

  //تم تعريف المفتاح هنا وليس في SharedPref حتى لا يتم تعديل القيمه من مكان اخر
  final String deviceOldSerialKey = 'device_old_serial';

  @override
  Future<String?> getOldMobileSerial() async {
    return SharedPref.instance.getString(deviceOldSerialKey);
  }

  @override
  Future<Either<AppFailure, String>> getMobileSerial() async {
    return Either.right("AAP3A.240905.015.A2");
    if (kIsWeb) {
      return Either.right('web-${DateTime.now().millisecondsSinceEpoch}');
    }
    try {
      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        AppLogger.info(info.id);
        return Either.right(info.id);
      }
      if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        return Either.right(info.identifierForVendor);
      }
      return Either.left(
        AppFailure.device(message: Strings.unknownDeviceOsApiCode),
      );
    } catch (e) {
      return Either.left(
        AppFailure.device(
          message: "${e.toString()}\n${Strings.unknownDeviceOsApiCode}",
        ),
      );
    }
  }

  @override
  Future<Either<AppFailure, String>> getMobileOsApiCode() async {
    if (kIsWeb) return Either.right('1');
    if (Platform.isAndroid) return Either.right('1');
    if (Platform.isIOS) return Either.right('2');
    return Either.left(
      AppFailure.device(message: Strings.unknownDeviceOsApiCode),
    );
  }

  @override
  Future<bool> setOldMobileSerial(String oldSerial) async {
    return SharedPref.instance.setString(deviceOldSerialKey, oldSerial);
  }
}
