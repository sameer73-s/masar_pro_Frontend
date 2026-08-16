import 'package:file_picker/file_picker.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either.dart';
import '../enums/humanize_mode.dart';
import '../entities/humanize_result.dart';
import '../entities/audit_result.dart';
import '../entities/pipeline_result.dart';
import '../entities/check_then_humanize_result.dart';

abstract class QualityRepository {
  Future<Either<AppFailure, PipelineResult>> runPipeline({
    required String text,
    required HumanizeMode mode,
    required String language,
    required bool runAudit,
    required bool useGemini,
  });

  Future<Either<AppFailure, HumanizeResult>> humanizeOnly({
    required String text,
    required HumanizeMode mode,
    required String language,
    required bool useGemini,
  });

  Future<Either<AppFailure, AuditResult>> auditOnly({
    required String text,
    int timeoutSeconds = 120,
  });

  Future<Either<AppFailure, String>> extractText(PlatformFile file);

  Future<Either<AppFailure, CheckThenHumanizeResult>> checkThenHumanize({
    required String text,
    required bool isArabic,
    required bool useGemini,
  });
}
