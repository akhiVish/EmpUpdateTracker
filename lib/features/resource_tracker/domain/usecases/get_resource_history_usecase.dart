import '../entities/day_info.dart';
import '../entities/resource.dart';
import '../entities/resource_history_point.dart';
import '../repositories/resource_repository.dart';
import '../services/working_calendar.dart';

/// Builds one resource's day-by-day status/notes timeline over a date
/// range, for the Reports screen's per-resource drill-down. Off days
/// (weekly offs and holidays) appear as labelled off-day entries instead of
/// being fetched.
class GetResourceHistoryUseCase {
  const GetResourceHistoryUseCase(this._repository);

  final ResourceRepository _repository;

  Future<List<ResourceHistoryPoint>> call({
    required String resourceId,
    required DateTime startDate,
    required DateTime endDate,
    required WorkingCalendar calendar,
  }) async {
    final span = endDate.difference(startDate).inDays;
    final days = [for (var i = 0; i <= span; i++) calendar.dayInfo(startDate.add(Duration(days: i)))];

    final workingDays = days.where((day) => day.isWorking).toList();
    final rosters = await Future.wait(workingDays.map((day) => _repository.getResources(day.date)));
    final rosterByDate = {for (var i = 0; i < workingDays.length; i++) workingDays[i].date: rosters[i]};

    final points = <ResourceHistoryPoint>[];
    for (final day in days) {
      if (day.type != DayType.working) {
        points.add(ResourceHistoryPoint.offDay(date: day.date, offLabel: day.description));
        continue;
      }

      Resource? match;
      for (final resource in rosterByDate[day.date] ?? const <Resource>[]) {
        if (resource.id == resourceId) {
          match = resource;
          break;
        }
      }
      if (match != null) {
        points.add(ResourceHistoryPoint(date: day.date, status: match.status, notes: match.notes));
      }
    }
    return points;
  }
}
