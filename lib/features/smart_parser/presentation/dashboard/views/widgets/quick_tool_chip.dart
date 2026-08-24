import 'package:flutter/material.dart';

import '../../../../../../config/app_colors.dart';
import '../../../../../../config/app_theme.dart';

/// Small rectangular quick-action chip with an icon and label.
class QuickToolChip extends StatelessWidget {
  const QuickToolChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.emoji,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Optional emoji shown above the label instead of [icon].
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShapes.secondaryContainerRadius),
        child: Ink(
          width: 88,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(AppShapes.secondaryContainerRadius),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.subtleCard,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null)
                Text(emoji!, style: const TextStyle(fontSize: 22))
              else
                Icon(icon, size: 22, color: AppColors.accentPurple),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
