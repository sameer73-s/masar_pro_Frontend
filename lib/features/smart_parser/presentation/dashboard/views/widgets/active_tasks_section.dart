import 'package:flutter/material.dart';

import '../../../../../../config/app_colors.dart';
import '../../../../../../config/app_theme.dart';
import '../../../../../agency/presentation/views/pages/agency_dashboard_page.dart';

/// Compact operational card summarizing active / processing task counts.
class ActiveTasksSection extends StatelessWidget {
  const ActiveTasksSection({
    super.key,
    this.activeCount = 8,
    this.processingCount = 3,
  });

  final int activeCount;
  final int processingCount;

  void _openActiveTasks(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AgencyDashboardPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtleCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfacePurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  color: AppColors.accentPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Active Tasks',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$activeCount Active • $processingCount Processing',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _openActiveTasks(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentPurple,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Open Active Tasks →',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
