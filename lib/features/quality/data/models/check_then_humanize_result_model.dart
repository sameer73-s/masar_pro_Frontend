import '../../domain/entities/check_then_humanize_result.dart';

class CheckThenHumanizeResultModel extends CheckThenHumanizeResult {
  const CheckThenHumanizeResultModel({
    required super.beforeScore,
    super.afterScore,
    super.humanizedText,
    required super.needsHumanization,
    super.downloadUrl,
    super.reportUrl,
  });

  factory CheckThenHumanizeResultModel.fromJson(Map<String, dynamic> json) {
    return CheckThenHumanizeResultModel(
      beforeScore: (json['before_score'] as num?)?.toDouble() ?? 0.0,
      afterScore: (json['after_score'] as num?)?.toDouble(),
      humanizedText: json['humanized_text'] as String?,
      needsHumanization: json['needs_humanization'] as bool? ?? true,
      downloadUrl: json['download_url'] as String?,
      reportUrl: json['report_url'] as String?,
    );
  }
}
