class SentenceMatch {
  final String sentence;
  final int similarityPct;
  final bool isFlagged;
  final String? topSource;

  const SentenceMatch({
    required this.sentence,
    required this.similarityPct,
    required this.isFlagged,
    this.topSource,
  });
}
