import '../../domain/entities/holiday.dart';
import '../../domain/repositories/holiday_repository.dart';
import '../datasources/holiday_data_source.dart';

/// Bridges the domain layer to a [HolidayDataSource].
class HolidayRepositoryImpl implements HolidayRepository {
  const HolidayRepositoryImpl(this._dataSource);

  final HolidayDataSource _dataSource;

  @override
  Future<List<Holiday>> getHolidays() => _dataSource.fetchHolidays();

  @override
  Future<Holiday> addHoliday({required DateTime date, required String name}) {
    return _dataSource.addHoliday(date: date, name: name);
  }

  @override
  Future<void> deleteHoliday(String holidayId) => _dataSource.deleteHoliday(holidayId);
}
