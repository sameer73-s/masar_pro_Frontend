import '../../domain/entities/evidence.dart';

class EvidenceModel extends Evidence {
  const EvidenceModel({
    required super.id,
    required super.submissionId,
    required super.fileType,
    required super.storageKey,
    required super.capturedAt,
    super.notes,
    super.downloadUrl,
  });

  factory EvidenceModel.fromJson(Map<String, dynamic> json) {
    return EvidenceModel(
      id: json['id']?.toString() ?? '',
      submissionId:
          (json['submission_id'] ?? json['submissionId'])?.toString() ?? '',
      fileType: (json['file_type'] ?? json['fileType'])?.toString() ??
          'SCREENSHOT',
      storageKey:
          (json['storage_key'] ?? json['storageKey'])?.toString() ?? '',
      capturedAt: _parseDateTime(json['captured_at'] ?? json['capturedAt']),
      notes: json['notes']?.toString() ?? '',
      downloadUrl: (json['download_url'] ?? json['downloadUrl'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'submission_id': submissionId,
      'file_type': fileType,
      'storage_key': storageKey,
      'captured_at': capturedAt.toUtc().toIso8601String(),
      'notes': notes,
      'download_url': downloadUrl,
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
