import 'package:easy_localization/easy_localization.dart';
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
    this.showLanguageToggle = true,
  });

  /// App bar title. Prefer a translation key (e.g. `'academicWorkspace'`)
  /// so the label updates automatically when the locale changes.
  /// Dynamic titles that are not keys are shown as-is.
  final String title;
  final List<Widget>? actions;

  /// When null, a custom back button is shown only if the route can pop.
  final bool? showBackButton;

  /// When true (default), shows a locale toggle (AR/EN) in [actions].
  final bool showLanguageToggle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Future<void> _toggleLocale(BuildContext context) async {
    if (context.locale.languageCode == 'ar') {
      await context.setLocale(const Locale('en'));
    } else {
      await context.setLocale(const Locale('ar'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final shouldShowBack = showBackButton ?? canPop;
    final languageCode = context.locale.languageCode;
    final resolvedTitle =
        title.trExists(context: context) ? title.tr(context: context) : title;

    final resolvedActions = <Widget>[
      ...?actions,
      if (showLanguageToggle)
        IconButton(
          tooltip: 'changeLanguage'.tr(context: context),
          onPressed: () => _toggleLocale(context),
          icon: Text(
            languageCode == 'ar' ? 'EN' : 'AR',
            style: AppTypography.title(
              fontSize: 13,
              color: AppColors.accentPurple,
              context: context,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ),
    ];

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
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            )
          : null,
      title: Text(
        resolvedTitle,
        style: AppTypography.title(
          fontSize: 18,
          color: AppColors.primary,
          context: context,
        ),
      ),
      actions: resolvedActions.isEmpty ? null : resolvedActions,
    );
  }
}
