import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_colors.dart';
import '../../../../../core/presentation/widgets/custom_app_bar.dart';
import '../../../../../injection/injection_container.dart' as di;
import '../../bloc/academic_workspace_bloc/academic_workspace_bloc.dart';
import '../bodies/academic_workspace_body.dart';

class AcademicWorkspacePage extends StatelessWidget {
  const AcademicWorkspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.locator<AcademicWorkspaceBloc>()
        ..add(const FetchAcademicProjectsRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'academicWorkspace'),
        body: const SafeArea(
          child: AcademicWorkspaceBody(),
        ),
      ),
    );
  }
}
