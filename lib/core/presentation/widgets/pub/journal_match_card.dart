import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/app_theme.dart';
import 'package:masar_pro/core/presentation/widgets/custom_circular_progress.dart';

const Color _kPubBorder = AppColors.uiBorder;

/// Recommended-journal card with quartile, APC, and match score.
class JournalMatchCard extends StatelessWidget {
  const JournalMatchCard({
    super.key,
    required this.journalName,
    required this.quartile,
    required this.publisher,
    required this.apcPrice,
    required this.matchScore,
    required this.isSelected,
    required this.onSelect,
  });

  final String journalName;
  final String quartile;
  final String publisher;
  final String apcPrice;

  /// Value from 0.0 to 1.0.
  final double matchScore;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: isSelected
          ? AppColors.surfacePurple.withValues(alpha: 0.55)
          : AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        side: BorderSide(
          color: isSelected ? AppColors.accentPurple : _kPubBorder,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    journalName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _QuartileBadge(quartile: quartile),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    publisher,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Text(
                  apcPrice,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: matchScore.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return CustomCircularProgress(
                      progress: value,
                      size: 48,
                      strokeWidth: 5,
                      trackColor: AppColors.accentPurple.withValues(
                        alpha: 0.15,
                      ),
                      progressColor: AppColors.accentPurple,
                      textColor: AppColors.primary,
                      textSize: 11,
                    );
                  },
                ),
                const SizedBox(width: 10),
                const Text(
                  'Match',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                _SelectPill(isSelected: isSelected, onSelect: onSelect),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuartileBadge extends StatelessWidget {
  const _QuartileBadge({required this.quartile});

  final String quartile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfacePurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        quartile,
        style: const TextStyle(
          color: AppColors.accentPurple,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}

class _SelectPill extends StatelessWidget {
  const _SelectPill({required this.isSelected, required this.onSelect});

  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.accentPurple : AppColors.surfacePurple,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            isSelected ? 'Selected' : 'Select',
            style: TextStyle(
              color: isSelected ? AppColors.background : AppColors.accentPurple,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
