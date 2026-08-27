import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/agency_task.dart';
import '../../../domain/entities/date_status_summary.dart';
import '../../../domain/enums/date_filter_mode.dart';
import '../../../domain/enums/task_status.dart';
import '../../../domain/repositories/agency_repository.dart';

part 'agency_event.dart';
part 'agency_state.dart';

class AgencyBloc extends Bloc<AgencyEvent, AgencyState> {
  final AgencyRepository repository;

  TaskStatus? _statusFilter;
  List<AgencyTask> _tasks = const [];
  bool _fetchInFlight = false;
  DateTime _selectedDate = AgencyCalendarRange.dateOnly(DateTime.now());
  DateFilterMode _dateFilterMode = DateFilterMode.all;

  AgencyBloc({required this.repository}) : super(const AgencyInitial()) {
    on<FetchAgencyTasksRequested>(_onFetchAgencyTasksRequested);
    on<SelectDateRequested>(_onSelectDateRequested);
    on<ChangeDateFilterRequested>(_onChangeDateFilterRequested);
    on<QuoteTaskRequested>(_onQuoteTaskRequested);
    on<ApproveTaskRequested>(_onApproveTaskRequested);
    on<RejectTaskRequested>(_onRejectTaskRequested);
    on<ProcessTaskRequested>(_onProcessTaskRequested);
    on<RetryTaskRequested>(_onRetryTaskRequested);
    on<DeleteTaskRequested>(_onDeleteTaskRequested);
  }

  Future<void> _onFetchAgencyTasksRequested(
    FetchAgencyTasksRequested event,
    Emitter<AgencyState> emit,
  ) async {
    if (event.silent && _fetchInFlight) return;

    if (!event.silent) {
      _statusFilter = event.statusFilter;
    }

    _fetchInFlight = true;
    // Keep the calendar selection during refresh / status-tab changes.
    if (!event.silent && state is! AgencyTasksLoaded) {
      emit(const AgencyLoading());
    }

    try {
      final result = await repository.getTasks();
      result.fold(
        (failure) {
          if (isClosed || event.silent) return;
          emit(AgencyFailure(failure.message));
        },
        (tasks) {
          _tasks = _applyStatusFilter(tasks);
          _emitLoaded(emit);
        },
      );
    } finally {
      _fetchInFlight = false;
    }
  }

  void _onSelectDateRequested(
    SelectDateRequested event,
    Emitter<AgencyState> emit,
  ) {
    _selectedDate = AgencyCalendarRange.dateOnly(event.date);
    if (state is AgencyTasksLoaded || _tasks.isNotEmpty) {
      _emitLoaded(emit);
    }
  }

  void _onChangeDateFilterRequested(
    ChangeDateFilterRequested event,
    Emitter<AgencyState> emit,
  ) {
    _dateFilterMode = event.mode;
    if (state is AgencyTasksLoaded || _tasks.isNotEmpty) {
      _emitLoaded(emit);
    }
  }

  Future<void> _onQuoteTaskRequested(
    QuoteTaskRequested event,
    Emitter<AgencyState> emit,
  ) async {
    emit(const AgencyLoading());

    final result = await repository.quoteTask(event.taskId, event.price);
    await result.fold(
      (failure) async => emit(AgencyFailure(failure.message)),
      (task) async {
        _upsertTask(task);
        emit(AgencyActionSuccess('taskQuotedSuccessfully', _tasks));
        add(FetchAgencyTasksRequested(statusFilter: _statusFilter));
      },
    );
  }

  Future<void> _onApproveTaskRequested(
    ApproveTaskRequested event,
    Emitter<AgencyState> emit,
  ) async {
    emit(const AgencyLoading());

    final result = await repository.approveTask(event.taskId);
    await result.fold(
      (failure) async => emit(AgencyFailure(failure.message)),
      (task) async {
        _upsertTask(task);
        emit(AgencyActionSuccess('taskApprovedSuccessfully', _tasks));
        add(FetchAgencyTasksRequested(statusFilter: _statusFilter));
      },
    );
  }

  Future<void> _onRejectTaskRequested(
    RejectTaskRequested event,
    Emitter<AgencyState> emit,
  ) async {
    emit(const AgencyLoading());

    final result = await repository.rejectTask(event.taskId);
    await result.fold(
      (failure) async => emit(AgencyFailure(failure.message)),
      (task) async {
        _upsertTask(task);
        emit(AgencyActionSuccess('taskRejectedSuccessfully', _tasks));
        add(FetchAgencyTasksRequested(statusFilter: _statusFilter));
      },
    );
  }

  Future<void> _onProcessTaskRequested(
    ProcessTaskRequested event,
    Emitter<AgencyState> emit,
  ) async {
    emit(const AgencyLoading());

    final result = await repository.processTask(
      event.taskId,
      event.workflow,
      event.params,
    );
    await result.fold(
      (failure) async => emit(AgencyFailure(failure.message)),
      (task) async {
        _upsertTask(task);
        emit(AgencyActionSuccess('taskProcessingStarted', _tasks));
        add(FetchAgencyTasksRequested(statusFilter: _statusFilter));
      },
    );
  }

  Future<void> _onRetryTaskRequested(
    RetryTaskRequested event,
    Emitter<AgencyState> emit,
  ) async {
    emit(const AgencyLoading());

    final result = await repository.retryTask(event.taskId);
    await result.fold(
      (failure) async => emit(AgencyFailure(failure.message)),
      (task) async {
        _upsertTask(task);
        emit(AgencyActionSuccess('taskRetryStarted', _tasks));
        add(FetchAgencyTasksRequested(statusFilter: _statusFilter));
      },
    );
  }

  Future<void> _onDeleteTaskRequested(
    DeleteTaskRequested event,
    Emitter<AgencyState> emit,
  ) async {
    emit(const AgencyLoading());

    final result = await repository.deleteTask(event.taskId);
    await result.fold(
      (failure) async => emit(AgencyFailure(failure.message)),
      (_) async {
        _tasks = List<AgencyTask>.unmodifiable(
          _tasks.where((t) => t.id != event.taskId),
        );
        emit(AgencyActionSuccess('taskDeletedSuccessfully', _tasks));
        _emitLoaded(emit);
      },
    );
  }

  void _emitLoaded(Emitter<AgencyState> emit) {
    if (isClosed) return;
    emit(
      AgencyTasksLoaded(
        tasks: _tasks,
        filteredTasks: _applyDateFilter(_tasks),
        selectedDate: _selectedDate,
        dateFilterMode: _dateFilterMode,
        dateSummaries: _buildDateSummaries(_tasks),
      ),
    );
  }

  void _upsertTask(AgencyTask task) {
    final updated = [..._tasks];
    final index = updated.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      updated[index] = task;
    } else {
      updated.insert(0, task);
    }
    _tasks = _applyStatusFilter(updated);
  }

  List<AgencyTask> _applyStatusFilter(List<AgencyTask> tasks) {
    final filter = _statusFilter;
    if (filter == null) return List<AgencyTask>.unmodifiable(tasks);
    return List<AgencyTask>.unmodifiable(
      tasks.where((t) => t.status == filter),
    );
  }

  List<AgencyTask> _applyDateFilter(List<AgencyTask> tasks) {
    final selected = _selectedDate;
    return List<AgencyTask>.unmodifiable(
      tasks.where((task) {
        final created = AgencyCalendarRange.dateOnly(task.createdAt);
        final deadline = AgencyCalendarRange.dateOnly(task.deadline);
        switch (_dateFilterMode) {
          case DateFilterMode.all:
            return created == selected || deadline == selected;
          case DateFilterMode.created:
            return created == selected;
          case DateFilterMode.due:
            return deadline == selected;
        }
      }),
    );
  }

  Map<DateTime, DateStatusSummary> _buildDateSummaries(
    List<AgencyTask> tasks,
  ) {
    final today = AgencyCalendarRange.dateOnly(DateTime.now());
    final visible = AgencyCalendarRange.visibleDates(
      _selectedDate,
      now: today,
    );
    // Always include the default today-window so dots stay correct after jumps.
    final defaultWindow = AgencyCalendarRange.visibleDates(today, now: today);
    final dates = <DateTime>{...visible, ...defaultWindow, _selectedDate};

    final map = <DateTime, DateStatusSummary>{};
    for (final date in dates) {
      map[date] = _summarizeDate(date, tasks, today);
    }
    return Map<DateTime, DateStatusSummary>.unmodifiable(map);
  }

  DateStatusSummary _summarizeDate(
    DateTime date,
    List<AgencyTask> tasks,
    DateTime today,
  ) {
    final tomorrow = today.add(const Duration(days: 1));
    var hasTasks = false;
    var deadlineTomorrow = false;
    var isOverdue = false;

    for (final task in tasks) {
      final created = AgencyCalendarRange.dateOnly(task.createdAt);
      final deadline = AgencyCalendarRange.dateOnly(task.deadline);
      final associated = created == date || deadline == date;
      if (!associated) continue;

      hasTasks = true;
      if (_isOpenTask(task.status)) {
        if (deadline == tomorrow) {
          deadlineTomorrow = true;
        }
        if (deadline.isBefore(today)) {
          isOverdue = true;
        }
      }
    }

    return DateStatusSummary(
      hasTasks: hasTasks,
      deadlineTomorrow: deadlineTomorrow,
      isOverdue: isOverdue,
    );
  }

  static bool _isOpenTask(TaskStatus status) {
    return status != TaskStatus.completed &&
        status != TaskStatus.rejected &&
        status != TaskStatus.failed;
  }
}
