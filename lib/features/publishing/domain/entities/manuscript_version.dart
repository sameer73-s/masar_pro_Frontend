import 'package:equatable/equatable.dart';

/// Upload-manuscript API payload (`ManuscriptVersionPublic`).
class ManuscriptVersion extends Equatable {
  final String id;
  final String projectId;
  final int versionNumber;
  final String fileType;
  final String storageKey;
  final String checksum;
  final DateTime createdAt;
  final bool deduplicated;
  final String? downloadUrl;

  const ManuscriptVersion({
    required this.id,
    required this.projectId,
    required this.versionNumber,
    required this.fileType,
    required this.storageKey,
    required this.checksum,
    required this.createdAt,
    this.deduplicated = false,
    this.downloadUrl,
  });

  @override
  List<Object?> get props => [
        id,
        projectId,
        versionNumber,
        fileType,
        storageKey,
        checksum,
        createdAt,
        deduplicated,
        downloadUrl,
      ];
}
