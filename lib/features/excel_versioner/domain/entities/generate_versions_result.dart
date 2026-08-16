import 'excel_version.dart';

class GenerateVersionsResult {
  final List<ExcelVersion> versions;
  final String zipUrl;
  final double processingTime;

  const GenerateVersionsResult({
    required this.versions,
    required this.zipUrl,
    required this.processingTime,
  });
}
