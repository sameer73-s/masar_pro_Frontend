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

class PublishingSubmissionStarted extends PublishingState {
  final AutomatedSubmissionJob job;

  const PublishingSubmissionStarted(this.job);

  @override
  List<Object?> get props => [job];
}

class SubmissionStepProgress extends PublishingState {
  final String state;
  final String message;
  final double progress;

  const SubmissionStepProgress({
    required this.state,
    required this.message,
    required this.progress,
  });

  @override
  List<Object?> get props => [state, message, progress];
}

class HumanActionRequired extends PublishingState {
  final String challengeType;

  const HumanActionRequired(this.challengeType);

  @override
  List<Object?> get props => [challengeType];
}

class SubmissionCompleted extends PublishingState {
  final String message;

  const SubmissionCompleted([this.message = 'Submission dry run completed.']);

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

class PublishingManuscriptPrepared extends PublishingState {
  final String packageUrl;

  const PublishingManuscriptPrepared(this.packageUrl);

  @override
  List<Object?> get props => [packageUrl];
}

class PublishingSubmissionEmpty extends PublishingState {
  const PublishingSubmissionEmpty();
}

class PublishingSubmissionLoaded extends PublishingState {
  final Submission submission;
  final List<Evidence> evidence;

  const PublishingSubmissionLoaded(this.submission, this.evidence);

  @override
  List<Object?> get props => [submission, evidence];
}

class PublishingCommentsLoaded extends PublishingState {
  final List<ReviewerComment> comments;

  const PublishingCommentsLoaded(this.comments);

  @override
  List<Object?> get props => [comments];
}

class PublishingResponsesGenerated extends PublishingState {
  final List<ResponseItem> responses;

  const PublishingResponsesGenerated(this.responses);

  @override
  List<Object?> get props => [responses];
}

class PublishingFailure extends PublishingState {
  final String error;

  const PublishingFailure(this.error);

  @override
  List<Object?> get props => [error];
}
