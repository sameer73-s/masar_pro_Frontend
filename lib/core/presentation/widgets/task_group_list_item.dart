import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';
import 'custom_circular_progress.dart';

/// List row for a task group with icon, labels, and circular progress.
class TaskGroupListItem extends StatelessWidget {
  const TaskGroupListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.progressColor,
  });

  final String title;
  final String subtitle;
  final double progress;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      elevation: 1,
      shadowColor: AppColors.shadowColor.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CustomCircularProgress(
              progress: progress,
              size: 42,
              strokeWidth: 4,
              trackColor: progressColor.withValues(alpha: 0.15),
              progressColor: progressColor,
              textColor: AppColors.primary,
              textSize: 11,
            ),
          ],
        ),
      ),
    );
  }
}
