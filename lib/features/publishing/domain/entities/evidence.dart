import 'package:equatable/equatable.dart';

class Evidence extends Equatable {
  final String id;
  final String submissionId;
  final String fileType;
  final String storageKey;
  final DateTime capturedAt;
  final String notes;
  final String? downloadUrl;

  const Evidence({
    required this.id,
    required this.submissionId,
    required this.fileType,
    required this.storageKey,
    required this.capturedAt,
    this.notes = '',
    this.downloadUrl,
  });

  String get displayName {
    final trimmedNotes = notes.trim();
    if (trimmedNotes.isNotEmpty) return trimmedNotes;

    final segments = storageKey.split('/');
    final last = segments.isNotEmpty ? segments.last : '';
    if (last.isNotEmpty) return last;

    return fileType.replaceAll('_', ' ');
  }

  @override
  List<Object?> get props => [
        id,
        submissionId,
        fileType,
        storageKey,
        capturedAt,
        notes,
        downloadUrl,
      ];
}
