import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/app_theme.dart';
import 'package:masar_pro/config/typography.dart';

import '../../../../domain/entities/readiness_report.dart';

class ReadinessResultBody extends StatelessWidget {
  const ReadinessResultBody({
    super.key,
    required this.report,
  });

  final ReadinessReport report;

  @override
  Widget build(BuildContext context) {
    final percent = (report.overallScore <= 1
            ? report.overallScore * 100
            : report.overallScore)
        .round();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfacePurple,
              borderRadius: BorderRadius.circular(AppShapes.cardRadius),
            ),
            child: Column(
              children: [
                Text(
                  'Placeholder',
                  style: AppTypography.body(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Readiness analysis complete',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyTitle(color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    color: AppColors.accentPurple,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.status.apiValue,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
