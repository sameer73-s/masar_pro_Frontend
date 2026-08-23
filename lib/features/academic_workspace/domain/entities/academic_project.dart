import 'package:equatable/equatable.dart';

class AcademicProject extends Equatable {
  final String id;
  final String title;
  final String academicLevel;
  final String language;
  final String? university;
  final String proposalStatus;
  final String researchStatus;
  final String publishingStatus;
  final String? proposalFileUrl;
  final String? researchFileUrl;
  final String? agencyTaskId;
  final String? pubProjectId;

  const AcademicProject({
    required this.id,
    required this.title,
    required this.academicLevel,
    required this.language,
    this.university,
    required this.proposalStatus,
    required this.researchStatus,
    required this.publishingStatus,
    this.proposalFileUrl,
    this.researchFileUrl,
    this.agencyTaskId,
    this.pubProjectId,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        academicLevel,
        language,
        university,
        proposalStatus,
        researchStatus,
        publishingStatus,
        proposalFileUrl,
        researchFileUrl,
        agencyTaskId,
        pubProjectId,
      ];
}
