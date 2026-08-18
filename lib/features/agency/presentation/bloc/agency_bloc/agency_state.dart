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
  /// Status-filtered tasks (not date-filtered). Used for polling.
  final List<AgencyTask> tasks;

  /// Tasks matching [selectedDate] and [dateFilterMode].
  final List<AgencyTask> filteredTasks;

  final DateTime selectedDate;
  final DateFilterMode dateFilterMode;
  final Map<DateTime, DateStatusSummary> dateSummaries;

  const AgencyTasksLoaded({
    required this.tasks,
    required this.filteredTasks,
    required this.selectedDate,
    required this.dateFilterMode,
    required this.dateSummaries,
  });

  @override
  List<Object?> get props => [
        tasks,
        filteredTasks,
        selectedDate,
        dateFilterMode,
        dateSummaries,
      ];
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
