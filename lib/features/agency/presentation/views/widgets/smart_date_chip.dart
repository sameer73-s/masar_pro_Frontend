import 'package:flutter/material.dart';

import '../../../../../config/app_colors.dart';
import '../../../domain/entities/date_status_summary.dart';
import 'date_status_indicator.dart';

/// Compact card: weekday (Mon), date number (17), and status dots.
class SmartDateChip extends StatelessWidget {
  const SmartDateChip({
    super.key,
    required this.date,
    required this.isSelected,
    required this.summary,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final DateStatusSummary summary;
  final VoidCallback onTap;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final weekday = _weekdays[date.weekday - 1];
    final day = date.day.toString();

    final Color bg = isSelected ? AppColors.accentPurple : Colors.white;
    final Color fg = isSelected ? Colors.white : AppColors.primary;
    final Color muted = isSelected ? Colors.white70 : AppColors.textSecondary;

    return Material(
      color: bg,
      elevation: isSelected ? 0 : 1,
      shadowColor: AppColors.shadowColor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekday,
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                day,
                style: TextStyle(
                  color: fg,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              DateStatusIndicator(
                summary: summary,
                onSelectedBackground: isSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
