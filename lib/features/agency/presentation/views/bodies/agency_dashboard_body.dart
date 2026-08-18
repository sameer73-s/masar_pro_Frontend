import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/strings.dart';
import '../../../../../core/presentation/widgets/app_error_dialog.dart';
import '../../../../../core/presentation/widgets/app_error_widget.dart';
import '../../../../../core/presentation/widgets/app_success_dialog.dart';
import '../../../../../core/presentation/widgets/empty_widget.dart';
import '../../../../../core/presentation/widgets/loading_widget.dart';
import '../../../domain/entities/agency_task.dart';
import '../../../domain/enums/task_status.dart';
import '../../bloc/agency_bloc/agency_bloc.dart';
import '../widgets/agency_task_card.dart';

class AgencyDashboardBody extends StatefulWidget {
  const AgencyDashboardBody({super.key});

  @override
  State<AgencyDashboardBody> createState() => _AgencyDashboardBodyState();
}

class _AgencyDashboardBodyState extends State<AgencyDashboardBody> {
  Timer? _pollTimer;

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pollTimer = null;
    super.dispose();
  }

  static bool _needsPolling(TaskStatus status) {
    return status == TaskStatus.processing ||
        status == TaskStatus.uploaded ||
        status == TaskStatus.pendingApproval;
  }

  /// Poll every 5s while any task is active; stop when all are terminal.
  void _syncPollTimer(List<AgencyTask> tasks) {
    final shouldPoll = tasks.any((task) => _needsPolling(task.status));
    if (shouldPoll) {
      _pollTimer ??= Timer.periodic(const Duration(seconds: 5), (_) {
        if (!mounted) return;
        context.read<AgencyBloc>().add(
              const FetchAgencyTasksRequested(silent: true),
            );
      });
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<AgencyBloc>();
    bloc.add(const FetchAgencyTasksRequested());
    await bloc.stream.firstWhere(
      (state) => state is AgencyTasksLoaded || state is AgencyFailure,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AgencyBloc, AgencyState>(
      listener: (context, state) {
        if (state is AgencyActionSuccess) {
          AppSuccessDialog.show(
            context,
            message: state.message,
          );
        } else if (state is AgencyFailure) {
          AppErrorDialog.show(
            context,
            message: state.error.tr(),
            okButtonText: Strings.retry.tr(),
            onOk: () => context.read<AgencyBloc>().add(
                  const FetchAgencyTasksRequested(),
                ),
            secondaryButtonText: Strings.ok.tr(),
            onSecondaryAction: () {},
          );
        }

        if (state is AgencyTasksLoaded) {
          _syncPollTimer(state.tasks);
        } else if (state is AgencyActionSuccess) {
          _syncPollTimer(state.updatedTasks);
        }
      },
      builder: (context, state) {
        if (state is AgencyLoading || state is AgencyInitial) {
          return const LoadingWidget();
        }

        if (state is AgencyFailure) {
          return AppErrorWidget(
            message: state.error.tr(),
            onRetry: () => context.read<AgencyBloc>().add(
                  const FetchAgencyTasksRequested(),
                ),
          );
        }

        final tasks = _tasksFromState(state);

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: tasks.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    EmptyWidget(message: 'No agency tasks yet'),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: tasks.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      AgencyTaskCard(task: tasks[index]),
                ),
        );
      },
    );
  }

  List<AgencyTask> _tasksFromState(AgencyState state) {
    if (state is AgencyTasksLoaded) return state.tasks;
    if (state is AgencyActionSuccess) return state.updatedTasks;
    return const [];
  }
}
