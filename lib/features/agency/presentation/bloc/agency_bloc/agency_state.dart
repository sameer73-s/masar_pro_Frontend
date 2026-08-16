part of 'agency_bloc.dart';

abstract class AgencyState extends Equatable {
  const AgencyState();

  @override
  List<Object?> get props => [];
}

class AgencyInitial extends AgencyState {
  const AgencyInitial();
}

class AgencyLoading extends AgencyState {
  const AgencyLoading();
}

class AgencyTasksLoaded extends AgencyState {
  final List<AgencyTask> tasks;

  const AgencyTasksLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class AgencyActionSuccess extends AgencyState {
  final String message;
  final List<AgencyTask> updatedTasks;

  const AgencyActionSuccess(this.message, this.updatedTasks);

  @override
  List<Object?> get props => [message, updatedTasks];
}

class AgencyFailure extends AgencyState {
  final String error;

  const AgencyFailure(this.error);

  @override
  List<Object?> get props => [error];
}
