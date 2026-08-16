import 'package:equatable/equatable.dart';

import '../enums/research_project_status.dart';

class ResearchProject extends Equatable {
  final String id;
  final String title;
  final ResearchProjectStatus status;
  final double readinessScore;
  final DateTime createdAt;

  const ResearchProject({
    required this.id,
    required this.title,
    required this.status,
    required this.readinessScore,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, status, readinessScore, createdAt];
}
