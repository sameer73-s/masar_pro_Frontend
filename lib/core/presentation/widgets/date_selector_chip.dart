import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

/// Date card chip — month / day-number / weekday, active or inactive.
class DateSelectorChip extends StatelessWidget {
  const DateSelectorChip({
    super.key,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final month = _months[date.month - 1];
    final weekday = _weekdays[date.weekday - 1];
    final day = date.day.toString().padLeft(2, '0');

    final Color bg = isSelected ? AppColors.accentPurple : AppColors.background;
    final Color fg = isSelected ? AppColors.background : AppColors.primary;
    final Color muted = isSelected
        ? AppColors.background
        : AppColors.textSecondary;

    return Material(
      color: bg,
      elevation: isSelected ? 0 : 1,
      shadowColor: AppColors.shadowColor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                month,
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                day,
                style: TextStyle(
                  color: fg,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                weekday,
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
