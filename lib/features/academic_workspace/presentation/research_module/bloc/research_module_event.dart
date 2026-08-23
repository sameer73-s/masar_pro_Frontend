part of 'research_module_bloc.dart';

abstract class ResearchModuleEvent extends Equatable {
  const ResearchModuleEvent();

  @override
  List<Object?> get props => [];
}

class LoadResearchProjectRequested extends ResearchModuleEvent {
  final String projectId;

  const LoadResearchProjectRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class UploadResearchRequested extends ResearchModuleEvent {
  final String projectId;
  final File file;

  const UploadResearchRequested({
    required this.projectId,
    required this.file,
  });

  @override
  List<Object?> get props => [projectId, file.path];
}

class ApproveResearchRequested extends ResearchModuleEvent {
  final String projectId;

  const ApproveResearchRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class StartPublishingRequested extends ResearchModuleEvent {
  final String projectId;

  const StartPublishingRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}
