import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/typography.dart';

class AIWorkerCard extends StatelessWidget {
  const AIWorkerCard({super.key, required this.state, required this.message});

  final String state;
  final String message;

  @override
  Widget build(BuildContext context) {
    final normalizedState = state.toUpperCase();
    final needsHuman = normalizedState == 'HUMAN_ACTION_REQUIRED';
    final isCompleted = normalizedState == 'COMPLETED';
    final isFailed = normalizedState == 'FAILED';
    final statusColor = needsHuman
        ? Colors.red
        : isCompleted
        ? Colors.green
        : isFailed
        ? Colors.red.shade700
        : AppColors.accentPurple;
    final statusLabel = needsHuman
        ? 'Human action required'
        : isCompleted
        ? 'Completed'
        : isFailed
        ? 'Failed'
        : 'Processing';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              needsHuman
                  ? Icons.pan_tool_alt_outlined
                  : isCompleted
                  ? Icons.check_circle_outline
                  : isFailed
                  ? Icons.error_outline
                  : Icons.smart_toy_outlined,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Submission Worker',
                  style: AppTypography.bodyTitle(color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  message.isEmpty ? statusLabel : message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(statusLabel, style: AppTypography.body(color: statusColor)),
        ],
      ),
    );
  }
}
