import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:update_tracker/main.dart';

void main() {
  testWidgets('Dashboard renders header, metrics and roster', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ResourceTrackerApp()));
    await tester.pumpAndSettle();

    expect(find.text('Daily Resource Activity Tracker'), findsOneWidget);
    expect(find.text('Total Resources'), findsOneWidget);
    expect(find.text('Girish'), findsOneWidget);
  });
}
