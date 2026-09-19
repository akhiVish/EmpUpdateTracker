import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/day_info.dart';
import '../../domain/entities/holiday.dart';
import '../../domain/services/working_calendar.dart';
import 'dashboard_filters_provider.dart';
import 'repository_providers.dart';

/// The configured holidays. Adding/removing one updates every screen that
/// depends on [workingCalendarProvider] (dashboard banner, reports).
class HolidaysNotifier extends AsyncNotifier<List<Holiday>> {
  @override
  Future<List<Holiday>> build() => ref.watch(getHolidaysUseCaseProvider)();

  Future<void> addHoliday({required DateTime date, required String name}) async {
    final created = await ref.read(addHolidayUseCaseProvider)(date: date, name: name);
    final current = state.value ?? const <Holiday>[];
    state = AsyncData([...current, created]..sort((a, b) => a.date.compareTo(b.date)));
  }

  Future<void> deleteHoliday(String holidayId) async {
    final current = state.value ?? const <Holiday>[];
    state = AsyncData([for (final holiday in current) if (holiday.id != holidayId) holiday]);
    await ref.read(deleteHolidayUseCaseProvider)(holidayId);
  }
}

final holidaysProvider = AsyncNotifierProvider<HolidaysNotifier, List<Holiday>>(
  HolidaysNotifier.new,
);

/// Working-day rules + the current holiday list. Empty holiday list until
/// the holidays load, so weekly offs still apply immediately.
final workingCalendarProvider = Provider<WorkingCalendar>((ref) {
  return WorkingCalendar(ref.watch(holidaysProvider).value ?? const <Holiday>[]);
});

/// Working / weekly-off / holiday info for the dashboard's selected date.
final selectedDayInfoProvider = Provider<DayInfo>((ref) {
  return ref.watch(workingCalendarProvider).dayInfo(ref.watch(selectedDateProvider));
});
