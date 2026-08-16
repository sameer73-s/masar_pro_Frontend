import '../../domain/entities/manuscript_version.dart';

class ManuscriptVersionModel extends ManuscriptVersion {
  const ManuscriptVersionModel({
    required super.id,
    required super.projectId,
    required super.versionNumber,
    required super.fileType,
    required super.storageKey,
    required super.checksum,
    required super.createdAt,
    super.deduplicated,
    super.downloadUrl,
  });

  factory ManuscriptVersionModel.fromJson(Map<String, dynamic> json) {
    return ManuscriptVersionModel(
      id: json['id']?.toString() ?? '',
      projectId: (json['project_id'] ?? json['projectId'])?.toString() ?? '',
      versionNumber:
          _asInt(json['version_number'] ?? json['versionNumber']) ?? 1,
      fileType:
          (json['file_type'] ?? json['fileType'])?.toString() ?? 'ORIGINAL',
      storageKey:
          (json['storage_key'] ?? json['storageKey'])?.toString() ?? '',
      checksum: json['checksum']?.toString() ?? '',
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      deduplicated: json['deduplicated'] == true,
      downloadUrl: (json['download_url'] ?? json['downloadUrl'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'version_number': versionNumber,
      'file_type': fileType,
      'storage_key': storageKey,
      'checksum': checksum,
      'created_at': createdAt.toUtc().toIso8601String(),
      'deduplicated': deduplicated,
      'download_url': downloadUrl,
    };
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
