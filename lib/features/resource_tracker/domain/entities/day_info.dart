import 'package:flutter/foundation.dart';

import 'holiday.dart';

enum DayType { working, weeklyOff, holiday }

/// What kind of day a given date is, and why.
@immutable
class DayInfo {
  const DayInfo._({required this.date, required this.type, this.label, this.holiday});

  factory DayInfo.working(DateTime date) => DayInfo._(date: date, type: DayType.working);

  factory DayInfo.weeklyOff(DateTime date, String label) {
    return DayInfo._(date: date, type: DayType.weeklyOff, label: label);
  }

  factory DayInfo.holiday(Holiday holiday) {
    return DayInfo._(date: holiday.date, type: DayType.holiday, label: holiday.name, holiday: holiday);
  }

  final DateTime date;
  final DayType type;

  /// "Sunday", "2nd Saturday" or the holiday's name; null on working days.
  final String? label;

  /// Set only when [type] is [DayType.holiday].
  final Holiday? holiday;

  bool get isWorking => type == DayType.working;

  /// Human-readable reason this day is off, e.g. "Weekly off · Sunday".
  String get description {
    switch (type) {
      case DayType.working:
        return 'Working day';
      case DayType.weeklyOff:
        return 'Weekly off · $label';
      case DayType.holiday:
        return 'Holiday · $label';
    }
  }
}
