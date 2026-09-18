import 'package:flutter/foundation.dart';

import 'resource_status.dart';

/// A single team member tracked in the daily activity dashboard.
@immutable
class Resource {
  const Resource({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.status,
    this.notes = '',
  });

  final String id;
  final String name;
  final String mobileNumber;
  final ResourceStatus status;
  final String notes;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Resource copyWith({
    String? id,
    String? name,
    String? mobileNumber,
    ResourceStatus? status,
    String? notes,
  }) {
    return Resource(
      id: id ?? this.id,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Resource &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          mobileNumber == other.mobileNumber &&
          status == other.status &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(id, name, mobileNumber, status, notes);
}
