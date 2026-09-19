import '../entities/holiday.dart';
import '../repositories/holiday_repository.dart';

/// Marks a date as a holiday.
class AddHolidayUseCase {
  const AddHolidayUseCase(this._repository);

  final HolidayRepository _repository;

  Future<Holiday> call({required DateTime date, required String name}) {
    return _repository.addHoliday(date: date, name: name);
  }
}
