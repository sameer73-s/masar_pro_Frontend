import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:masar_pro/config/app_assets.dart';
import 'package:masar_pro/core/presentation/widgets/language_bottom_sheet.dart';

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key, this.isInside = false});
  final bool isInside;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLanguageBottomSheet(context),
      child: SvgPicture.asset(
        isInside
            ? AppAssetsImages.icLanguageInside
            : AppAssetsImages.icChngLanguage,
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return LanguageBottomSheet();
      },
    );
  }
}
