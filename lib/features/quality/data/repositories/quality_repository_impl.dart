import 'package:file_picker/file_picker.dart';
import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../../domain/entities/audit_result.dart';
import '../../domain/entities/check_then_humanize_result.dart';
import '../../domain/entities/humanize_result.dart';
import '../../domain/entities/pipeline_result.dart';
import '../../domain/enums/humanize_mode.dart';
import '../../domain/repositories/quality_repository.dart';
import '../datasources/quality_remote_datasource.dart';

class QualityRepositoryImpl extends BaseRepository implements QualityRepository {
  final QualityRemoteDataSource remoteDataSource;

  QualityRepositoryImpl({
    required super.networkService,
    required this.remoteDataSource,
  });

  @override
  Future<Either<AppFailure, PipelineResult>> runPipeline({
    required String text,
    required HumanizeMode mode,
    required String language,
    required bool runAudit,
    required bool useGemini,
  }) async {
    return guardedCall(() async {
      final result = await remoteDataSource.runPipeline(
        text: text,
        mode: mode,
        language: language,
        runAudit: runAudit,
        useGemini: useGemini,
      );
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, HumanizeResult>> humanizeOnly({
    required String text,
    required HumanizeMode mode,
    required String language,
    required bool useGemini,
  }) async {
    return guardedCall(() async {
      final result = await remoteDataSource.humanizeOnly(
        text: text,
        mode: mode,
        language: language,
        useGemini: useGemini,
      );
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, AuditResult>> auditOnly({
    required String text,
    int timeoutSeconds = 120,
  }) async {
    return guardedCall(() async {
      final result = await remoteDataSource.auditOnly(
        text: text,
        timeoutSeconds: timeoutSeconds,
      );
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }

  @override
  Future<Either<AppFailure, String>> extractText(PlatformFile file) async {
    return guardedCall(() async {
      final result = await remoteDataSource.extractText(file);
      return result.fold(
        (failure) => Either.left(failure),
        (text) => Either.right(text),
      );
    });
  }

  @override
  Future<Either<AppFailure, CheckThenHumanizeResult>> checkThenHumanize({
    required String text,
    required bool isArabic,
    required bool useGemini,
  }) async {
    return guardedCall(() async {
      final result = await remoteDataSource.checkThenHumanize(
        text: text,
        isArabic: isArabic,
        useGemini: useGemini,
      );
      return result.fold(
        (failure) => Either.left(failure),
        (model) => Either.right(model),
      );
    });
  }
}
