import 'package:equatable/equatable.dart';

class Revision extends Equatable {
  final String id;
  final String submissionId;
  final int versionNumber;
  final String storageKey;
  final String? downloadUrl;
  final String? submissionStatus;

  const Revision({
    required this.id,
    required this.submissionId,
    required this.versionNumber,
    required this.storageKey,
    this.downloadUrl,
    this.submissionStatus,
  });

  @override
  List<Object?> get props => [
        id,
        submissionId,
        versionNumber,
        storageKey,
        downloadUrl,
        submissionStatus,
      ];
}
