import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/core/presentation/widgets/custom_app_bar.dart';
import 'package:masar_pro/injection/injection_container.dart' as di;

import '../../bloc/publishing_bloc/publishing_bloc.dart';
import 'widgets/revision_workflow_body.dart';

class RevisionWorkflowPage extends StatelessWidget {
  const RevisionWorkflowPage({
    super.key,
    required this.submissionId,
  });

  final String submissionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.locator<PublishingBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(
          title: 'Revision Workflow',
          showBackButton: true,
        ),
        body: RevisionWorkflowBody(submissionId: submissionId),
      ),
    );
  }
}
