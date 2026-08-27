import 'package:easy_localization/easy_localization.dart';
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

  /// Localized default when no logged-in display name is available.
  static String defaultDisplayName() => 'defaultUserName'.tr();

  /// Resolves [rawName] to a display name, falling back to [defaultDisplayName].
  static String resolveDisplayName(String? rawName) {
    final trimmed = rawName?.trim() ?? '';
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'user') {
      return defaultDisplayName();
    }
    return trimmed;
  }

  Future<void> _toggleLocale(BuildContext context) async {
    if (context.locale.languageCode == 'ar') {
      await context.setLocale(const Locale('en'));
    } else {
      await context.setLocale(const Locale('ar'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = resolveDisplayName(userName);
    final languageCode = context.locale.languageCode;

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
                    Text(
                      'hello'.tr(context: context),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      displayName,
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
        IconButton(
          tooltip: 'changeLanguage'.tr(context: context),
          onPressed: () => _toggleLocale(context),
          icon: Text(
            languageCode == 'ar' ? 'EN' : 'AR',
            style: const TextStyle(
              color: AppColors.accentPurple,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        NotificationBell(hasActiveNotifications: hasNotifications),
      ],
    );
  }
}
