import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../config/app_colors.dart';
import '../../../domain/entities/date_status_summary.dart';
import 'smart_date_chip.dart';

/// Horizontal date strip with a Today jump and a calendar picker.
class SmartDateSelector extends StatefulWidget {
  const SmartDateSelector({
    super.key,
    required this.selectedDate,
    required this.dateSummaries,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final Map<DateTime, DateStatusSummary> dateSummaries;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<SmartDateSelector> createState() => _SmartDateSelectorState();
}

class _SmartDateSelectorState extends State<SmartDateSelector> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(SmartDateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!AgencyCalendarRange.isSameDay(
      oldWidget.selectedDate,
      widget.selectedDate,
    )) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<DateTime> get _dates =>
      AgencyCalendarRange.visibleDates(widget.selectedDate);

  DateStatusSummary _summaryFor(DateTime date) {
    return widget.dateSummaries[AgencyCalendarRange.dateOnly(date)] ??
        const DateStatusSummary();
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients) return;
    final dates = _dates;
    final index = dates.indexWhere(
      (d) => AgencyCalendarRange.isSameDay(d, widget.selectedDate),
    );
    if (index < 0) return;

    const chipWidth = 52.0;
    const separator = 8.0;
    final offset = index * (chipWidth + separator);
    final max = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      offset.clamp(0.0, max),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return;
    widget.onDateSelected(AgencyCalendarRange.dateOnly(picked));
  }

  @override
  Widget build(BuildContext context) {
    final today = AgencyCalendarRange.dateOnly(DateTime.now());
    final isTodaySelected = AgencyCalendarRange.isSameDay(
      widget.selectedDate,
      today,
    );
    final dates = _dates;

    return SizedBox(
      height: 86,
      child: Row(
        children: [
          _TodayButton(
            isSelected: isTodaySelected,
            onTap: () => widget.onDateSelected(today),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final date = dates[index];
                return SmartDateChip(
                  date: date,
                  isSelected: AgencyCalendarRange.isSameDay(
                    date,
                    widget.selectedDate,
                  ),
                  summary: _summaryFor(date),
                  onTap: () => widget.onDateSelected(date),
                );
              },
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'jumpToDate'.tr(),
            onPressed: _openDatePicker,
            icon: const Icon(Icons.calendar_month_outlined),
            color: AppColors.accentPurple,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _TodayButton extends StatelessWidget {
  const _TodayButton({required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.accentPurple : AppColors.surfacePurple,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: Text(
            'today'.tr(),
            style: TextStyle(
              color: isSelected ? AppColors.background : AppColors.accentPurple,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
