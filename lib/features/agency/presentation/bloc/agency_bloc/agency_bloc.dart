import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/agency_task.dart';
import '../../../domain/enums/task_status.dart';
import '../../../domain/repositories/agency_repository.dart';

part 'agency_event.dart';
part 'agency_state.dart';

class AgencyBloc extends Bloc<AgencyEvent, AgencyState> {
  final AgencyRepository repository;

  TaskStatus? _statusFilter;
  List<AgencyTask> _tasks = const [];
  bool _fetchInFlight = false;

  AgencyBloc({required this.repository}) : super(const AgencyInitial()) {
    on<FetchAgencyTasksRequested>(_onFetchAgencyTasksRequested);
    on<QuoteTaskRequested>(_onQuoteTaskRequested);
    on<ApproveTaskRequested>(_onApproveTaskRequested);
    on<RejectTaskRequested>(_onRejectTaskRequested);
    on<ProcessTaskRequested>(_onProcessTaskRequested);
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
    if (!event.silent) {
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
          _tasks = _applyFilter(tasks);
          if (isClosed) return;
          emit(AgencyTasksLoaded(_tasks));
        },
      );
    } finally {
      _fetchInFlight = false;
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
        emit(AgencyActionSuccess('Task quoted successfully', _tasks));
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
        emit(AgencyActionSuccess('Task approved successfully', _tasks));
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
        emit(AgencyActionSuccess('Task rejected successfully', _tasks));
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
        emit(AgencyActionSuccess('Task processing started', _tasks));
        add(FetchAgencyTasksRequested(statusFilter: _statusFilter));
      },
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
    _tasks = _applyFilter(updated);
  }

  List<AgencyTask> _applyFilter(List<AgencyTask> tasks) {
    final filter = _statusFilter;
    if (filter == null) return List<AgencyTask>.unmodifiable(tasks);
    return List<AgencyTask>.unmodifiable(
      tasks.where((t) => t.status == filter),
    );
  }
}
