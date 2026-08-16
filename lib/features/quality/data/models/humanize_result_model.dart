import '../../domain/entities/humanize_result.dart';
import '../../domain/enums/humanize_mode.dart';
import 'change_item_model.dart';

class HumanizeResultModel extends HumanizeResult {
  const HumanizeResultModel({
    required super.originalText,
    required super.humanizedText,
    required super.mode,
    required super.aiMarkerScoreBefore,
    required super.aiMarkerScoreAfter,
    required super.improvementPct,
    required super.burstinessBefore,
    required super.burstinessAfter,
    required super.changesCount,
    required super.changesSummary,
    required super.processingTimeMs,
  });

  factory HumanizeResultModel.fromJson(Map<String, dynamic> json, String originalText) {
    final modeStr = json['mode'] as String? ?? 'standard';
    final mode = modeStr == 'safe' ? HumanizeMode.safe : HumanizeMode.standard;

    final changesJson = json['changes_summary'] as List<dynamic>? ?? [];
    final changesSummary = changesJson
        .map((e) => ChangeItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return HumanizeResultModel(
      originalText: originalText,
      humanizedText: json['humanized_text'] as String? ?? '',
      mode: mode,
      aiMarkerScoreBefore: (json['ai_marker_score_before'] as num?)?.toDouble() ?? 0.0,
      aiMarkerScoreAfter: (json['ai_marker_score_after'] as num?)?.toDouble() ?? 0.0,
      improvementPct: (json['improvement_pct'] as num?)?.toDouble() ?? 0.0,
      burstinessBefore: (json['burstiness_before'] as num?)?.toDouble() ?? 0.0,
      burstinessAfter: (json['burstiness_after'] as num?)?.toDouble() ?? 0.0,
      changesCount: (json['changes_count'] as num?)?.toInt() ?? 0,
      changesSummary: changesSummary,
      processingTimeMs: (json['processing_time_ms'] as num?)?.toInt() ?? 0,
    );
  }
}
