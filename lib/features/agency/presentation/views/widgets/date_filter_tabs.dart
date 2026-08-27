import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/presentation/widgets/filter_tab_bar.dart';
import '../../../domain/enums/date_filter_mode.dart';

/// Segmented `[ All ] [ Created ] [ Due ]` control for date matching.
class DateFilterTabs extends StatelessWidget {
  const DateFilterTabs({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final DateFilterMode mode;
  final ValueChanged<DateFilterMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterTabBar(
      tabs: [
        'dateFilterAll'.tr(),
        'dateFilterCreated'.tr(),
        'dateFilterDue'.tr(),
      ],
      selectedIndex: mode.index,
      onTabSelected: (index) => onChanged(DateFilterMode.values[index]),
    );
  }
}
