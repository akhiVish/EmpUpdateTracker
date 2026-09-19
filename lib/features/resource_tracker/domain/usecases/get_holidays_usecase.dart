import '../entities/holiday.dart';
import '../repositories/holiday_repository.dart';

/// Fetches every configured holiday, oldest first.
class GetHolidaysUseCase {
  const GetHolidaysUseCase(this._repository);

  final HolidayRepository _repository;

  Future<List<Holiday>> call() => _repository.getHolidays();
}
