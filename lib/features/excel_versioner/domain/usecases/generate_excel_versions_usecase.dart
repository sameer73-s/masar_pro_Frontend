import 'package:file_picker/file_picker.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../entities/generate_versions_result.dart';
import '../repositories/excel_versioner_repository.dart';

class GenerateExcelVersionsParams {
  final PlatformFile file;
  final String prompt;
  final int versionCount;
  final bool changeStyle;
  final bool changeNumbers;

  const GenerateExcelVersionsParams({
    required this.file,
    required this.prompt,
    required this.versionCount,
    required this.changeStyle,
    required this.changeNumbers,
  });
}

class GenerateExcelVersionsUseCase {
  final ExcelVersionerRepository repository;

  GenerateExcelVersionsUseCase(this.repository);

  Future<Either<AppFailure, GenerateVersionsResult>> call(
    GenerateExcelVersionsParams params,
  ) {
    return repository.generateVersions(
      file: params.file,
      prompt: params.prompt,
      versionCount: params.versionCount,
      changeStyle: params.changeStyle,
      changeNumbers: params.changeNumbers,
    );
  }
}
