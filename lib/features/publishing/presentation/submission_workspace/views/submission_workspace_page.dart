import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/core/presentation/widgets/app_error_dialog.dart';
import 'package:masar_pro/core/presentation/widgets/custom_app_bar.dart';
import 'package:masar_pro/injection/injection_container.dart' as di;

import '../../bloc/publishing_bloc/publishing_bloc.dart';
import '../../revision_workflow/views/revision_workflow_page.dart';
import 'widgets/submission_workspace_body.dart';

class SubmissionWorkspacePage extends StatelessWidget {
  const SubmissionWorkspacePage({
    super.key,
    required this.projectId,
    required this.journalId,
    this.journalName,
  });

  final String projectId;
  final String journalId;
  final String? journalName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.locator<PublishingBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Submission Workspace',
          showBackButton: true,
          actions: [
            Builder(
              builder: (context) => IconButton(
                tooltip: 'Revision Workflow',
                onPressed: () => _openRevisionWorkflow(context),
                icon: const Icon(
                  Icons.rate_review_outlined,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        body: SubmissionWorkspaceBody(
          projectId: projectId,
          journalId: journalId,
          journalName: journalName,
        ),
      ),
    );
  }

  void _openRevisionWorkflow(BuildContext context) {
    final state = context.read<PublishingBloc>().state;
    if (state is! PublishingSubmissionLoaded) {
      AppErrorDialog.show(
        context,
        message: 'Load the submission before opening the revision workflow.',
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RevisionWorkflowPage(
          submissionId: state.submission.id,
        ),
      ),
    );
  }
}
