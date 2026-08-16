import '../../domain/entities/research_project.dart';
import '../../domain/enums/research_project_status.dart';

class ResearchProjectModel extends ResearchProject {
  const ResearchProjectModel({
    required super.id,
    required super.title,
    required super.status,
    required super.readinessScore,
    required super.createdAt,
  });

  factory ResearchProjectModel.fromJson(Map<String, dynamic> json) {
    return ResearchProjectModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: ResearchProjectStatus.fromApi(json['status']?.toString()),
      readinessScore: _readinessScoreFromJson(json),
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status.apiValue,
      'readiness_score': readinessScore,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  factory ResearchProjectModel.fromEntity(ResearchProject entity) {
    return ResearchProjectModel(
      id: entity.id,
      title: entity.title,
      status: entity.status,
      readinessScore: entity.readinessScore,
      createdAt: entity.createdAt,
    );
  }

  static double _readinessScoreFromJson(Map<String, dynamic> json) {
    final direct = json['readiness_score'] ?? json['readinessScore'];
    if (direct is num) return direct.toDouble();
    if (direct is String) return double.tryParse(direct) ?? 0;

    final report = json['readiness_report'] ?? json['readinessReport'];
    if (report is Map) {
      final score = report['overall_score'] ?? report['overallScore'];
      if (score is num) return score.toDouble();
      if (score is String) return double.tryParse(score) ?? 0;
    }
    return 0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
