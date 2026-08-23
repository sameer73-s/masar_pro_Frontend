part of 'academic_workspace_bloc.dart';

abstract class AcademicWorkspaceState extends Equatable {
  const AcademicWorkspaceState();

  @override
  List<Object?> get props => [];
}

class AcademicWorkspaceInitial extends AcademicWorkspaceState {
  const AcademicWorkspaceInitial();
}

class AcademicWorkspaceLoading extends AcademicWorkspaceState {
  const AcademicWorkspaceLoading();
}

class AcademicProjectsLoaded extends AcademicWorkspaceState {
  final List<AcademicProject> projects;

  const AcademicProjectsLoaded(this.projects);

  @override
  List<Object?> get props => [projects];
}

class AcademicProjectCreated extends AcademicWorkspaceState {
  final AcademicProject project;

  const AcademicProjectCreated(this.project);

  @override
  List<Object?> get props => [project];
}

class AcademicPhaseStatusUpdated extends AcademicWorkspaceState {
  final String projectId;
  final AcademicPhase phase;
  final String status;

  const AcademicPhaseStatusUpdated(
    this.projectId,
    this.phase,
    this.status,
  );

  @override
  List<Object?> get props => [projectId, phase, status];
}

class FeedbackProcessed extends AcademicWorkspaceState {
  final String fileUrl;

  const FeedbackProcessed(this.fileUrl);

  @override
  List<Object?> get props => [fileUrl];
}

class AcademicWorkspaceFailure extends AcademicWorkspaceState {
  final String error;

  const AcademicWorkspaceFailure(this.error);

  @override
  List<Object?> get props => [error];
}
