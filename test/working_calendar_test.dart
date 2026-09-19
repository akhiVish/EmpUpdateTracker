import 'package:flutter_test/flutter_test.dart';
import 'package:update_tracker/features/resource_tracker/domain/entities/day_info.dart';
import 'package:update_tracker/features/resource_tracker/domain/entities/holiday.dart';
import 'package:update_tracker/features/resource_tracker/domain/services/working_calendar.dart';

void main() {
  // September 2026: Saturdays are the 5th, 12th, 19th and 26th.
  final calendar = WorkingCalendar([
    Holiday(id: 'h1', date: DateTime(2026, 10, 2), name: 'Gandhi Jayanti'),
    Holiday(id: 'h2', date: DateTime(2026, 9, 20), name: 'Company Day'),
  ]);

  test('1st, 3rd and 5th Saturdays are working days', () {
    expect(DateTime(2026, 9, 5).weekday, DateTime.saturday);
    expect(calendar.isWorkingDay(DateTime(2026, 9, 5)), isTrue);
    expect(calendar.isWorkingDay(DateTime(2026, 9, 19)), isTrue);
    expect(calendar.isWorkingDay(DateTime(2026, 10, 31)), isTrue); // 5th Saturday
  });

  test('2nd and 4th Saturdays are weekly offs', () {
    final second = calendar.dayInfo(DateTime(2026, 9, 12));
    final fourth = calendar.dayInfo(DateTime(2026, 9, 26));

    expect(second.type, DayType.weeklyOff);
    expect(second.label, '2nd Saturday');
    expect(fourth.type, DayType.weeklyOff);
    expect(fourth.label, '4th Saturday');
  });

  test('Sundays are weekly offs, weekdays are working', () {
    expect(calendar.dayInfo(DateTime(2026, 9, 13)).label, 'Sunday');
    expect(calendar.isWorkingDay(DateTime(2026, 9, 16)), isTrue); // Wednesday
  });

  test('holidays are off and carry their name', () {
    final info = calendar.dayInfo(DateTime(2026, 10, 2, 15, 30)); // time ignored
    expect(info.type, DayType.holiday);
    expect(info.description, 'Holiday · Gandhi Jayanti');
    expect(info.holiday?.id, 'h1');
  });

  test('a holiday on a Sunday is reported as the holiday', () {
    expect(DateTime(2026, 9, 20).weekday, DateTime.sunday);
    expect(calendar.dayInfo(DateTime(2026, 9, 20)).type, DayType.holiday);
  });
}
