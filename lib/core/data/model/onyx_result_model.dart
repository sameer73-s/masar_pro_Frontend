import 'package:easy_localization/easy_localization.dart';
import 'package:masar_pro/config/strings.dart';

class OnyxResultModel {
  const OnyxResultModel({
    required this.errNo,
    required this.errMsg,
    this.versionNo,
  });

  final int errNo;
  final String errMsg;
  final String? versionNo;
  factory OnyxResultModel.fromJson(Map<String, dynamic> json) =>
      OnyxResultModel(
        errNo: ((json['ErrNo'] ?? -1) as num).toInt(),
        errMsg: json['ErrMsg'] ?? "",
        versionNo: json['VersionNo'] as String?,
      );
  String get errorMessage {
    switch (errNo) {
      case 1:
        return "$errNo - ${Strings.noDataFound.tr()}";

      case 5577: // locally
        return "$errNo - ${Strings.systemUpdateProgress.tr()}";

      case 5566: // locally
        return "$errNo - ${Strings.systemUpdateProgressMobile.tr()}";

      case 65:
        return "$errNo - ${Strings.employeeNoRequired.tr()}";

      case 66:
        return "$errNo - ${Strings.passwordRequired.tr()}";

      case 67:
        return "$errNo - ${Strings.wrongPassword.tr()}";

      case 69:
        return "$errNo - ${Strings.deviceSerialRequired.tr()}";

      case 70:
        return "$errNo - ${Strings.employeeNotLinkedWithDevice.tr()}";

      case 71:
        return "$errNo - ${Strings.employeeHasToAssignedToLocation.tr()}";

      case 72:
        return "$errNo - ${Strings.errorDeviceNumberEmployee.tr()}";

      case 10:
      case 100:
        return "$errNo - $errMsg";
      default:
        return "$errNo - $errMsg";
    }
  }
}
