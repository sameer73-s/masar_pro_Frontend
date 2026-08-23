import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/academic_project.dart';
import '../../../domain/repositories/academic_project_repository.dart';

part 'research_module_event.dart';
part 'research_module_state.dart';

class ResearchModuleBloc
    extends Bloc<ResearchModuleEvent, ResearchModuleState> {
  final AcademicProjectRepository repository;

  ResearchModuleBloc({required this.repository})
      : super(const ResearchModuleInitial()) {
    on<LoadResearchProjectRequested>(_onLoadResearchProjectRequested);
    on<UploadResearchRequested>(_onUploadResearchRequested);
    on<ApproveResearchRequested>(_onApproveResearchRequested);
  }

  Future<void> _onLoadResearchProjectRequested(
    LoadResearchProjectRequested event,
    Emitter<ResearchModuleState> emit,
  ) async {
    emit(const ResearchModuleLoading());

    final result = await repository.getProjectDetails(event.projectId);
    result.fold(
      (failure) => emit(ResearchModuleFailure(failure.message)),
      (project) => emit(ResearchModuleLoaded(project)),
    );
  }

  Future<void> _onUploadResearchRequested(
    UploadResearchRequested event,
    Emitter<ResearchModuleState> emit,
  ) async {
    emit(const ResearchModuleLoading());

    final result = await repository.uploadResearch(
      event.projectId,
      event.file,
    );
    result.fold(
      (failure) => emit(ResearchModuleFailure(failure.message)),
      (project) => emit(ResearchModuleLoaded(project)),
    );
  }

  Future<void> _onApproveResearchRequested(
    ApproveResearchRequested event,
    Emitter<ResearchModuleState> emit,
  ) async {
    emit(const ResearchModuleLoading());

    final result = await repository.approveResearch(event.projectId);
    result.fold(
      (failure) => emit(ResearchModuleFailure(failure.message)),
      (project) => emit(ResearchModuleLoaded(project)),
    );
  }
}
