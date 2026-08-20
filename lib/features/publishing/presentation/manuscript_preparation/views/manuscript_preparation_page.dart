import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/core/presentation/widgets/custom_app_bar.dart';
import 'package:masar_pro/injection/injection_container.dart' as di;

import '../../bloc/publishing_bloc/publishing_bloc.dart';
import 'widgets/manuscript_preparation_body.dart';

class ManuscriptPreparationPage extends StatelessWidget {
  const ManuscriptPreparationPage({
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Manuscript Preparation'),
      body: BlocProvider(
        create: (_) => di.locator<PublishingBloc>(),
        child: ManuscriptPreparationBody(
          projectId: projectId,
          journalId: journalId,
          journalName: journalName,
        ),
      ),
    );
  }
}
