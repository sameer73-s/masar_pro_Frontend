import 'package:file_picker/file_picker.dart';
import '../../domain/enums/humanize_mode.dart';

abstract class QualityEvent {}

class RunPipelineEvent extends QualityEvent {
  final String text;
  final HumanizeMode mode;
  final String language;
  final bool runAudit;
  final bool useGemini;

  RunPipelineEvent({
    required this.text,
    required this.mode,
    required this.language,
    required this.runAudit,
    required this.useGemini,
  });
}

class HumanizeOnlyEvent extends QualityEvent {
  final String text;
  final HumanizeMode mode;
  final String language;
  final bool useGemini;

  HumanizeOnlyEvent({
    required this.text,
    required this.mode,
    required this.language,
    required this.useGemini,
  });
}

class AuditOnlyEvent extends QualityEvent {
  final String text;
  final int timeoutSeconds;

  AuditOnlyEvent({
    required this.text,
    this.timeoutSeconds = 120,
  });
}

class ExtractTextEvent extends QualityEvent {
  final PlatformFile file;

  ExtractTextEvent({required this.file});
}

class CheckThenHumanizeEvent extends QualityEvent {
  final String text;
  final bool isArabic;
  final bool useGemini;

  CheckThenHumanizeEvent({
    required this.text,
    this.isArabic = true,
    this.useGemini = true,
  });
}

class ResetQualityEvent extends QualityEvent {}
