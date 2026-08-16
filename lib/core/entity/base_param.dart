import 'package:equatable/equatable.dart';

class BaseParam extends Equatable {
  const BaseParam({
    this.langNm,
    this.unitNo,
    this.yearNo,
    this.locRecordLimit,
    this.userNo,
  });

  final String? langNm;
  final String? unitNo;
  final String? yearNo;

  final String? locRecordLimit;
  final String? userNo;

  @override
  List<Object?> get props => [langNm, unitNo, yearNo, locRecordLimit, userNo];
}
