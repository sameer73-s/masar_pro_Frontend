import '../../domain/entities/audit_result.dart';
import '../../domain/enums/risk_level.dart';
import 'sentence_match_model.dart';

class AuditResultModel extends AuditResult {
  const AuditResultModel({
    required super.success,
    required super.overallSimilarity,
    required super.plagiarismPercentage,
    required super.riskLevel,
    required super.totalSentences,
    required super.flaggedSentences,
    required super.wordCount,
    required super.sentenceResults,
    required super.processingTimeMs,
    super.error,
    super.downloadUrl,
    super.reportUrl,
  });

  factory AuditResultModel.fromJson(Map<String, dynamic> json) {
    final sentencesJson = json['sentence_results'] as List<dynamic>? ?? [];
    final sentenceResults = sentencesJson
        .map((e) => SentenceMatchModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final plagiarism = (json['plagiarism_percentage'] as num?)?.toInt() ??
        (json['overall_similarity'] as num?)?.toInt() ??
        0;

    return AuditResultModel(
      success: json['success'] as bool? ?? true,
      overallSimilarity: (json['overall_similarity'] as num?)?.toInt() ?? plagiarism,
      plagiarismPercentage: plagiarism,
      riskLevel: RiskLevel.fromApi(json['risk_level'] as String? ?? 'high'),
      totalSentences: (json['total_sentences'] as num?)?.toInt() ?? 0,
      flaggedSentences: (json['flagged_sentences'] as num?)?.toInt() ?? 0,
      wordCount: (json['word_count'] as num?)?.toInt() ?? 0,
      sentenceResults: sentenceResults,
      processingTimeMs: (json['processing_time_ms'] as num?)?.toInt() ?? 0,
      error: json['error'] as String?,
      downloadUrl: json['download_url'] as String?,
      reportUrl: json['report_url'] as String?,
    );
  }
}
