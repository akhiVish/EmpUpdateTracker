import '../../domain/entities/holiday.dart';
import 'holiday_data_source.dart';

/// In-memory holiday list, seeded with a few fixed-date national holidays
/// for last year, this year and next year so past reports and upcoming
/// days both have some to show.
class MockHolidayDataSource implements HolidayDataSource {
  MockHolidayDataSource() : _holidays = _seed();

  final List<Holiday> _holidays;
  int _autoId = 0;

  static const List<(int month, int day, String name)> _fixedHolidays = [
    (1, 26, 'Republic Day'),
    (8, 15, 'Independence Day'),
    (10, 2, 'Gandhi Jayanti'),
    (12, 25, 'Christmas'),
  ];

  static List<Holiday> _seed() {
    final year = DateTime.now().year;
    return [
      for (final y in [year - 1, year, year + 1])
        for (final fixed in _fixedHolidays)
          Holiday(id: 'hol-$y-${fixed.$1}-${fixed.$2}', date: DateTime(y, fixed.$1, fixed.$2), name: fixed.$3),
    ];
  }

  @override
  Future<List<Holiday>> fetchHolidays() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return [..._holidays]..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<Holiday> addHoliday({required DateTime date, required String name}) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _autoId += 1;
    final holiday = Holiday(id: 'hol-new-$_autoId', date: DateTime(date.year, date.month, date.day), name: name);
    _holidays.add(holiday);
    return holiday;
  }

  @override
  Future<void> deleteHoliday(String holidayId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _holidays.removeWhere((holiday) => holiday.id == holidayId);
  }
}
