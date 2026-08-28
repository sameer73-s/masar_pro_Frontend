import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/core/presentation/widgets/app_error_dialog.dart';
import 'package:masar_pro/core/presentation/widgets/custom_app_bar.dart';
import 'package:masar_pro/injection/injection_container.dart' as di;

import '../../bloc/publishing_bloc/publishing_bloc.dart';
import '../../revision_workflow/views/revision_workflow_page.dart';
import '../../submission_monitor/submission_monitor_page.dart';
import 'widgets/submission_workspace_body.dart';

class SubmissionWorkspacePage extends StatelessWidget {
  const SubmissionWorkspacePage({
    super.key,
    required this.projectId,
    required this.journalId,
    this.journalName,
    this.targetUrl,
    this.fileId,
  });

  final String projectId;
  final String journalId;
  final String? journalName;
  final String? targetUrl;
  final String? fileId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.locator<PublishingBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'submissionWorkspace',
          showBackButton: true,
          actions: [
            Builder(
              builder: (context) => IconButton(
                tooltip: 'revisionWorkflow'.tr(),
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
          targetUrl: targetUrl,
          fileId: fileId,
          onStartAutomatedSubmission: () => _openSubmissionMonitor(context),
        ),
      ),
    );
  }

  void _openSubmissionMonitor(BuildContext context) {
    final target = targetUrl?.trim() ?? '';
    final manuscriptFileId = fileId?.trim() ?? '';
    if (target.isEmpty || manuscriptFileId.isEmpty) {
      AppErrorDialog.show(
        context,
        message:
            'Automated submission needs the journal submission URL and manuscript file ID.',
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SubmissionMonitorPage(
          projectId: projectId,
          journalId: journalId,
          targetUrl: target,
          fileId: manuscriptFileId,
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
        message: 'loadSubmissionBeforeRevision'.tr(),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RevisionWorkflowPage(submissionId: state.submission.id),
      ),
    );
  }
}
