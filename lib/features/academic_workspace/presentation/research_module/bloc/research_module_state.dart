part of 'research_module_bloc.dart';

abstract class ResearchModuleState extends Equatable {
  const ResearchModuleState();

  @override
  List<Object?> get props => [];
}

class ResearchModuleInitial extends ResearchModuleState {
  const ResearchModuleInitial();
}

class ResearchModuleLoading extends ResearchModuleState {
  const ResearchModuleLoading();
}

class ResearchModuleLoaded extends ResearchModuleState {
  final AcademicProject project;

  const ResearchModuleLoaded(this.project);

  @override
  List<Object?> get props => [project];
}

class ResearchModuleFailure extends ResearchModuleState {
  final String error;

  const ResearchModuleFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class ResearchModulePublishingStarted extends ResearchModuleState {
  final String pubProjectId;

  const ResearchModulePublishingStarted(this.pubProjectId);

  @override
  List<Object?> get props => [pubProjectId];
}
