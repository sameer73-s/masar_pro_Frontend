import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/academic_project.dart';
import '../../../domain/repositories/academic_project_repository.dart';

part 'proposal_module_event.dart';
part 'proposal_module_state.dart';

class ProposalModuleBloc
    extends Bloc<ProposalModuleEvent, ProposalModuleState> {
  final AcademicProjectRepository repository;

  ProposalModuleBloc({required this.repository})
      : super(const ProposalModuleInitial()) {
    on<LoadProposalProjectRequested>(_onLoadProposalProjectRequested);
    on<UploadProposalRequested>(_onUploadProposalRequested);
    on<ApproveProposalRequested>(_onApproveProposalRequested);
  }

  Future<void> _onLoadProposalProjectRequested(
    LoadProposalProjectRequested event,
    Emitter<ProposalModuleState> emit,
  ) async {
    emit(const ProposalModuleLoading());

    final result = await repository.getProjectDetails(event.projectId);
    result.fold(
      (failure) => emit(ProposalModuleFailure(failure.message)),
      (project) => emit(ProposalModuleLoaded(project)),
    );
  }

  Future<void> _onUploadProposalRequested(
    UploadProposalRequested event,
    Emitter<ProposalModuleState> emit,
  ) async {
    emit(const ProposalModuleLoading());

    final result = await repository.uploadProposal(
      event.projectId,
      event.file,
    );
    result.fold(
      (failure) => emit(ProposalModuleFailure(failure.message)),
      (project) => emit(ProposalModuleLoaded(project)),
    );
  }

  Future<void> _onApproveProposalRequested(
    ApproveProposalRequested event,
    Emitter<ProposalModuleState> emit,
  ) async {
    emit(const ProposalModuleLoading());

    final result = await repository.approveProposal(event.projectId);
    result.fold(
      (failure) => emit(ProposalModuleFailure(failure.message)),
      (project) => emit(ProposalModuleLoaded(project)),
    );
  }
}
