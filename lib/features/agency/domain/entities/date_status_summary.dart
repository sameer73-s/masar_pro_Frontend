import 'package:equatable/equatable.dart';

/// Per-day status dots for the smart horizontal calendar.
class DateStatusSummary extends Equatable {
  /// Purple — at least one task is created on or due this date.
  final bool hasTasks;

  /// Yellow — at least one open task associated with this date is due tomorrow.
  final bool deadlineTomorrow;

  /// Red — at least one open task associated with this date is already overdue.
  final bool isOverdue;

  const DateStatusSummary({
    this.hasTasks = false,
    this.deadlineTomorrow = false,
    this.isOverdue = false,
  });

  bool get hasAnyIndicator => hasTasks || deadlineTomorrow || isOverdue;

  @override
  List<Object?> get props => [hasTasks, deadlineTomorrow, isOverdue];
}

/// Calendar-day helpers shared by the agency BLoC and smart date selector.
class AgencyCalendarRange {
  AgencyCalendarRange._();

  static const int lookbehindDays = 2;
  static const int lookaheadDays = 7;

  static DateTime dateOnly(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  static bool isSameDay(DateTime a, DateTime b) => dateOnly(a) == dateOnly(b);

  /// Default strip: previous 2 days + today + next 7 days.
  /// If [selected] is outside that window, the strip is recentered on it.
  static List<DateTime> visibleDates(DateTime selected, {DateTime? now}) {
    final today = dateOnly(now ?? DateTime.now());
    final sel = dateOnly(selected);
    final defaultStart = today.subtract(const Duration(days: lookbehindDays));
    final defaultEnd = today.add(const Duration(days: lookaheadDays));

    final DateTime start;
    final DateTime end;
    if (!sel.isBefore(defaultStart) && !sel.isAfter(defaultEnd)) {
      start = defaultStart;
      end = defaultEnd;
    } else {
      start = sel.subtract(const Duration(days: lookbehindDays));
      end = sel.add(const Duration(days: lookaheadDays));
    }

    final dayCount = end.difference(start).inDays + 1;
    return List<DateTime>.generate(
      dayCount,
      (i) => DateTime(start.year, start.month, start.day + i),
    );
  }
}
