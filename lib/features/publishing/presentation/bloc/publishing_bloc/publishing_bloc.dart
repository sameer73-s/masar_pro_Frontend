import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/app_failure.dart';
import '../../../domain/entities/evidence.dart';
import '../../../domain/entities/journal_match.dart';
import '../../../domain/entities/manuscript_version.dart';
import '../../../domain/entities/readiness_report.dart';
import '../../../domain/entities/research_project.dart';
import '../../../domain/entities/response_item.dart';
import '../../../domain/entities/reviewer_comment.dart';
import '../../../domain/entities/submission.dart';
import '../../../domain/repositories/publishing_repository.dart';

part 'publishing_event.dart';
part 'publishing_state.dart';

class PublishingBloc extends Bloc<PublishingEvent, PublishingState> {
  final PublishingRepository repository;

  PublishingBloc({required this.repository})
      : super(const PublishingInitial()) {
    on<FetchResearchProjectsRequested>(_onFetchResearchProjectsRequested);
    on<CreateResearchRequested>(_onCreateResearchRequested);
    on<DeletePublishingProjectRequested>(_onDeletePublishingProjectRequested);
    on<UploadManuscriptRequested>(_onUploadManuscriptRequested);
    on<AnalyzeReadinessRequested>(_onAnalyzeReadinessRequested);
    on<MatchJournalsRequested>(_onMatchJournalsRequested);
    on<PrepareManuscriptRequested>(_onPrepareManuscriptRequested);
    on<CreateSubmissionRequested>(_onCreateSubmissionRequested);
    on<FetchSubmissionRequested>(_onFetchSubmissionRequested);
    on<AddEvidenceRequested>(_onAddEvidenceRequested);
    on<FetchReviewerCommentsRequested>(_onFetchReviewerCommentsRequested);
    on<AddReviewerCommentsRequested>(_onAddReviewerCommentsRequested);
    on<GenerateResponsesRequested>(_onGenerateResponsesRequested);
    on<UploadRevisionRequested>(_onUploadRevisionRequested);
  }

  List<ReviewerComment> _comments = const [];

  Future<void> _onFetchResearchProjectsRequested(
    FetchResearchProjectsRequested event,
    Emitter<PublishingState> emit,
  ) async {
    emit(const PublishingLoading('Loading publications...'));

    final result = await repository.getResearchProjects();
    result.fold(
      (failure) => emit(PublishingFailure(failure.message)),
      (projects) => emit(PublishingProjectsLoaded(projects)),
    );
  }

  Future<void> _onCreateResearchRequested(
    CreateResearchRequested event,
    Emitter<PublishingState> emit,
  ) async {
    emit(const PublishingLoading('Creating research...'));

    final result = await repository.createResearch(event.title);
    result.fold(
      (failure) => emit(PublishingFailure(failure.message)),
      (project) => emit(PublishingResearchCreated(project.id)),
    );
  }

  Future<void> _onDeletePublishingProjectRequested(
    DeletePublishingProjectRequested event,
    Emitter<PublishingState> emit,
  ) async {
    final previous = state;
    emit(const PublishingLoading('Deleting project...'));

    final result = await repository.deleteResearchProject(event.projectId);
    await result.fold(
      (failure) async => emit(PublishingFailure(failure.message)),
      (_) async {
        if (previous is PublishingProjectsLoaded) {
          final updated = previous.projects
              .where((project) => project.id != event.projectId)
              .toList();
          emit(PublishingProjectsLoaded(updated));
          return;
        }

        final refresh = await repository.getResearchProjects();
        refresh.fold(
          (failure) => emit(PublishingFailure(failure.message)),
          (projects) => emit(PublishingProjectsLoaded(projects)),
        );
      },
    );
  }

  Future<void> _onUploadManuscriptRequested(
    UploadManuscriptRequested event,
    Emitter<PublishingState> emit,
  ) async {
    emit(const PublishingLoading('Uploading manuscript...'));

    final platformFile = await _toPlatformFile(event.file);
    final result = await repository.uploadManuscript(
      event.projectId,
      platformFile,
    );
    result.fold(
      (failure) => emit(PublishingFailure(failure.message)),
      (version) => emit(PublishingManuscriptUploaded(version)),
    );
  }

  Future<void> _onAnalyzeReadinessRequested(
    AnalyzeReadinessRequested event,
    Emitter<PublishingState> emit,
  ) async {
    emit(const PublishingLoading('Analyzing research...'));

    final result = await repository.analyzeReadiness(event.projectId);
    result.fold(
      (failure) => emit(PublishingFailure(failure.message)),
      (report) => emit(PublishingReadinessAnalyzed(report)),
    );
  }

  Future<void> _onMatchJournalsRequested(
    MatchJournalsRequested event,
    Emitter<PublishingState> emit,
  ) async {
    emit(const PublishingLoading('Matching journals...'));

    final result = await repository.matchJournals(event.projectId);
    result.fold(
      (failure) => emit(PublishingFailure(failure.message)),
      (matches) => emit(PublishingJournalsMatched(matches)),
    );
  }

  Future<void> _onPrepareManuscriptRequested(
    PrepareManuscriptRequested event,
    Emitter<PublishingState> emit,
  ) async {
    emit(const PublishingLoading('Preparing manuscript...'));

    final result = await repository.prepareManuscript(
      event.projectId,
      event.journalId,
    );
    result.fold(
      (failure) => emit(PublishingFailure(failure.message)),
      (packageUrl) => emit(PublishingManuscriptPrepared(packageUrl)),
    );
  }

  Future<void> _onCreateSubmissionRequested(
    CreateSubmissionRequested event,
    Emitter<PublishingState> emit,
  ) async {
    emit(const PublishingLoading('Recording submission...'));

    final result = await repository.createSubmission(
      event.projectId,
      event.journalId,
      event.submissionId,
    );
    result.fold(
      (failure) => emit(PublishingFailure(failure.message)),
      (submission) => emit(PublishingSubmissionLoaded(submission, const [])),
    );
  }

  Future<void> _onFetchSubmissionRequested(
    FetchSubmissionRequested event,
    Emitter<PublishingState> emit,
  ) async {
    emit(const PublishingLoading('Loading submission...'));

    final result = await repository.getSubmissionDetails(event.projectId);
    result.fold(
      (failure) {
        if (_isSubmissionNotFound(failure)) {
          emit(const PublishingSubmissionEmpty());
        } else {
          emit(PublishingFailure(failure.message));
        }
      },
      (details) => emit(
        PublishingSubmissionLoaded(details.submission, details.evidence),
      ),
    );
  }

  Future<void> _onAddEvidenceRequested(
    AddEvidenceRequested event,
    Emitter<PublishingState> emit,
  ) async {
    final previous = state;
    emit(const PublishingLoading('Uploading evidence...'));

    final platformFile = await _toPlatformFile(event.file);
    final result = await repository.addEvidence(
      event.submissionId,
      platformFile,
    );
    result.fold(
      (failure) => emit(PublishingFailure(failure.message)),
      (evidence) {
        if (previous is PublishingSubmissionLoaded) {
          emit(
            PublishingSubmissionLoaded(
              previous.submission,
              [...previous.evidence, evidence],
            ),
          );
        } else {
          emit(
            PublishingFailure(
              'Evidence uploaded, but the submission could not be refreshed.',
            ),
          );
        }
      },
    );
  }

  Future<void> _onFetchReviewerCommentsRequested(
    FetchReviewerCommentsRequested event,
    Emitter<PublishingState> emit,
  ) async {
    emit(const PublishingLoading('Loading comments...'));

    final result = await repository.getComments(event.submissionId);
    result.fold(
      (failure) => emit(PublishingFailure(failure.message)),
      (comments) {
        _comments = comments;
        emit(PublishingCommentsLoaded(List.unmodifiable(_comments)));
      },
    );
  }

  Future<void> _onAddReviewerCommentsRequested(
    AddReviewerCommentsRequested event,
    Emitter<PublishingState> emit,
  ) async {
    emit(const PublishingLoading('Saving comments...'));

    final result = await repository.addComments(
      event.submissionId,
      event.comments,
    );
    result.fold(
      (failure) => emit(PublishingFailure(failure.message)),
      (added) {
        final existingIds = _comments.map((item) => item.id).toSet();
        final uniqueAdded = added
            .where((item) => item.id.isEmpty || !existingIds.contains(item.id))
            .toList();
        _comments = [..._comments, ...uniqueAdded];
        emit(PublishingCommentsLoaded(List.unmodifiable(_comments)));
      },
    );
  }

  Future<void> _onGenerateResponsesRequested(
    GenerateResponsesRequested event,
    Emitter<PublishingState> emit,
  ) async {
    emit(const PublishingLoading('Generating responses...'));

    final result = await repository.generateResponses(event.submissionId);
    result.fold(
      (failure) => emit(PublishingFailure(failure.message)),
      (responses) {
        _comments = _mergeResponses(_comments, responses);
        emit(PublishingResponsesGenerated(responses));
      },
    );
  }

  Future<void> _onUploadRevisionRequested(
    UploadRevisionRequested event,
    Emitter<PublishingState> emit,
  ) async {
    emit(const PublishingLoading('Uploading revision...'));

    final platformFile = await _toPlatformFile(event.file);
    final result = await repository.uploadRevision(
      event.submissionId,
      platformFile,
    );
    result.fold(
      (failure) => emit(PublishingFailure(failure.message)),
      (_) => emit(PublishingCommentsLoaded(List.unmodifiable(_comments))),
    );
  }

  List<ReviewerComment> _mergeResponses(
    List<ReviewerComment> comments,
    List<ResponseItem> responses,
  ) {
    if (responses.isEmpty) return comments;
    final byCommentId = <String, ResponseItem>{
      for (final item in responses)
        if (item.commentId.isNotEmpty) item.commentId: item,
    };
    return [
      for (final comment in comments)
        byCommentId.containsKey(comment.id)
            ? comment.copyWith(response: byCommentId[comment.id])
            : comment,
    ];
  }

  bool _isSubmissionNotFound(AppFailure failure) {
    if (failure.statusCode == 404) return true;
    final message = failure.message.toLowerCase();
    return message.contains('no submission found');
  }

  Future<PlatformFile> _toPlatformFile(File file) async {
    final segments = file.uri.pathSegments;
    final name = segments.isNotEmpty ? segments.last : file.path;
    return PlatformFile(
      name: name,
      path: file.path,
      size: await file.length(),
    );
  }
}
