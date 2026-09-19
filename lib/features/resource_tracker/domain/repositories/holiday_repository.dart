import '../entities/holiday.dart';

/// Contract for the holiday list. Kept separate from [ResourceRepository]
/// because holidays are their own resource with their own API endpoints.
abstract class HolidayRepository {
  Future<List<Holiday>> getHolidays();

  Future<Holiday> addHoliday({required DateTime date, required String name});

  Future<void> deleteHoliday(String holidayId);
}
