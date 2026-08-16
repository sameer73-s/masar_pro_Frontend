import '../enums/research_status.dart';

class ResearchJob {
  final String jobId;
  final String title;
  final ResearchStatus status;
  final String downloadUrl; // متاح عند status == completed
  final int totalWords;
  final int sourcesCount;
  final int processingTimeSeconds;
  final DateTime createdAt;

  const ResearchJob({
    required this.jobId,
    required this.title,
    required this.status,
    required this.downloadUrl,
    required this.totalWords,
    required this.sourcesCount,
    required this.processingTimeSeconds,
    required this.createdAt,
  });
}
