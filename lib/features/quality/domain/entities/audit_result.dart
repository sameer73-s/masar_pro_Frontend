import '../enums/risk_level.dart';
import 'sentence_match.dart';

class AuditResult {
  final bool success;
  final int overallSimilarity;
  final int plagiarismPercentage;
  final RiskLevel riskLevel;
  final int totalSentences;
  final int flaggedSentences;
  final int wordCount;
  final List<SentenceMatch> sentenceResults;
  final int processingTimeMs;
  final String? error;
  final String? downloadUrl;
  final String? reportUrl;

  const AuditResult({
    required this.success,
    required this.overallSimilarity,
    required this.plagiarismPercentage,
    required this.riskLevel,
    required this.totalSentences,
    required this.flaggedSentences,
    required this.wordCount,
    required this.sentenceResults,
    required this.processingTimeMs,
    this.error,
    this.downloadUrl,
    this.reportUrl,
  });

  bool get isPassing => plagiarismPercentage < 35;
  double get safetyScore => 100 - plagiarismPercentage.toDouble();
}
