import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../injection/injection_container.dart' as di;
import '../../task_selection/views/widgets/task_selection_form.dart';
import '../bloc/task_form_bloc.dart';
import 'widgets/task_form_body.dart';

class TaskFormPage extends StatelessWidget {
  final TaskItem task;

  const TaskFormPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.locator<TaskFormBloc>(),
      child: TaskFormBody(task: task),
    );
  }
}
