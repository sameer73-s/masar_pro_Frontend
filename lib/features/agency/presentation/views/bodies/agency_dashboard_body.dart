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
import '../../bloc/agency_bloc/agency_bloc.dart';
import '../widgets/agency_task_card.dart';

class AgencyDashboardBody extends StatelessWidget {
  const AgencyDashboardBody({super.key});

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
        if (tasks.isEmpty) {
          return const EmptyWidget(message: 'No agency tasks yet');
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: tasks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => AgencyTaskCard(task: tasks[index]),
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
