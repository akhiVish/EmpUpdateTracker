import 'package:intl/intl.dart';

/// Formatting helpers for the date navigator and headers.
class AppDateFormatter {
  AppDateFormatter._();

  static final DateFormat _full = DateFormat('EEEE, MMM d, y');
  static final DateFormat _short = DateFormat('MMM d, y');

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String label(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));

    if (isSameDay(date, now)) return 'Today, ${_short.format(date)}';
    if (isSameDay(date, yesterday)) return 'Yesterday, ${_short.format(date)}';
    if (isSameDay(date, tomorrow)) return 'Tomorrow, ${_short.format(date)}';
    return _full.format(date);
  }

  static DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
}
