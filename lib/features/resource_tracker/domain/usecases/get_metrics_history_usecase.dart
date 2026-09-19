import '../entities/daily_metrics_point.dart';
import '../entities/resource_metrics.dart';
import '../repositories/resource_repository.dart';
import '../services/working_calendar.dart';

/// Builds the day-by-day series the Reports trend chart plots, by fetching
/// each *working* day's roster and reducing it to its [ResourceMetrics].
/// Weekly offs and holidays are left out so they never show up as a wave of
/// "Not Updated".
class GetMetricsHistoryUseCase {
  const GetMetricsHistoryUseCase(this._repository);

  final ResourceRepository _repository;

  Future<List<DailyMetricsPoint>> call({
    required DateTime startDate,
    required DateTime endDate,
    required WorkingCalendar calendar,
  }) async {
    final span = endDate.difference(startDate).inDays;
    final dates = [
      for (var i = 0; i <= span; i++) startDate.add(Duration(days: i)),
    ].where(calendar.isWorkingDay).toList();

    final results = await Future.wait(dates.map(_repository.getResources));

    return [
      for (var i = 0; i < dates.length; i++)
        DailyMetricsPoint(date: dates[i], metrics: ResourceMetrics.fromResources(results[i])),
    ];
  }
}
