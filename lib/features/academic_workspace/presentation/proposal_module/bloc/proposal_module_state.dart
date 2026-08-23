part of 'proposal_module_bloc.dart';

abstract class ProposalModuleState extends Equatable {
  const ProposalModuleState();

  @override
  List<Object?> get props => [];
}

class ProposalModuleInitial extends ProposalModuleState {
  const ProposalModuleInitial();
}

class ProposalModuleLoading extends ProposalModuleState {
  const ProposalModuleLoading();
}

class ProposalModuleGenerating extends ProposalModuleState {
  const ProposalModuleGenerating();
}

class ProposalModuleLoaded extends ProposalModuleState {
  final AcademicProject project;

  const ProposalModuleLoaded(this.project);

  @override
  List<Object?> get props => [project];
}

class ProposalModuleSkipSuccess extends ProposalModuleState {
  final AcademicProject project;

  const ProposalModuleSkipSuccess(this.project);

  @override
  List<Object?> get props => [project];
}

class ProposalModuleFailure extends ProposalModuleState {
  final String error;

  const ProposalModuleFailure(this.error);

  @override
  List<Object?> get props => [error];
}
