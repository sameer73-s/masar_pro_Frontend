import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/journal_match.dart';
import '../../../domain/entities/manuscript_version.dart';
import '../../../domain/entities/readiness_report.dart';
import '../../../domain/entities/research_project.dart';
import '../../../domain/repositories/publishing_repository.dart';

part 'publishing_event.dart';
part 'publishing_state.dart';

class PublishingBloc extends Bloc<PublishingEvent, PublishingState> {
  final PublishingRepository repository;

  PublishingBloc({required this.repository})
      : super(const PublishingInitial()) {
    on<FetchResearchProjectsRequested>(_onFetchResearchProjectsRequested);
    on<CreateResearchRequested>(_onCreateResearchRequested);
    on<UploadManuscriptRequested>(_onUploadManuscriptRequested);
    on<AnalyzeReadinessRequested>(_onAnalyzeReadinessRequested);
    on<MatchJournalsRequested>(_onMatchJournalsRequested);
  }

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
