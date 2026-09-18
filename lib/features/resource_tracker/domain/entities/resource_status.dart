/// The three explicit daily-update states a resource can be in.
///
/// Framework-agnostic by design: presentation-layer code maps each value
/// to a color/icon/label so this entity stays free of Flutter imports.
enum ResourceStatus {
  updated,
  onLeave,
  notUpdated;

  /// Cycles Updated -> On Leave -> Not Updated -> Updated for the
  /// "quick action" one-click status toggle.
  ResourceStatus get next {
    switch (this) {
      case ResourceStatus.updated:
        return ResourceStatus.onLeave;
      case ResourceStatus.onLeave:
        return ResourceStatus.notUpdated;
      case ResourceStatus.notUpdated:
        return ResourceStatus.updated;
    }
  }
}
