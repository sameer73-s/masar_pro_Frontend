part of 'agency_bloc.dart';

abstract class AgencyEvent extends Equatable {
  const AgencyEvent();

  @override
  List<Object?> get props => [];
}

class FetchAgencyTasksRequested extends AgencyEvent {
  /// Optional client-side filter applied after fetching all tasks.
  final TaskStatus? statusFilter;

  /// When true, skip the loading spinner and keep the current list on failure.
  /// Used by the PROCESSING auto-refresh timer.
  final bool silent;

  const FetchAgencyTasksRequested({
    this.statusFilter,
    this.silent = false,
  });

  @override
  List<Object?> get props => [statusFilter, silent];
}

class QuoteTaskRequested extends AgencyEvent {
  final String taskId;
  final int price;

  const QuoteTaskRequested(this.taskId, this.price);

  @override
  List<Object?> get props => [taskId, price];
}

class ApproveTaskRequested extends AgencyEvent {
  final String taskId;

  const ApproveTaskRequested(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class RejectTaskRequested extends AgencyEvent {
  final String taskId;

  const RejectTaskRequested(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ProcessTaskRequested extends AgencyEvent {
  final String taskId;
  final String workflow;
  final Map<String, dynamic> params;

  const ProcessTaskRequested(this.taskId, this.workflow, this.params);

  @override
  List<Object?> get props => [taskId, workflow, params];
}
