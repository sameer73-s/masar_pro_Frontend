import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/app_colors.dart';
import '../../../../../core/presentation/widgets/custom_app_bar.dart';
import '../../../../../injection/injection_container.dart' as di;
import '../bloc/task_selection_bloc.dart';
import 'widgets/task_selection_body.dart';

class TaskSelectionPage extends StatelessWidget {
  const TaskSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          di.locator<TaskSelectionBloc>()..add(const WatchSavedContents()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(title: 'contentCreationTitle'),
        body: const TaskSelectionBody(),
      ),
    );
  }
}
