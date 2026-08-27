import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/core/presentation/widgets/custom_app_bar.dart';
import 'package:masar_pro/injection/injection_container.dart' as di;

import '../../bloc/publishing_bloc/publishing_bloc.dart';
import 'widgets/readiness_result_body.dart';

class ReadinessResultPage extends StatelessWidget {
  const ReadinessResultPage({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'researchReadiness'),
      body: BlocProvider(
        create: (_) => di.locator<PublishingBloc>()
          ..add(AnalyzeReadinessRequested(projectId)),
        child: ReadinessResultBody(projectId: projectId),
      ),
    );
  }
}
