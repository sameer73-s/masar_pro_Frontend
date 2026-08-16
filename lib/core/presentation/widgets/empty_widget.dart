import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:masar_pro/config/app_assets.dart';
import 'package:masar_pro/config/strings.dart';
import '../../../config/app_colors.dart';

class EmptyWidget extends StatelessWidget {
  final String? message;
  final IconData icon;

  const EmptyWidget({super.key, this.message, this.icon = Icons.inbox_rounded});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(AppAssetsImages.icEmptyReport),
          Center(
            child: Text(
              message?.tr() ?? Strings.noDataFound.tr(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }
}
