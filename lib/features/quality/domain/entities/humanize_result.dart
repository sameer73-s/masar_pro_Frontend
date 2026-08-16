import 'change_item.dart';
import '../enums/humanize_mode.dart';

class HumanizeResult {
  final String originalText;
  final String humanizedText;
  final HumanizeMode mode;
  final double aiMarkerScoreBefore;
  final double aiMarkerScoreAfter;
  final double improvementPct;
  final double burstinessBefore;
  final double burstinessAfter;
  final int changesCount;
  final List<ChangeItem> changesSummary;
  final int processingTimeMs;

  const HumanizeResult({
    required this.originalText,
    required this.humanizedText,
    required this.mode,
    required this.aiMarkerScoreBefore,
    required this.aiMarkerScoreAfter,
    required this.improvementPct,
    required this.burstinessBefore,
    required this.burstinessAfter,
    required this.changesCount,
    required this.changesSummary,
    required this.processingTimeMs,
  });

  bool get isImproved => improvementPct > 0;
}
