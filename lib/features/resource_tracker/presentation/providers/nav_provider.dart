import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The three destinations in the side nav / bottom nav, each backed by a
/// real screen.
enum AppTab {
  dashboard,
  resources,
  reports;

  String get label {
    switch (this) {
      case AppTab.dashboard:
        return 'Dashboard';
      case AppTab.resources:
        return 'Resources';
      case AppTab.reports:
        return 'Reports';
    }
  }
}

class SelectedTabController extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.dashboard;

  void set(AppTab tab) => state = tab;
}

final selectedTabProvider = NotifierProvider<SelectedTabController, AppTab>(
  SelectedTabController.new,
);
