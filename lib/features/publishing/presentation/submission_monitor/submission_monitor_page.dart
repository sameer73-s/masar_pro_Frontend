import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/core/presentation/widgets/custom_app_bar.dart';

import '../bloc/publishing_bloc/publishing_bloc.dart';
import 'submission_monitor_body.dart';

class SubmissionMonitorPage extends StatelessWidget {
  const SubmissionMonitorPage({
    super.key,
    required this.projectId,
    required this.journalId,
    required this.targetUrl,
    required this.fileId,
    this.journalName,
  });

  final String projectId;
  final String journalId;
  final String targetUrl;
  final String fileId;
  final String? journalName;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PublishingBloc>();

    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(
          title: 'Live Submission Monitor',
          showBackButton: true,
        ),
        body: SubmissionMonitorBody(
          projectId: projectId,
          journalId: journalId,
          targetUrl: targetUrl,
          fileId: fileId,
          journalName: journalName,
        ),
      ),
    );
  }
}
