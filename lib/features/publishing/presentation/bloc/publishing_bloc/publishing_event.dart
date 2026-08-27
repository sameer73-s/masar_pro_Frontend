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

class DeletePublishingProjectRequested extends PublishingEvent {
  final String projectId;

  const DeletePublishingProjectRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
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

class PrepareManuscriptRequested extends PublishingEvent {
  final String projectId;
  final String journalId;

  const PrepareManuscriptRequested(this.projectId, this.journalId);

  @override
  List<Object?> get props => [projectId, journalId];
}

class CreateSubmissionRequested extends PublishingEvent {
  final String projectId;
  final String journalId;
  final String submissionId;

  const CreateSubmissionRequested(
    this.projectId,
    this.journalId,
    this.submissionId,
  );

  @override
  List<Object?> get props => [projectId, journalId, submissionId];
}

class FetchSubmissionRequested extends PublishingEvent {
  final String projectId;

  const FetchSubmissionRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class AddEvidenceRequested extends PublishingEvent {
  final String submissionId;
  final File file;

  const AddEvidenceRequested(this.submissionId, this.file);

  @override
  List<Object?> get props => [submissionId, file.path];
}

class FetchReviewerCommentsRequested extends PublishingEvent {
  final String submissionId;

  const FetchReviewerCommentsRequested(this.submissionId);

  @override
  List<Object?> get props => [submissionId];
}

class AddReviewerCommentsRequested extends PublishingEvent {
  final String submissionId;
  final List<String> comments;

  const AddReviewerCommentsRequested(this.submissionId, this.comments);

  @override
  List<Object?> get props => [submissionId, comments];
}

class GenerateResponsesRequested extends PublishingEvent {
  final String submissionId;

  const GenerateResponsesRequested(this.submissionId);

  @override
  List<Object?> get props => [submissionId];
}

class StartAutomatedSubmissionRequested extends PublishingEvent {
  final String projectId;
  final String journalId;
  final String targetUrl;
  final String fileId;

  const StartAutomatedSubmissionRequested({
    required this.projectId,
    required this.journalId,
    required this.targetUrl,
    required this.fileId,
  });

  @override
  List<Object?> get props => [projectId, journalId, targetUrl, fileId];
}

class SubmissionProgressReceived extends PublishingEvent {
  final SubmissionProgressUpdate progress;

  const SubmissionProgressReceived(this.progress);

  @override
  List<Object?> get props => [progress];
}

class SubmissionProgressStreamFailed extends PublishingEvent {
  final String error;

  const SubmissionProgressStreamFailed(this.error);

  @override
  List<Object?> get props => [error];
}

class StopAutomatedSubmissionMonitoringRequested extends PublishingEvent {
  const StopAutomatedSubmissionMonitoringRequested();
}

class UploadRevisionRequested extends PublishingEvent {
  final String submissionId;
  final File file;

  const UploadRevisionRequested(this.submissionId, this.file);

  @override
  List<Object?> get props => [submissionId, file.path];
}
