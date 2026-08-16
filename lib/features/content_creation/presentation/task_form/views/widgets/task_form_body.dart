import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../config/app_colors.dart';
import '../../../../../../core/presentation/widgets/app_error_dialog.dart';
import '../../../../../../core/presentation/widgets/custom_app_bar.dart';
import '../../../task_selection/views/widgets/task_selection_form.dart';
import '../../../content_result/views/content_result_page.dart';
import '../../bloc/task_form_bloc.dart';
import 'task_form.dart';

class TaskFormBody extends StatelessWidget {
  final TaskItem task;

  const TaskFormBody({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(title: task.title),
        body: BlocListener<TaskFormBloc, TaskFormState>(
          listener: (context, state) {
            if (state is ContentGenerationSuccess) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ContentResultPage(
                    taskType: state.taskType,
                    title: state.title,
                    payload: state.rawResult,
                    resultData: state.rawResult,
                    content: state.content,
                  ),
                ),
              );
            } else if (state is ContentCreationFailure) {
              AppErrorDialog.show(context, message: state.message);
            } else if (state is UploadFailure) {
              AppErrorDialog.show(
                context,
                message: 'فشل رفع الملف: ${state.message}',
              );
            }
          },
          child: TaskForm(task: task),
        ),
      ),
    );
  }
}
