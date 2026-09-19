import '../entities/day_info.dart';
import '../entities/holiday.dart';

/// Decides whether a date is a working day.
///
/// Weekly-off rule: every Sunday, plus the 2nd and 4th Saturday of each
/// month. Any [Holiday] overrides that and is reported by name. To change
/// the weekly pattern, edit [_weeklyOffLabel].
class WorkingCalendar {
  WorkingCalendar(Iterable<Holiday> holidays)
      : _holidays = {for (final holiday in holidays) _dateOnly(holiday.date): holiday};

  final Map<DateTime, Holiday> _holidays;

  DayInfo dayInfo(DateTime date) {
    final day = _dateOnly(date);

    final holiday = _holidays[day];
    if (holiday != null) return DayInfo.holiday(holiday);

    final weeklyOff = _weeklyOffLabel(day);
    if (weeklyOff != null) return DayInfo.weeklyOff(day, weeklyOff);

    return DayInfo.working(day);
  }

  bool isWorkingDay(DateTime date) => dayInfo(date).isWorking;

  static String? _weeklyOffLabel(DateTime day) {
    if (day.weekday == DateTime.sunday) return 'Sunday';

    if (day.weekday == DateTime.saturday) {
      final occurrence = (day.day - 1) ~/ 7 + 1;
      if (occurrence == 2) return '2nd Saturday';
      if (occurrence == 4) return '4th Saturday';
    }
    return null;
  }

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
}
