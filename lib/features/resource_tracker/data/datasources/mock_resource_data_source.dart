import 'dart:math' as math;

import '../../domain/entities/resource.dart';
import '../../domain/entities/resource_status.dart';
import 'resource_data_source.dart';

class _Person {
  _Person({required this.id, required this.name, required this.mobileNumber});

  final String id;
  String name;
  String mobileNumber;
}

/// In-memory mock "backend" for the tracker.
///
/// Holds one mutable master roster (id, name, mobile number — day
/// independent, edited from the Resources directory) plus per-day status
/// and notes overrides. A day's roster is *computed*, not cached: for each
/// person, an explicit override wins, otherwise today gets a hand-curated
/// default (so the dashboard looks realistic on first run) and any other
/// day gets a value derived deterministically from the date + person, so
/// repeat visits to the same day stay stable within a session.
class MockResourceDataSource implements ResourceDataSource {
  MockResourceDataSource() : _roster = [for (final p in _seed) _Person(id: p.$1, name: p.$2, mobileNumber: p.$3)];

  final List<_Person> _roster;
  int _autoId = _seed.length;

  final Map<String, Map<String, ResourceStatus>> _statusOverrides = {};
  final Map<String, Map<String, String>> _notesOverrides = {};

  static const List<(String id, String name, String mobileNumber)> _seed = [
    ('res-1', 'Girish', '9000012345'),
    ('res-2', 'Rohal Thakur', '9000012346'),
    ('res-3', 'Amir Khan', '9000012347'),
    ('res-4', 'Pratik Singh', '9000012348'),
    ('res-5', 'Sandeep Chau', '9000012349'),
    ('res-6', 'Aditi Verma', '9000012350'),
    ('res-7', 'Rahul', '9000012351'),
    ('res-8', 'Altamash', '9000012352'),
    ('res-9', 'Kiran Kapse', '9000012353'),
    ('res-10', 'Manpreet', '9000012354'),
    ('res-11', 'Mohit Panchal', '9000012355'),
    ('res-12', 'Shivraj Walke', '9000012356'),
    ('res-13', 'Prachi Shukla', '9000012357'),
    ('res-14', 'Sumit Sharna', '9000012358'),
    ('res-15', 'Dayalu', '9000012359'),
    ('res-16', 'Ankit Mehta', '9000012360'),
  ];

  static const Map<String, ResourceStatus> _curatedStatus = {
    'res-1': ResourceStatus.updated,
    'res-2': ResourceStatus.updated,
    'res-3': ResourceStatus.notUpdated,
    'res-4': ResourceStatus.updated,
    'res-5': ResourceStatus.onLeave,
    'res-6': ResourceStatus.updated,
    'res-7': ResourceStatus.notUpdated,
    'res-8': ResourceStatus.updated,
    'res-9': ResourceStatus.onLeave,
    'res-10': ResourceStatus.updated,
    'res-11': ResourceStatus.notUpdated,
    'res-12': ResourceStatus.updated,
    'res-13': ResourceStatus.updated,
    'res-14': ResourceStatus.onLeave,
    'res-15': ResourceStatus.notUpdated,
    'res-16': ResourceStatus.updated,
  };

  static const Map<String, String> _curatedNotes = {
    'res-1': 'Completed daily inventory update and shared report.',
    'res-2': 'Client call done, sent summary on WhatsApp.',
    'res-4': 'Finished testing module 3, no blockers.',
    'res-5': 'On leave today, back tomorrow.',
    'res-6': 'Design review completed, feedback shared.',
    'res-8': 'Deployed hotfix to production.',
    'res-9': 'Sick leave, informed via WhatsApp.',
    'res-10': 'Completed onboarding for new joiner.',
    'res-12': 'Site visit completed, report attached.',
    'res-13': 'Training session conducted successfully.',
    'res-14': 'Half day leave - personal work.',
    'res-16': 'Weekly report submitted.',
  };

  @override
  Future<List<Resource>> fetch(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 220));
    return [for (final person in _roster) _buildResource(date, person)];
  }

  @override
  Future<Resource> setStatus(DateTime date, String resourceId, ResourceStatus status) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _statusOverrides.putIfAbsent(_keyFor(date), () => {})[resourceId] = status;
    return _buildResource(date, _findPerson(resourceId));
  }

  @override
  Future<Resource> setNotes(DateTime date, String resourceId, String notes) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _notesOverrides.putIfAbsent(_keyFor(date), () => {})[resourceId] = notes;
    return _buildResource(date, _findPerson(resourceId));
  }

  @override
  Future<Resource> addResource({required String name, required String mobileNumber}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _autoId += 1;
    final person = _Person(id: 'res-$_autoId', name: name, mobileNumber: mobileNumber);
    _roster.add(person);
    return Resource(id: person.id, name: person.name, mobileNumber: person.mobileNumber, status: ResourceStatus.notUpdated);
  }

  @override
  Future<void> updateResource(String resourceId, {required String name, required String mobileNumber}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final person = _findPerson(resourceId);
    person.name = name;
    person.mobileNumber = mobileNumber;
  }

  @override
  Future<void> deleteResource(String resourceId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _roster.removeWhere((p) => p.id == resourceId);
    for (final overrides in _statusOverrides.values) {
      overrides.remove(resourceId);
    }
    for (final overrides in _notesOverrides.values) {
      overrides.remove(resourceId);
    }
  }

  _Person _findPerson(String resourceId) {
    return _roster.firstWhere(
      (p) => p.id == resourceId,
      orElse: () => throw StateError('Resource "$resourceId" not found'),
    );
  }

  Resource _buildResource(DateTime date, _Person person) {
    final key = _keyFor(date);
    final status = _statusOverrides[key]?[person.id] ?? _defaultStatus(date, person.id);
    final notes = _notesOverrides[key]?[person.id] ?? _defaultNotes(date, person.id);
    return Resource(id: person.id, name: person.name, mobileNumber: person.mobileNumber, status: status, notes: notes);
  }

  ResourceStatus _defaultStatus(DateTime date, String id) {
    if (_isToday(date)) return _curatedStatus[id] ?? ResourceStatus.notUpdated;
    final random = math.Random(_dateSeed(date) ^ id.hashCode);
    return _weightedStatus(random);
  }

  String _defaultNotes(DateTime date, String id) {
    if (_isToday(date)) return _curatedNotes[id] ?? '';
    return '';
  }

  ResourceStatus _weightedStatus(math.Random random) {
    final roll = random.nextDouble();
    if (roll < 0.6) return ResourceStatus.updated;
    if (roll < 0.82) return ResourceStatus.onLeave;
    return ResourceStatus.notUpdated;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  int _dateSeed(DateTime date) => date.year * 10000 + date.month * 100 + date.day;

  String _keyFor(DateTime date) => '${date.year}-${date.month}-${date.day}';
}
