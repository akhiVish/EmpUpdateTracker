import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:update_tracker/features/resource_tracker/data/datasources/mock_holiday_data_source.dart';
import 'package:update_tracker/features/resource_tracker/data/datasources/mock_resource_data_source.dart';
import 'package:update_tracker/features/resource_tracker/presentation/providers/dashboard_filters_provider.dart';
import 'package:update_tracker/features/resource_tracker/presentation/providers/repository_providers.dart';
import 'package:update_tracker/features/resource_tracker/presentation/screens/dashboard_screen.dart';

/// Pins the dashboard to a fixed date so the tests don't depend on the day
/// they happen to run (weekends and holidays render differently).
class _FixedDate extends SelectedDateController {
  _FixedDate(this._date);

  final DateTime _date;

  @override
  DateTime build() => _date;
}

/// Widget tests must never touch the real Firestore backend — no network in
/// the test runner, and no reason to read/write production data. Overriding
/// the data-source providers back to the in-memory mocks is exactly what
/// this DI seam is for.
///
/// Pumps [DashboardScreen] directly rather than the app's root widget,
/// since the root also gates on Firebase Auth's session stream — that needs
/// a real (or faked) Firebase session, which is out of scope for these
/// dashboard-behavior tests.
Widget _appOn(DateTime date) {
  return ProviderScope(
    overrides: [
      selectedDateProvider.overrideWith(() => _FixedDate(date)),
      resourceDataSourceProvider.overrideWith((ref) => MockResourceDataSource()),
      holidayDataSourceProvider.overrideWith((ref) => MockHolidayDataSource()),
    ],
    child: const MaterialApp(home: DashboardScreen()),
  );
}

void main() {
  testWidgets('Dashboard renders header, metrics and roster on a working day', (WidgetTester tester) async {
    await tester.pumpWidget(_appOn(DateTime(2026, 9, 16))); // Wednesday
    await tester.pumpAndSettle();

    expect(find.text('Daily Resource Activity Tracker'), findsOneWidget);
    expect(find.text('Total Resources'), findsOneWidget);
    expect(find.text('Girish'), findsOneWidget);
    expect(find.textContaining('Weekly off'), findsNothing);
  });

  testWidgets('Dashboard shows the weekly-off banner instead of the roster on a Sunday', (WidgetTester tester) async {
    await tester.pumpWidget(_appOn(DateTime(2026, 9, 20))); // Sunday
    await tester.pumpAndSettle();

    expect(find.text('Weekly off · Sunday'), findsOneWidget);
    expect(find.text('Total Resources'), findsNothing);
    expect(find.text('Girish'), findsNothing);
  });

  testWidgets('Dashboard shows the holiday banner on a seeded holiday', (WidgetTester tester) async {
    final year = DateTime.now().year;
    await tester.pumpWidget(_appOn(DateTime(year, 10, 2))); // Gandhi Jayanti
    await tester.pumpAndSettle();

    expect(find.text('Holiday · Gandhi Jayanti'), findsOneWidget);
    expect(find.text('Remove holiday'), findsOneWidget);
  });
}
