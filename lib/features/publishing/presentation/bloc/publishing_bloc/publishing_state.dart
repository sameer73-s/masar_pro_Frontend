part of 'publishing_bloc.dart';

abstract class PublishingState extends Equatable {
  const PublishingState();

  @override
  List<Object?> get props => [];
}

class PublishingInitial extends PublishingState {
  const PublishingInitial();
}

class PublishingLoading extends PublishingState {
  final String? message;

  const PublishingLoading([this.message]);

  @override
  List<Object?> get props => [message];
}

class PublishingProjectsLoaded extends PublishingState {
  final List<ResearchProject> projects;

  const PublishingProjectsLoaded(this.projects);

  @override
  List<Object?> get props => [projects];
}

class PublishingResearchCreated extends PublishingState {
  final String projectId;

  const PublishingResearchCreated(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class PublishingManuscriptUploaded extends PublishingState {
  final ManuscriptVersion version;

  const PublishingManuscriptUploaded(this.version);

  @override
  List<Object?> get props => [version];
}

class PublishingReadinessAnalyzed extends PublishingState {
  final ReadinessReport report;

  const PublishingReadinessAnalyzed(this.report);

  @override
  List<Object?> get props => [report];
}

class PublishingJournalsMatched extends PublishingState {
  final List<JournalMatch> matches;

  const PublishingJournalsMatched(this.matches);

  @override
  List<Object?> get props => [matches];
}

class PublishingFailure extends PublishingState {
  final String error;

  const PublishingFailure(this.error);

  @override
  List<Object?> get props => [error];
}
