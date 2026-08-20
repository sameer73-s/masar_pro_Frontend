import '../../domain/entities/revision.dart';

class RevisionModel extends Revision {
  const RevisionModel({
    required super.id,
    required super.submissionId,
    required super.versionNumber,
    required super.storageKey,
    super.downloadUrl,
    super.submissionStatus,
  });

  factory RevisionModel.fromJson(Map<String, dynamic> json) {
    return RevisionModel(
      id: json['id']?.toString() ?? '',
      submissionId:
          (json['submission_id'] ?? json['submissionId'])?.toString() ?? '',
      versionNumber: _asInt(json['version_number'] ?? json['versionNumber']),
      storageKey:
          (json['storage_key'] ?? json['storageKey'])?.toString() ?? '',
      downloadUrl: (json['download_url'] ?? json['downloadUrl'])?.toString(),
      submissionStatus:
          (json['submission_status'] ?? json['submissionStatus'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'submission_id': submissionId,
      'version_number': versionNumber,
      'storage_key': storageKey,
      'download_url': downloadUrl,
      'submission_status': submissionStatus,
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }
}
