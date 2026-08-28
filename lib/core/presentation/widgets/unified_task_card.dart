import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';
import 'custom_circular_progress.dart';

/// Canonical task category for [UnifiedTaskCard] icon and tint mapping.
enum UnifiedTaskType {
  research,
  permit,
  report,
  publishing,
  generic;

  IconData get icon => switch (this) {
    research => Icons.menu_book,
    permit => Icons.assignment_turned_in,
    report => Icons.description,
    publishing => Icons.publish,
    generic => Icons.task_alt,
  };

  Color get iconBackground => switch (this) {
    research => AppColors.surfacePurple,
    permit => AppColors.surfaceBlue,
    report => AppColors.surfaceOrange,
    publishing => AppColors.surfaceYellow,
    generic => AppColors.surfacePink,
  };

  Color get iconColor => switch (this) {
    research => AppColors.accentPurple,
    permit => AppColors.statusBlue,
    report => AppColors.accentOrange,
    publishing => AppColors.accentYellow,
    generic => AppColors.primary,
  };

  Color get progressColor => iconColor;

  /// Maps Smart Parser / content-creation `task_type` strings.
  static UnifiedTaskType fromOrderType(String value) {
    final t = value.toLowerCase();
    if (t.contains('permit') || t.contains('تصريح')) {
      return UnifiedTaskType.permit;
    }
    if (t.contains('report') || t.contains('تقرير')) {
      return UnifiedTaskType.report;
    }
    if (t.contains('publish') || t.contains('نشر')) {
      return UnifiedTaskType.publishing;
    }
    if (t.contains('research') ||
        t.contains('بحث') ||
        t.contains('literature') ||
        t.contains('أدب')) {
      return UnifiedTaskType.research;
    }
    return UnifiedTaskType.generic;
  }
}

/// Standard task card with a subtle entrance and press interaction.
class UnifiedTaskCard extends StatefulWidget {
  const UnifiedTaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.taskType = UnifiedTaskType.generic,
    this.onTap,
  });

  final String title;
  final String subtitle;

  /// Value from 0.0 to 1.0.
  final double progress;
  final UnifiedTaskType taskType;
  final VoidCallback? onTap;

  @override
  State<UnifiedTaskCard> createState() => _UnifiedTaskCardState();
}

class _UnifiedTaskCardState extends State<UnifiedTaskCard> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value || !mounted) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.taskType;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.scale(scale: 0.98 + (value * 0.02), child: child),
      ),
      child: Listener(
        onPointerDown: (_) => _setPressed(true),
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: AnimatedScale(
          scale: _isPressed ? 0.985 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Material(
            color: AppColors.background,
            elevation: 1,
            shadowColor: AppColors.shadowColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
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
                              color: type.iconBackground,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              type.icon,
                              size: 20,
                              color: type.iconColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.subtitle,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 2,
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
                      progress: widget.progress,
                      size: 42,
                      strokeWidth: 4,
                      trackColor: type.progressColor.withValues(alpha: 0.15),
                      progressColor: type.progressColor,
                      textColor: AppColors.primary,
                      textSize: 11,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
