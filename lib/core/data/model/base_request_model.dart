import 'package:equatable/equatable.dart';

class BaseRequestModel extends Equatable {
  const BaseRequestModel({
    this.pLngNm,
    this.untNo,
    this.yrNo,
    this.pLocRecordLimit = "",
    this.pUsrNo = "",
  });

  final String? pLngNm;
  final String? untNo;
  final String? yrNo;

  final String pLocRecordLimit;
  final String pUsrNo;

  Map<String, dynamic> toRequestBody(Map<String, dynamic> additioanlData) {
    return {
      'Value': {
        'P_LNG_NO': languageCodeToNumber(pLngNm ?? ""),
        'UNT_NO': untNo,
        'YR_NO': yrNo,
        'P_LOC_RCRD_LMT': pLocRecordLimit,
        'P_USR_NO': pUsrNo,
        ...additioanlData,
      },
    };
  }

  /// Matches native OnyxESS: ar=1, en=2, fr=3, tr=4 (default ar).
  String languageCodeToNumber(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'ar':
        return '1';
      case 'en':
        return '2';
      case 'fr':
        return '3';
      case 'tr':
        return '4';
      default:
        return '1';
    }
  }

  @override
  List<Object?> get props => [pLngNm, untNo, yrNo];
}
