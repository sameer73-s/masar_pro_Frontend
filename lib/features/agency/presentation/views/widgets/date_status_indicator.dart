import 'package:flutter/material.dart';

import '../../../../../config/app_colors.dart';
import '../../../domain/entities/date_status_summary.dart';

/// Compact status dots: purple (has tasks), yellow (due tomorrow), red (overdue).
class DateStatusIndicator extends StatelessWidget {
  const DateStatusIndicator({
    super.key,
    required this.summary,
    this.onSelectedBackground = false,
  });

  final DateStatusSummary summary;
  final bool onSelectedBackground;

  static const double _size = 5;
  static const double _gap = 3;

  @override
  Widget build(BuildContext context) {
    final dots = <Widget>[];
    if (summary.hasTasks) {
      dots.add(
        _Dot(
          color: onSelectedBackground
              ? AppColors.background
              : AppColors.accentPurple,
        ),
      );
    }
    if (summary.deadlineTomorrow) {
      dots.add(const _Dot(color: AppColors.accentYellow));
    }
    if (summary.isOverdue) {
      dots.add(
        _Dot(
          color: onSelectedBackground
              ? AppColors.uiDanger.withValues(alpha: 0.55)
              : AppColors.error,
        ),
      );
    }

    return SizedBox(
      height: _size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < dots.length; i++) ...[
            if (i > 0) const SizedBox(width: _gap),
            dots[i],
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DateStatusIndicator._size,
      height: DateStatusIndicator._size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
