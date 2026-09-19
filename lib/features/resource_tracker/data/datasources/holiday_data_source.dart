import '../../domain/entities/holiday.dart';

/// Contract for wherever holidays live. Same swap-in idea as
/// [ResourceDataSource]: implement this against the real API and change the
/// provider in `repository_providers.dart`.
abstract class HolidayDataSource {
  /// Every holiday, oldest first.
  Future<List<Holiday>> fetchHolidays();

  Future<Holiday> addHoliday({required DateTime date, required String name});

  Future<void> deleteHoliday(String holidayId);
}
