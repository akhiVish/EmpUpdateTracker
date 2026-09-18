import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/resource_status.dart';

/// Maps the framework-agnostic [ResourceStatus] to its visual treatment.
/// Kept in the presentation layer so the domain entity stays Flutter-free.
extension ResourceStatusStyle on ResourceStatus {
  Color get color {
    switch (this) {
      case ResourceStatus.updated:
        return AppColors.emerald;
      case ResourceStatus.onLeave:
        return AppColors.amber;
      case ResourceStatus.notUpdated:
        return AppColors.crimson;
    }
  }

  IconData get icon {
    switch (this) {
      case ResourceStatus.updated:
        return Icons.check_circle_rounded;
      case ResourceStatus.onLeave:
        return Icons.wb_sunny_rounded;
      case ResourceStatus.notUpdated:
        return Icons.error_rounded;
    }
  }

  String get label {
    switch (this) {
      case ResourceStatus.updated:
        return 'Updated';
      case ResourceStatus.onLeave:
        return 'On Leave';
      case ResourceStatus.notUpdated:
        return 'Not Updated';
    }
  }

  String get shortLabel {
    switch (this) {
      case ResourceStatus.updated:
        return 'Updated';
      case ResourceStatus.onLeave:
        return 'On Leave';
      case ResourceStatus.notUpdated:
        return 'Pending';
    }
  }
}
