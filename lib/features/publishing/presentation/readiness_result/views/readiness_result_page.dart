import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/core/presentation/widgets/custom_app_bar.dart';

import '../../../domain/entities/readiness_report.dart';
import 'widgets/readiness_result_body.dart';

class ReadinessResultPage extends StatelessWidget {
  const ReadinessResultPage({
    super.key,
    required this.report,
  });

  final ReadinessReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Readiness Result'),
      body: ReadinessResultBody(report: report),
    );
  }
}
