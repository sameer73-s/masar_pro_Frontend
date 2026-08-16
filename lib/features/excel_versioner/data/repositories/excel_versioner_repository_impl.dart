import 'package:file_picker/file_picker.dart';
import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../../domain/entities/generate_versions_result.dart';
import '../../domain/repositories/excel_versioner_repository.dart';
import '../datasources/excel_versioner_remote_datasource.dart';

class ExcelVersionerRepositoryImpl extends BaseRepository
    implements ExcelVersionerRepository {
  final ExcelVersionerRemoteDataSource remoteDataSource;

  ExcelVersionerRepositoryImpl({
    required super.networkService,
    required this.remoteDataSource,
  });

  @override
  Future<Either<AppFailure, GenerateVersionsResult>> generateVersions({
    required PlatformFile file,
    required String prompt,
    required int versionCount,
    required bool changeStyle,
    required bool changeNumbers,
  }) async {
    return guardedCall(() async {
      final result = await remoteDataSource.generateVersions(
        file: file,
        prompt: prompt,
        versionCount: versionCount,
        changeStyle: changeStyle,
        changeNumbers: changeNumbers,
      );
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }
}
