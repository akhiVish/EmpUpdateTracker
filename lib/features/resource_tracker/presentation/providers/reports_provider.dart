import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/daily_metrics_point.dart';
import '../../domain/entities/resource_history_point.dart';
import 'repository_providers.dart';

/// Quick presets for the Reports date range, plus a fully custom range
/// picked via [showDateRangePicker].
enum ReportRangePreset {
  today,
  last3Days,
  last7Days,
  last30Days,
  custom;

  String get label {
    switch (this) {
      case ReportRangePreset.today:
        return 'Today';
      case ReportRangePreset.last3Days:
        return 'Last 3 Days';
      case ReportRangePreset.last7Days:
        return 'Last 7 Days';
      case ReportRangePreset.last30Days:
        return 'Last 30 Days';
      case ReportRangePreset.custom:
        return 'Custom Range';
    }
  }
}

class ReportRangePresetController extends Notifier<ReportRangePreset> {
  @override
  ReportRangePreset build() => ReportRangePreset.last7Days;

  void set(ReportRangePreset preset) => state = preset;
}

final reportRangePresetProvider = NotifierProvider<ReportRangePresetController, ReportRangePreset>(
  ReportRangePresetController.new,
);

/// The explicit start/end picked when [ReportRangePreset.custom] is active.
class CustomReportRangeController extends Notifier<DateTimeRange?> {
  @override
  DateTimeRange? build() => null;

  void set(DateTimeRange range) => state = range;
}

final customReportRangeProvider = NotifierProvider<CustomReportRangeController, DateTimeRange?>(
  CustomReportRangeController.new,
);

/// The resource currently drilled into on the Reports screen; null shows
/// the all-resources aggregate view.
class SelectedReportResourceController extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? resourceId) => state = resourceId;

  void clear() => state = null;
}

final selectedReportResourceIdProvider = NotifierProvider<SelectedReportResourceController, String?>(
  SelectedReportResourceController.new,
);

/// Resolves the active preset (or custom pick) into a concrete, date-only
/// start/end range, anchored on today.
final effectiveReportRangeProvider = Provider<DateTimeRange>((ref) {
  final preset = ref.watch(reportRangePresetProvider);
  final today = AppDateFormatter.dateOnly(DateTime.now());

  switch (preset) {
    case ReportRangePreset.today:
      return DateTimeRange(start: today, end: today);
    case ReportRangePreset.last3Days:
      return DateTimeRange(start: today.subtract(const Duration(days: 2)), end: today);
    case ReportRangePreset.last7Days:
      return DateTimeRange(start: today.subtract(const Duration(days: 6)), end: today);
    case ReportRangePreset.last30Days:
      return DateTimeRange(start: today.subtract(const Duration(days: 29)), end: today);
    case ReportRangePreset.custom:
      final custom = ref.watch(customReportRangeProvider);
      if (custom == null) return DateTimeRange(start: today.subtract(const Duration(days: 6)), end: today);
      return DateTimeRange(start: AppDateFormatter.dateOnly(custom.start), end: AppDateFormatter.dateOnly(custom.end));
  }
});

/// Aggregate day-by-day metrics for the active range (all resources).
final metricsHistoryProvider = FutureProvider.autoDispose<List<DailyMetricsPoint>>((ref) async {
  final range = ref.watch(effectiveReportRangeProvider);
  final getHistory = ref.watch(getMetricsHistoryUseCaseProvider);
  return getHistory(startDate: range.start, endDate: range.end);
});

/// Day-by-day status/notes for the drilled-into resource, over the active
/// range. Empty when no resource is selected.
final resourceHistoryProvider = FutureProvider.autoDispose<List<ResourceHistoryPoint>>((ref) async {
  final resourceId = ref.watch(selectedReportResourceIdProvider);
  if (resourceId == null) return const [];

  final range = ref.watch(effectiveReportRangeProvider);
  final getHistory = ref.watch(getResourceHistoryUseCaseProvider);
  return getHistory(resourceId: resourceId, startDate: range.start, endDate: range.end);
});
