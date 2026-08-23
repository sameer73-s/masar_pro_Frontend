part of 'academic_workspace_bloc.dart';

abstract class AcademicWorkspaceEvent extends Equatable {
  const AcademicWorkspaceEvent();

  @override
  List<Object?> get props => [];
}

class FetchAcademicProjectsRequested extends AcademicWorkspaceEvent {
  const FetchAcademicProjectsRequested();
}

class CreateAcademicProjectRequested extends AcademicWorkspaceEvent {
  final String title;
  final String academicLevel;
  final String language;
  final String? university;

  const CreateAcademicProjectRequested({
    required this.title,
    required this.academicLevel,
    required this.language,
    this.university,
  });

  @override
  List<Object?> get props => [title, academicLevel, language, university];
}

class UpdatePhaseStatusRequested extends AcademicWorkspaceEvent {
  final String projectId;
  final AcademicPhase phase;
  final String status;

  const UpdatePhaseStatusRequested({
    required this.projectId,
    required this.phase,
    required this.status,
  });

  @override
  List<Object?> get props => [projectId, phase, status];
}
