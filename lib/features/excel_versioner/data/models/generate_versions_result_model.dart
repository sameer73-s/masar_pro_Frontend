import '../../domain/entities/generate_versions_result.dart';
import 'excel_version_model.dart';

class GenerateVersionsResultModel extends GenerateVersionsResult {
  const GenerateVersionsResultModel({
    required super.versions,
    required super.zipUrl,
    required super.processingTime,
  });

  factory GenerateVersionsResultModel.fromJson(Map<String, dynamic> json) {
    final versionsList = (json['versions'] as List? ?? [])
        .map((v) => ExcelVersionModel.fromJson(Map<String, dynamic>.from(v as Map)))
        .toList();

    return GenerateVersionsResultModel(
      versions: versionsList,
      zipUrl: json['zip_url'] as String? ?? '',
      processingTime: (json['processing_time'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
