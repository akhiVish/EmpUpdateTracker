import '../../domain/entities/resource_status.dart';

/// Quick-filter chip selection: "All" plus each [ResourceStatus].
enum StatusFilter {
  all,
  updated,
  onLeave,
  notUpdated;

  String get label {
    switch (this) {
      case StatusFilter.all:
        return 'All';
      case StatusFilter.updated:
        return 'Updated';
      case StatusFilter.onLeave:
        return 'On Leave';
      case StatusFilter.notUpdated:
        return 'Not Updated';
    }
  }

  bool matches(ResourceStatus status) {
    switch (this) {
      case StatusFilter.all:
        return true;
      case StatusFilter.updated:
        return status == ResourceStatus.updated;
      case StatusFilter.onLeave:
        return status == ResourceStatus.onLeave;
      case StatusFilter.notUpdated:
        return status == ResourceStatus.notUpdated;
    }
  }
}
