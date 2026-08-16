import 'package:file_picker/file_picker.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../entities/audit_result.dart';
import '../entities/check_then_humanize_result.dart';
import '../entities/humanize_result.dart';
import '../entities/pipeline_result.dart';
import '../enums/humanize_mode.dart';
import '../repositories/quality_repository.dart';

class QualityRunPipelineUseCase {
  final QualityRepository repository;
  QualityRunPipelineUseCase(this.repository);

  Future<Either<AppFailure, PipelineResult>> call({
    required String text,
    required HumanizeMode mode,
    required String language,
    required bool runAudit,
    required bool useGemini,
  }) {
    return repository.runPipeline(
      text: text,
      mode: mode,
      language: language,
      runAudit: runAudit,
      useGemini: useGemini,
    );
  }
}

class QualityHumanizeOnlyUseCase {
  final QualityRepository repository;
  QualityHumanizeOnlyUseCase(this.repository);

  Future<Either<AppFailure, HumanizeResult>> call({
    required String text,
    required HumanizeMode mode,
    required String language,
    required bool useGemini,
  }) {
    return repository.humanizeOnly(
      text: text,
      mode: mode,
      language: language,
      useGemini: useGemini,
    );
  }
}

class QualityAuditOnlyUseCase {
  final QualityRepository repository;
  QualityAuditOnlyUseCase(this.repository);

  Future<Either<AppFailure, AuditResult>> call({
    required String text,
    int timeoutSeconds = 120,
  }) {
    return repository.auditOnly(text: text, timeoutSeconds: timeoutSeconds);
  }
}

class QualityExtractTextUseCase {
  final QualityRepository repository;
  QualityExtractTextUseCase(this.repository);

  Future<Either<AppFailure, String>> call(PlatformFile file) {
    return repository.extractText(file);
  }
}

class QualityCheckThenHumanizeUseCase {
  final QualityRepository repository;
  QualityCheckThenHumanizeUseCase(this.repository);

  Future<Either<AppFailure, CheckThenHumanizeResult>> call({
    required String text,
    required bool isArabic,
    required bool useGemini,
  }) {
    return repository.checkThenHumanize(
      text: text,
      isArabic: isArabic,
      useGemini: useGemini,
    );
  }
}
