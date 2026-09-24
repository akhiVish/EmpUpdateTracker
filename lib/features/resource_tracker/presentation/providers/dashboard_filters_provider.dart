import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_formatter.dart';
import 'status_filter.dart';

/// The day currently shown across the header, metrics and list.
class SelectedDateController extends Notifier<DateTime> {
  @override
  DateTime build() => AppDateFormatter.dateOnly(DateTime.now());

  void set(DateTime date) {
    final normalized = AppDateFormatter.dateOnly(date);
    final today = AppDateFormatter.dateOnly(DateTime.now());
    state = normalized.isAfter(today) ? today : normalized;
  }

  void previousDay() => state = state.subtract(const Duration(days: 1));

  void nextDay() {
    final today = AppDateFormatter.dateOnly(DateTime.now());
    if (state.isBefore(today)) {
      state = state.add(const Duration(days: 1));
    }
  }

  void today() => state = AppDateFormatter.dateOnly(DateTime.now());
}

final selectedDateProvider = NotifierProvider<SelectedDateController, DateTime>(
  SelectedDateController.new,
);

/// Free-text query from the header search bar (matches name or mobile number).
class SearchQueryController extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;

  void clear() => state = '';
}

final searchQueryProvider = NotifierProvider<SearchQueryController, String>(
  SearchQueryController.new,
);

/// Active quick-filter chip.
class StatusFilterController extends Notifier<StatusFilter> {
  @override
  StatusFilter build() => StatusFilter.all;

  void set(StatusFilter filter) => state = filter;
}

final statusFilterProvider = NotifierProvider<StatusFilterController, StatusFilter>(
  StatusFilterController.new,
);
