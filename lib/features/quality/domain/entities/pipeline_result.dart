import 'humanize_result.dart';
import 'audit_result.dart';

class PipelineResult {
  final HumanizeResult humanize;
  final AuditResult? audit;

  const PipelineResult({
    required this.humanize,
    this.audit,
  });
}
