import '../../domain/entities/academic_project.dart';

class AcademicProjectModel extends AcademicProject {
  const AcademicProjectModel({
    required super.id,
    required super.title,
    required super.academicLevel,
    required super.language,
    super.university,
    required super.proposalStatus,
    required super.researchStatus,
    required super.publishingStatus,
    super.proposalFileUrl,
    super.researchFileUrl,
    super.agencyTaskId,
    super.pubProjectId,
  });

  factory AcademicProjectModel.fromJson(Map<String, dynamic> json) {
    return AcademicProjectModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      academicLevel:
          json['academic_level']?.toString() ??
          json['academicLevel']?.toString() ??
          '',
      language: json['language']?.toString() ?? '',
      university: _nullableString(
        json['university'],
      ),
      proposalStatus:
          json['proposal_status']?.toString() ??
          json['proposalStatus']?.toString() ??
          'DRAFT',
      researchStatus:
          json['research_status']?.toString() ??
          json['researchStatus']?.toString() ??
          'NOT_STARTED',
      publishingStatus:
          json['publishing_status']?.toString() ??
          json['publishingStatus']?.toString() ??
          'NOT_STARTED',
      proposalFileUrl: _nullableString(
        json['proposal_file_url'] ?? json['proposalFileUrl'],
      ),
      researchFileUrl: _nullableString(
        json['research_file_url'] ?? json['researchFileUrl'],
      ),
      agencyTaskId: _nullableString(
        json['agency_task_id'] ?? json['agencyTaskId'],
      ),
      pubProjectId: _nullableString(
        json['pub_project_id'] ?? json['pubProjectId'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'academic_level': academicLevel,
      'language': language,
      'university': university,
      'proposal_status': proposalStatus,
      'research_status': researchStatus,
      'publishing_status': publishingStatus,
      'proposal_file_url': proposalFileUrl,
      'research_file_url': researchFileUrl,
      'agency_task_id': agencyTaskId,
      'pub_project_id': pubProjectId,
    };
  }

  factory AcademicProjectModel.fromEntity(AcademicProject entity) {
    return AcademicProjectModel(
      id: entity.id,
      title: entity.title,
      academicLevel: entity.academicLevel,
      language: entity.language,
      university: entity.university,
      proposalStatus: entity.proposalStatus,
      researchStatus: entity.researchStatus,
      publishingStatus: entity.publishingStatus,
      proposalFileUrl: entity.proposalFileUrl,
      researchFileUrl: entity.researchFileUrl,
      agencyTaskId: entity.agencyTaskId,
      pubProjectId: entity.pubProjectId,
    );
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
