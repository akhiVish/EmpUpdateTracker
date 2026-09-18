import '../entities/resource.dart';
import '../entities/resource_history_point.dart';
import '../repositories/resource_repository.dart';

/// Builds one resource's day-by-day status/notes timeline over a date
/// range, for the Reports screen's per-resource drill-down.
class GetResourceHistoryUseCase {
  const GetResourceHistoryUseCase(this._repository);

  final ResourceRepository _repository;

  Future<List<ResourceHistoryPoint>> call({
    required String resourceId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final days = endDate.difference(startDate).inDays;
    final dates = [for (var i = 0; i <= days; i++) startDate.add(Duration(days: i))];

    final results = await Future.wait(dates.map(_repository.getResources));

    final points = <ResourceHistoryPoint>[];
    for (var i = 0; i < dates.length; i++) {
      Resource? match;
      for (final resource in results[i]) {
        if (resource.id == resourceId) {
          match = resource;
          break;
        }
      }
      if (match != null) {
        points.add(ResourceHistoryPoint(date: dates[i], status: match.status, notes: match.notes));
      }
    }
    return points;
  }
}
