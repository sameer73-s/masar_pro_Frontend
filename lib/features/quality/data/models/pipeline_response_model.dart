import '../../domain/entities/pipeline_result.dart';
import 'humanize_result_model.dart';
import 'audit_result_model.dart';

class PipelineResponseModel extends PipelineResult {
  const PipelineResponseModel({
    required super.humanize,
    super.audit,
  });

  factory PipelineResponseModel.fromJson(Map<String, dynamic> json, String originalText) {
    final humanizeJson = json['humanize'] as Map<String, dynamic>?;
    final auditJson = json['audit'] as Map<String, dynamic>?;

    final humanizeResult = humanizeJson != null
        ? HumanizeResultModel.fromJson(humanizeJson, originalText)
        : null;

    final auditResult = auditJson != null
        ? AuditResultModel.fromJson(auditJson)
        : null;

    if (humanizeResult == null) {
      throw Exception('Humanize result is missing from pipeline response');
    }

    return PipelineResponseModel(
      humanize: humanizeResult,
      audit: auditResult,
    );
  }
}
