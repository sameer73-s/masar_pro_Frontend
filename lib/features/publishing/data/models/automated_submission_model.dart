import '../../domain/entities/automated_submission.dart';

class AutomatedSubmissionJobModel {
  final String jobId;
  final String status;

  const AutomatedSubmissionJobModel({
    required this.jobId,
    required this.status,
  });

  factory AutomatedSubmissionJobModel.fromJson(Map<String, dynamic> json) {
    return AutomatedSubmissionJobModel(
      jobId: (json['job_id'] ?? json['id'] ?? '').toString(),
      status: (json['status'] ?? 'QUEUED').toString(),
    );
  }

  AutomatedSubmissionJob toEntity() =>
      AutomatedSubmissionJob(jobId: jobId, status: status);
}

class SubmissionProgressUpdateModel {
  final String state;
  final String message;
  final double progress;
  final String? challengeType;
  final DateTime? occurredAt;

  const SubmissionProgressUpdateModel({
    required this.state,
    required this.message,
    required this.progress,
    this.challengeType,
    this.occurredAt,
  });

  factory SubmissionProgressUpdateModel.fromEnvelope(dynamic raw) {
    final decoded = raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};
    final nested = decoded['data'];
    final payload = nested is Map ? Map<String, dynamic>.from(nested) : decoded;

    final state =
        (payload['state'] ??
                payload['status'] ??
                decoded['state'] ??
                decoded['status'] ??
                'QUEUED')
            .toString()
            .toUpperCase();
    final message =
        (payload['message'] ??
                payload['current_step'] ??
                decoded['message'] ??
                '')
            .toString();
    final rawProgress =
        payload['progress'] ??
        payload['progress_pct'] ??
        decoded['progress'] ??
        0;
    final progress = _toProgress(rawProgress);
    final challenge =
        payload['challenge_type'] ??
        payload['challengeType'] ??
        decoded['challenge_type'] ??
        decoded['challengeType'];
    final occurred =
        payload['occurred_at'] ??
        payload['occurredAt'] ??
        decoded['occurred_at'] ??
        decoded['occurredAt'];

    return SubmissionProgressUpdateModel(
      state: state,
      message: message,
      progress: progress,
      challengeType: challenge?.toString(),
      occurredAt: _toDateTime(occurred),
    );
  }

  SubmissionProgressUpdate toEntity() => SubmissionProgressUpdate(
    state: state,
    message: message,
    progress: progress,
    challengeType: challengeType,
    occurredAt: occurredAt,
  );

  static double _toProgress(dynamic value) {
    if (value is num) {
      final numeric = value.toDouble();
      return numeric > 1 ? (numeric / 100).clamp(0, 1) : numeric.clamp(0, 1);
    }
    return double.tryParse(value?.toString() ?? '')?.clamp(0, 1) ?? 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
