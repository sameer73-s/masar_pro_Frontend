import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/app_theme.dart';

const Color _kPubBorder = Color(0xFFE8E5F0);

/// Reviewer comment with an AI-suggested response and accept/edit actions.
class ReviewerCommentCard extends StatelessWidget {
  const ReviewerCommentCard({
    super.key,
    required this.commentText,
    required this.aiResponse,
    required this.onAccept,
    required this.onEdit,
  });

  final String commentText;
  final String aiResponse;
  final VoidCallback onAccept;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.cardRadius),
        side: const BorderSide(color: _kPubBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              commentText,
              style: const TextStyle(
                color: Color(0xFF4A4758),
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: _kPubBorder),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: AppColors.accentPurple,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'AI suggested response',
                        style: TextStyle(
                          color: AppColors.accentPurple,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    aiResponse,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _PillButton(
                  label: 'Accept',
                  filled: true,
                  onPressed: onAccept,
                ),
                const SizedBox(width: 8),
                _PillButton(
                  label: 'Edit',
                  filled: false,
                  onPressed: onEdit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.accentPurple : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: filled
                ? null
                : Border.all(color: AppColors.accentPurple),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : AppColors.accentPurple,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
