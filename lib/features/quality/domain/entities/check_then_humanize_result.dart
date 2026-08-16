class CheckThenHumanizeResult {
  final double beforeScore;
  final double? afterScore;
  final String? humanizedText;
  final bool needsHumanization;
  final String? downloadUrl;
  final String? reportUrl;

  const CheckThenHumanizeResult({
    required this.beforeScore,
    this.afterScore,
    this.humanizedText,
    required this.needsHumanization,
    this.downloadUrl,
    this.reportUrl,
  });
}
