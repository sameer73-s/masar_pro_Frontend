import '../../domain/entities/excel_version.dart';

class ExcelVersionModel extends ExcelVersion {
  const ExcelVersionModel({
    required super.name,
    required super.url,
  });

  factory ExcelVersionModel.fromJson(Map<String, dynamic> json) {
    return ExcelVersionModel(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}
