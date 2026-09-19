import 'package:flutter/foundation.dart';

/// A one-off non-working day (festival, company event, etc.) on top of the
/// regular weekly offs.
@immutable
class Holiday {
  const Holiday({required this.id, required this.date, required this.name});

  final String id;

  /// Date-only (time is ignored).
  final DateTime date;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Holiday && id == other.id && date == other.date && name == other.name;

  @override
  int get hashCode => Object.hash(id, date, name);
}
