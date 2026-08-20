import 'package:equatable/equatable.dart';

import '../enums/submission_status.dart';
import 'evidence.dart';

class Submission extends Equatable {
  final String id;
  final String projectId;
  final String journalId;
  final SubmissionStatus status;
  final String submissionId;
  final DateTime submittedAt;
  final DateTime updatedAt;

  const Submission({
    required this.id,
    required this.projectId,
    required this.journalId,
    required this.status,
    required this.submissionId,
    required this.submittedAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        projectId,
        journalId,
        status,
        submissionId,
        submittedAt,
        updatedAt,
      ];
}

class SubmissionDetails extends Equatable {
  final Submission submission;
  final List<Evidence> evidence;

  const SubmissionDetails({
    required this.submission,
    required this.evidence,
  });

  @override
  List<Object?> get props => [submission, evidence];
}
