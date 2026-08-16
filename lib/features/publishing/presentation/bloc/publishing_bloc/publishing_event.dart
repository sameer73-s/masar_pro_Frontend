part of 'publishing_bloc.dart';

abstract class PublishingEvent extends Equatable {
  const PublishingEvent();

  @override
  List<Object?> get props => [];
}

class FetchResearchProjectsRequested extends PublishingEvent {
  const FetchResearchProjectsRequested();
}

class CreateResearchRequested extends PublishingEvent {
  final String title;

  const CreateResearchRequested(this.title);

  @override
  List<Object?> get props => [title];
}

class UploadManuscriptRequested extends PublishingEvent {
  final String projectId;
  final File file;

  const UploadManuscriptRequested(this.projectId, this.file);

  @override
  List<Object?> get props => [projectId, file.path];
}

class AnalyzeReadinessRequested extends PublishingEvent {
  final String projectId;

  const AnalyzeReadinessRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class MatchJournalsRequested extends PublishingEvent {
  final String projectId;

  const MatchJournalsRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}
