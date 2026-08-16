import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

/// 24×24 notification bell with an optional active-state indicator dot.
class NotificationBell extends StatelessWidget {
  const NotificationBell({
    super.key,
    required this.hasActiveNotifications,
  });

  final bool hasActiveNotifications;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            size: 24,
            color: AppColors.primary,
          ),
          if (hasActiveNotifications)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accentPurple,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
