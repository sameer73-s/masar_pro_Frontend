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

  static const Color _trackColor = Color(0xFFEEE9FF);
  static const Color _progressColor = Color(0xFF8764FF);

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
                const Text(
                  "Your today's task\nalmost done!",
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                SmallPillButton(
                  label: 'View Task',
                  onPressed: onViewTask,
                ),
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
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
