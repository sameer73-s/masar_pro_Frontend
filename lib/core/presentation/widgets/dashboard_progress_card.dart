import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';
import 'custom_circular_progress.dart';
import 'small_pill_button.dart';

/// Purple dashboard card summarizing today's task progress.
class DashboardProgressCard extends StatelessWidget {
  const DashboardProgressCard({
    super.key,
    this.progress = 0.85,
    required this.onViewTask,
  });

  final double progress;
  final VoidCallback onViewTask;

  static const Color _trackColor = AppColors.uiPurpleTrack;
  static const Color _progressColor = AppColors.uiPurpleProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accentPurple,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'todaysTaskAlmostDone'.tr(),
                  textDirection: Directionality.of(context),
                  style: const TextStyle(
                    color: AppColors.background,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                SmallPillButton(label: 'viewTask'.tr(), onPressed: onViewTask),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CustomCircularProgress(
            progress: progress,
            size: 76,
            strokeWidth: 6,
            trackColor: _trackColor,
            progressColor: _progressColor,
            textColor: AppColors.background,
          ),
        ],
      ),
    );
  }
}
