import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

/// Compact pill CTA — 111×38, 9px radius.
class SmallPillButton extends StatelessWidget {
  const SmallPillButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 111,
      height: 38,
      child: Material(
        color: AppColors.surfacePurple,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(9),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.accentPurple,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
