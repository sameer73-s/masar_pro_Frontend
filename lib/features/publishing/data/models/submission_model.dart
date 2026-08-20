import '../../domain/entities/submission.dart';
import '../../domain/enums/submission_status.dart';
import 'evidence_model.dart';

class SubmissionModel extends Submission {
  const SubmissionModel({
    required super.id,
    required super.projectId,
    required super.journalId,
    required super.status,
    required super.submissionId,
    required super.submittedAt,
    required super.updatedAt,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id']?.toString() ?? '',
      projectId: (json['project_id'] ?? json['projectId'])?.toString() ?? '',
      journalId: (json['journal_id'] ?? json['journalId'])?.toString() ?? '',
      status: SubmissionStatus.fromApi(
        (json['status'] ?? json['submission_status'])?.toString(),
      ),
      submissionId:
          (json['submission_id'] ?? json['submissionId'] ?? json['tracking_number'])
              ?.toString() ??
          '',
      submittedAt: _parseDateTime(json['submitted_at'] ?? json['submittedAt']),
      updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'journal_id': journalId,
      'status': status.apiValue,
      'submission_id': submissionId,
      'submitted_at': submittedAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

class SubmissionDetailsModel extends SubmissionDetails {
  const SubmissionDetailsModel({
    required super.submission,
    required super.evidence,
  });

  factory SubmissionDetailsModel.fromJson(Map<String, dynamic> json) {
    final submissionRaw = json['submission'];
    final submissionMap = submissionRaw is Map
        ? Map<String, dynamic>.from(submissionRaw)
        : json;

    final evidenceRaw = json['evidence'] ?? json['timeline'];
    final evidenceItems = <EvidenceModel>[];
    if (evidenceRaw is List) {
      for (final item in evidenceRaw) {
        if (item is Map) {
          evidenceItems.add(
            EvidenceModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return SubmissionDetailsModel(
      submission: SubmissionModel.fromJson(submissionMap),
      evidence: evidenceItems,
    );
  }
}
