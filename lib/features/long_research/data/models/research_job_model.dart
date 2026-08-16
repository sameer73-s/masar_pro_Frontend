import 'package:hive/hive.dart';
import '../../domain/entities/research_job.dart';
import '../../domain/enums/research_status.dart';

part 'research_job_model.g.dart';

@HiveType(typeId: 10)
class ResearchJobModel extends HiveObject {
  @HiveField(0)
  final String jobId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String statusName;

  @HiveField(3)
  final String downloadUrl;

  @HiveField(4)
  final int totalWords;

  @HiveField(5)
  final int sourcesCount;

  @HiveField(6)
  final int processingTimeSeconds;

  @HiveField(7)
  final DateTime createdAt;

  ResearchJobModel({
    required this.jobId,
    required this.title,
    required this.statusName,
    required this.downloadUrl,
    required this.totalWords,
    required this.sourcesCount,
    required this.processingTimeSeconds,
    required this.createdAt,
  });

  factory ResearchJobModel.fromJson(Map<String, dynamic> json) {
    return ResearchJobModel(
      jobId: json['job_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      statusName: json['status'] as String? ?? 'pending',
      downloadUrl: json['download_url'] as String? ?? '',
      totalWords: json['total_words'] as int? ?? 0,
      sourcesCount: json['sources_count'] as int? ?? 0,
      processingTimeSeconds: json['processing_time_seconds'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  factory ResearchJobModel.fromEntity(ResearchJob job) {
    return ResearchJobModel(
      jobId: job.jobId,
      title: job.title,
      statusName: job.status.name,
      downloadUrl: job.downloadUrl,
      totalWords: job.totalWords,
      sourcesCount: job.sourcesCount,
      processingTimeSeconds: job.processingTimeSeconds,
      createdAt: job.createdAt,
    );
  }

  ResearchJob toEntity() {
    return ResearchJob(
      jobId: jobId,
      title: title,
      status: ResearchStatus.fromApi(statusName),
      downloadUrl: downloadUrl,
      totalWords: totalWords,
      sourcesCount: sourcesCount,
      processingTimeSeconds: processingTimeSeconds,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'title': title,
      'status': statusName,
      'download_url': downloadUrl,
      'total_words': totalWords,
      'sources_count': sourcesCount,
      'processing_time_seconds': processingTimeSeconds,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
