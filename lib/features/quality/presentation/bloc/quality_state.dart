import '../../domain/entities/audit_result.dart';
import '../../domain/entities/check_then_humanize_result.dart';
import '../../domain/entities/humanize_result.dart';

abstract class QualityState {}

class QualityInitial extends QualityState {}

class QualityExtractingText extends QualityState {}

class QualityTextExtracted extends QualityState {
  final String text;
  QualityTextExtracted({required this.text});
}

class QualityHumanizing extends QualityState {}

class QualityAuditing extends QualityState {
  final HumanizeResult? humanizeResult;
  QualityAuditing({this.humanizeResult});
}

class QualitySuccess extends QualityState {
  final HumanizeResult humanizeResult;
  final AuditResult? auditResult;

  QualitySuccess({
    required this.humanizeResult,
    this.auditResult,
  });
}

class QualityAuditSuccess extends QualityState {
  final AuditResult auditResult;
  QualityAuditSuccess({required this.auditResult});
}

class QualityCheckThenHumanizeSuccess extends QualityState {
  final CheckThenHumanizeResult result;
  QualityCheckThenHumanizeSuccess({required this.result});
}

class QualityFailure extends QualityState {
  final String message;
  QualityFailure({required this.message});
}
