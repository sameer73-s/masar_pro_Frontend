import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

enum Status { done, inProgress, toDo }

/// Compact status pill — height 14, radius 7, 9px label.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.label,
  });

  final Status status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String defaultLabel) = switch (status) {
      Status.done => (
          AppColors.surfacePurple,
          AppColors.accentPurple,
          'Done',
        ),
      Status.inProgress => (
          AppColors.surfaceOrange,
          AppColors.accentOrange,
          'In Progress',
        ),
      Status.toDo => (
          AppColors.surfaceBlue,
          AppColors.statusBlue,
          'To-Do',
        ),
    };

    return Container(
      height: 14,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
      ),
      alignment: Alignment.center,
      child: Text(
        label ?? defaultLabel,
        style: TextStyle(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}
