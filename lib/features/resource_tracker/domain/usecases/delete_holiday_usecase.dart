import '../repositories/holiday_repository.dart';

/// Removes a holiday, turning that date back into a normal day.
class DeleteHolidayUseCase {
  const DeleteHolidayUseCase(this._repository);

  final HolidayRepository _repository;

  Future<void> call(String holidayId) => _repository.deleteHoliday(holidayId);
}
