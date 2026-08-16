import '../../domain/entities/sentence_match.dart';

class SentenceMatchModel extends SentenceMatch {
  const SentenceMatchModel({
    required super.sentence,
    required super.similarityPct,
    required super.isFlagged,
    super.topSource,
  });

  factory SentenceMatchModel.fromJson(Map<String, dynamic> json) {
    return SentenceMatchModel(
      sentence: json['sentence'] as String,
      similarityPct: (json['similarity_pct'] as num).toInt(),
      isFlagged: json['is_flagged'] as bool,
      topSource: json['top_source'] as String?,
    );
  }
}
