import 'package:flutter/material.dart';
import '../../../../../../core/presentation/widgets/app_bar_greeting.dart';

/// Dashboard greeting header — delegates to [AppBarGreeting].
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.userName,
    this.avatarUrl,
    this.hasNotifications = true,
  });

  final String userName;
  final String? avatarUrl;
  final bool hasNotifications;

  @override
  Widget build(BuildContext context) {
    return AppBarGreeting(
      userName: userName,
      avatarUrl: avatarUrl,
      hasNotifications: hasNotifications,
    );
  }
}
