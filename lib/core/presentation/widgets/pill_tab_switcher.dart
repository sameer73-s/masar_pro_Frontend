import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:masar_pro/config/app_colors.dart';
import 'package:masar_pro/config/extensions.dart';
import 'package:masar_pro/config/typography.dart';

/// Pill segmented control: white track, sliding primary highlight, localized
/// labels. Mirrors native `cv_tabs` used on attendance.
class PillTabSwitcher extends StatelessWidget {
  const PillTabSwitcher({
    super.key,
    required this.labelKeys,
    required this.selectedIndex,
    required this.onChanged,
    this.width,
    // this.trackColor = AppColors.white,
    this.trackBorderColor,
  });

  final List<String> labelKeys;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// When null, the switcher expands to the parent width.
  final double? width;
  // final Color trackColor;
  final Color? trackBorderColor;

  @override
  Widget build(BuildContext context) {
    assert(labelKeys.length >= 2, 'PillTabSwitcher needs at least 2 tabs');
    final tabCount = labelKeys.length;
    final clampedIndex = selectedIndex.clamp(0, tabCount - 1);
    final alignmentX = tabCount == 1
        ? 0.0
        : -1 + (2 * clampedIndex / (tabCount - 1));

    return Container(
      width: width,
      height: 36.h,
      decoration: BoxDecoration(
        // color: trackColor,
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(
          color:
              trackBorderColor ??
              AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
      // LTR layout keeps the sliding pill aligned with tab indices in RTL locales.
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment: Alignment(alignmentX, 0),
              child: FractionallySizedBox(
                widthFactor: 1 / tabCount,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < tabCount; i++)
                  Expanded(
                    child: _PillTabLabel(
                      labelKey: labelKeys[i],
                      selected: clampedIndex == i,
                      onTap: () => onChanged(i),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PillTabLabel extends StatelessWidget {
  const _PillTabLabel({
    required this.labelKey,
    required this.selected,
    required this.onTap,
  });

  final String labelKey;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Text(
          labelKey.tr(),
          style: AppTypography.label(
            color: selected ? AppColors.white : AppColors.primary,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}
