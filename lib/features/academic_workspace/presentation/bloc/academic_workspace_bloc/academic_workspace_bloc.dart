import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/academic_project.dart';
import '../../../domain/enums/academic_phase.dart';
import '../../../domain/repositories/academic_project_repository.dart';

part 'academic_workspace_event.dart';
part 'academic_workspace_state.dart';

class AcademicWorkspaceBloc
    extends Bloc<AcademicWorkspaceEvent, AcademicWorkspaceState> {
  final AcademicProjectRepository repository;

  AcademicWorkspaceBloc({required this.repository})
      : super(const AcademicWorkspaceInitial()) {
    on<FetchAcademicProjectsRequested>(_onFetchAcademicProjectsRequested);
    on<CreateAcademicProjectRequested>(_onCreateAcademicProjectRequested);
    on<UpdatePhaseStatusRequested>(_onUpdatePhaseStatusRequested);
    on<SubmitFeedbackRequested>(_onSubmitFeedbackRequested);
    on<DeleteAcademicProjectRequested>(_onDeleteAcademicProjectRequested);
  }

  Future<void> _onFetchAcademicProjectsRequested(
    FetchAcademicProjectsRequested event,
    Emitter<AcademicWorkspaceState> emit,
  ) async {
    emit(const AcademicWorkspaceLoading());

    final result = await repository.getProjects();
    result.fold(
      (failure) => emit(AcademicWorkspaceFailure(failure.message)),
      (projects) => emit(AcademicProjectsLoaded(projects)),
    );
  }

  Future<void> _onCreateAcademicProjectRequested(
    CreateAcademicProjectRequested event,
    Emitter<AcademicWorkspaceState> emit,
  ) async {
    emit(const AcademicWorkspaceLoading());

    final result = await repository.createProject(
      title: event.title,
      academicLevel: event.academicLevel,
      language: event.language,
      university: event.university,
    );
    result.fold(
      (failure) => emit(AcademicWorkspaceFailure(failure.message)),
      (project) => emit(AcademicProjectCreated(project)),
    );
  }

  Future<void> _onUpdatePhaseStatusRequested(
    UpdatePhaseStatusRequested event,
    Emitter<AcademicWorkspaceState> emit,
  ) async {
    emit(const AcademicWorkspaceLoading());

    final result = await repository.updatePhaseStatus(
      event.projectId,
      event.phase,
      event.status,
    );
    result.fold(
      (failure) => emit(AcademicWorkspaceFailure(failure.message)),
      (_) => emit(
        AcademicPhaseStatusUpdated(
          event.projectId,
          event.phase,
          event.status,
        ),
      ),
    );
  }

  Future<void> _onSubmitFeedbackRequested(
    SubmitFeedbackRequested event,
    Emitter<AcademicWorkspaceState> emit,
  ) async {
    emit(const AcademicWorkspaceLoading());

    final result = await repository.submitFeedback(
      projectId: event.projectId,
      feedbackText: event.feedbackText,
      instructions: event.instructions,
      source: event.source,
    );
    result.fold(
      (failure) => emit(AcademicWorkspaceFailure(failure.message)),
      (fileUrl) => emit(FeedbackProcessed(fileUrl)),
    );
  }

  Future<void> _onDeleteAcademicProjectRequested(
    DeleteAcademicProjectRequested event,
    Emitter<AcademicWorkspaceState> emit,
  ) async {
    final previous = state;
    emit(const AcademicWorkspaceLoading());

    final result = await repository.deleteAcademicProject(event.projectId);
    await result.fold(
      (failure) async => emit(AcademicWorkspaceFailure(failure.message)),
      (_) async {
        if (previous is AcademicProjectsLoaded) {
          final updated = previous.projects
              .where((project) => project.id != event.projectId)
              .toList();
          emit(AcademicProjectsLoaded(updated));
          return;
        }

        final refresh = await repository.getProjects();
        refresh.fold(
          (failure) => emit(AcademicWorkspaceFailure(failure.message)),
          (projects) => emit(AcademicProjectsLoaded(projects)),
        );
      },
    );
  }
}
