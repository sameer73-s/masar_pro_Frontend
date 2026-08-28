import 'package:equatable/equatable.dart';

class AutomatedSubmissionJob extends Equatable {
  final String jobId;
  final String status;

  const AutomatedSubmissionJob({required this.jobId, required this.status});

  @override
  List<Object?> get props => [jobId, status];
}

class SubmissionProgressUpdate extends Equatable {
  final String state;
  final String message;
  final double progress;
  final String? challengeType;
  final DateTime? occurredAt;

  const SubmissionProgressUpdate({
    required this.state,
    required this.message,
    required this.progress,
    this.challengeType,
    this.occurredAt,
  });

  bool get isHumanActionRequired =>
      state.toUpperCase() == 'HUMAN_ACTION_REQUIRED';
  bool get isCompleted => state.toUpperCase() == 'COMPLETED';

  @override
  List<Object?> get props => [
    state,
    message,
    progress,
    challengeType,
    occurredAt,
  ];
}
