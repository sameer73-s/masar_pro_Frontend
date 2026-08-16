import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';
import 'notification_bell.dart';

/// Greeting header with avatar, user name, and notification bell.
class AppBarGreeting extends StatelessWidget {
  const AppBarGreeting({
    super.key,
    required this.userName,
    this.avatarUrl,
    this.hasNotifications = false,
  });

  final String userName;
  final String? avatarUrl;
  final bool hasNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                    ? NetworkImage(avatarUrl!)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Hello!',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        NotificationBell(hasActiveNotifications: hasNotifications),
      ],
    );
  }
}
