import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/shared_preference.dart';
import 'package:masar_pro/config/strings.dart';
import 'package:masar_pro/core/presentation/widgets/closed_icon.dart';

class LanguageBottomSheet extends StatelessWidget {
  LanguageBottomSheet({super.key});
  final SharedPref sharedPref = SharedPref.instance;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(top: 32, bottom: 18, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.changeLanguage.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontSize: 20,
                  ),
                ),
                ClosedIcon(onTap: () => Navigator.pop(context)),
              ],
            ),
            SizedBox(height: 25),

            _LanguageOption(
              label: 'english'.tr(),
              isSelected: context.locale.languageCode == 'en',
              onTap: () {
                sharedPref.setString(SharedPrefKeys.languageNmKey, 'en');
                context.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 14),
              child: Divider(color: AppColors.grayHint, height: 1),
            ),
            _LanguageOption(
              label: 'arabic'.tr(),
              isSelected: context.locale.languageCode == 'ar',
              onTap: () {
                sharedPref.setString(SharedPrefKeys.languageNmKey, 'ar');
                context.setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 14, top: 10),
              child: Divider(color: AppColors.grayHint, height: 1),
            ),
            _LanguageOption(
              label: 'french'.tr(),
              isSelected: context.locale.languageCode == 'fr',
              onTap: () {
                sharedPref.setString(SharedPrefKeys.languageNmKey, 'fr');
                context.setLocale(const Locale('fr'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),

        child: Row(
          children: [
            Text(label, style: TextStyle(fontSize: 16, color: AppColors.black)),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}
