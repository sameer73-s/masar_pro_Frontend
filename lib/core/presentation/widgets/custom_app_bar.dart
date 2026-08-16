import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';
import '../../../config/typography.dart';

/// Shared flat AppBar — white background, dark centered title, optional actions.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton,
  });

  final String title;
  final List<Widget>? actions;

  /// When null, a custom back button is shown only if the route can pop.
  final bool? showBackButton;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final shouldShowBack = showBackButton ?? canPop;

    return AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: shouldShowBack
          ? IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            )
          : null,
      title: Text(
        title,
        style: AppTypography.title(
          fontSize: 18,
          color: AppColors.primary,
          context: context,
        ),
      ),
      actions: actions,
    );
  }
}
