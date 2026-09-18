import '../entities/daily_metrics_point.dart';
import '../entities/resource_metrics.dart';
import '../repositories/resource_repository.dart';

/// Builds the day-by-day series the Reports trend chart plots, by fetching
/// each day's roster and reducing it to its [ResourceMetrics].
class GetMetricsHistoryUseCase {
  const GetMetricsHistoryUseCase(this._repository);

  final ResourceRepository _repository;

  Future<List<DailyMetricsPoint>> call({required DateTime startDate, required DateTime endDate}) async {
    final days = endDate.difference(startDate).inDays;
    final dates = [for (var i = 0; i <= days; i++) startDate.add(Duration(days: i))];

    final results = await Future.wait(dates.map(_repository.getResources));

    return [
      for (var i = 0; i < dates.length; i++)
        DailyMetricsPoint(date: dates[i], metrics: ResourceMetrics.fromResources(results[i])),
    ];
  }
}
