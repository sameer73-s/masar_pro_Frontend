import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Shared date/time picker and formatting for request flows.
abstract final class DateTimeHelper {
  static Future<void> pickDate(
    BuildContext context, {

    ///'dd/MM/yyyy' format string, e.g. '25/12/2023'.
    String initialDate = '',

    ///'dd/MM/yyyy' format string, e.g. '25/12/2023'.
    String firstDate = '',
    String initialLastDate = '',
    required ValueChanged<DateTime> onPicked,
  }) async {
    DateFormat('dd/MM/yyyy').tryParse(initialDate);
    final now = DateTime.now();
    var initialDateFormatted = DateFormat('dd/MM/yyyy').tryParse(initialDate);
    final firstFormatted = DateFormat('dd/MM/yyyy').tryParse(firstDate);

    final DateTime f;

    if (firstFormatted == null) {
      f = DateTime(initialDateFormatted?.year ?? now.year - 10);
    } else if (initialDateFormatted == null) {
      f = firstFormatted;
    } else if (initialDateFormatted.isBefore(firstFormatted)) {
      initialDateFormatted = f = firstFormatted;
    } else {
      f = firstFormatted;
    }
    final pickedDate = await showDatePicker(
      context: context,
      locale: context.locale,
      initialDate: initialDateFormatted ?? now,
      firstDate: f,
      lastDate: DateTime(now.year + 10),
    );
    if (pickedDate != null) onPicked(pickedDate);
  }

  static Future<void> pickTime(
    BuildContext context, {
    required TimeOfDay? initialTime,
    required ValueChanged<TimeOfDay> onPicked,
  }) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) onPicked(pickedTime);
  }

  /// dd/MM/yyyy (used by vacation, task, permit, assignment request UIs).
  static String formatDateDdMmYyyy(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$day/$month/$year';
  }

  /// yyyy-MM-dd (fingerprint exempted request fields).
  static String formatDateYyyyMmDd(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String formatTimeHhMm(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String formatTimeHhMmSs(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  /// يحسب المدة بين وقتين بصيغة HH:mm (يتجاهل الثواني إن وُجدت).
  /// يعيد null إذا كان أحد الوقتين غير صالح أو from > to.
  static String? calculateDurationHhMm(String fromTime, String toTime) {
    final fromMinutes = _timeToMinutes(fromTime);
    final toMinutes = _timeToMinutes(toTime);
    if (fromMinutes == null || toMinutes == null) return null;
    if (toMinutes < fromMinutes) return null;
    final diff = toMinutes - fromMinutes;
    final hours = (diff ~/ 60).toString().padLeft(2, '0');
    final minutes = (diff % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  static int? _timeToMinutes(String raw) {
    final parts = raw.trim().split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  /// Parses `yyyy-MM-dd`, `dd/MM/yyyy`, or a leading date in a longer string.
  static DateTime? parseFlexibleDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    final iso = DateTime.tryParse(s);
    if (iso != null) return DateTime(iso.year, iso.month, iso.day);

    final dateToken = s.split(RegExp(r'[\s(]')).first;
    final parts = dateToken.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  /// Normalizes any supported date string to native display `dd/MM/yyyy`.
  static String toDisplayDate(String raw) {
    final parsed = parseFlexibleDate(raw);
    if (parsed == null) return raw.trim();
    return formatDateDdMmYyyy(parsed);
  }
}
