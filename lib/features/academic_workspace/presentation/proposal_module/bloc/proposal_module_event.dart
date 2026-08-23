part of 'proposal_module_bloc.dart';

abstract class ProposalModuleEvent extends Equatable {
  const ProposalModuleEvent();

  @override
  List<Object?> get props => [];
}

class LoadProposalProjectRequested extends ProposalModuleEvent {
  final String projectId;

  const LoadProposalProjectRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class UploadProposalRequested extends ProposalModuleEvent {
  final String projectId;
  final File file;

  const UploadProposalRequested({
    required this.projectId,
    required this.file,
  });

  @override
  List<Object?> get props => [projectId, file.path];
}

class GenerateProposalRequested extends ProposalModuleEvent {
  final String projectId;

  const GenerateProposalRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class ApproveProposalRequested extends ProposalModuleEvent {
  final String projectId;

  const ApproveProposalRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class SkipProposalRequested extends ProposalModuleEvent {
  final String projectId;

  const SkipProposalRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}
