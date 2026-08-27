import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/core/presentation/widgets/custom_app_bar.dart';

import 'widgets/journal_matching_body.dart';

class JournalMatchingPage extends StatelessWidget {
  const JournalMatchingPage({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'recommendedJournals'),
      body: JournalMatchingBody(projectId: projectId),
    );
  }
}
