import 'package:file_picker/file_picker.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../entities/generate_versions_result.dart';

abstract class ExcelVersionerRepository {
  Future<Either<AppFailure, GenerateVersionsResult>> generateVersions({
    required PlatformFile file,
    required String prompt,
    required int versionCount,
    required bool changeStyle,
    required bool changeNumbers,
  });
}
