import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/typography.dart';

class PublishingProgressHeader extends StatelessWidget {
  const PublishingProgressHeader({
    super.key,
    required this.progress,
    required this.state,
    required this.message,
    this.jobId,
  });

  final double progress;
  final String state;
  final String message;
  final String? jobId;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0);
    final percentage = (normalizedProgress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Live Submission Monitor',
                  style: AppTypography.bodyTitle(color: Colors.white),
                ),
              ),
              Text(
                '$percentage%',
                style: AppTypography.bodyTitle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: normalizedProgress,
              backgroundColor: Colors.white.withAlpha(50),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message.isEmpty ? 'Preparing the automation worker...' : message,
            style: AppTypography.body(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            state.isEmpty ? 'QUEUED' : state,
            style: AppTypography.body(color: Colors.white.withAlpha(190)),
          ),
          if (jobId != null && jobId!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Job ID: $jobId',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(color: Colors.white.withAlpha(170)),
            ),
          ],
        ],
      ),
    );
  }
}
