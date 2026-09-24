import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/holiday.dart';
import 'holiday_data_source.dart';

/// Firestore-backed [HolidayDataSource].
///
/// Schema: `holidays/{holidayId}` — `{ date, name }`.
class FirebaseHolidayDataSource implements HolidayDataSource {
  FirebaseHolidayDataSource({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _holidays => _db.collection('holidays');

  @override
  Future<List<Holiday>> fetchHolidays() async {
    final snapshot = await _holidays.orderBy('date').get();
    return [
      for (final doc in snapshot.docs)
        Holiday(
          id: doc.id,
          date: (doc.data()['date'] as Timestamp).toDate(),
          name: doc.data()['name'] as String? ?? '',
        ),
    ];
  }

  @override
  Future<Holiday> addHoliday({required DateTime date, required String name}) async {
    final day = DateTime(date.year, date.month, date.day);
    final doc = await _holidays.add({'date': Timestamp.fromDate(day), 'name': name});
    return Holiday(id: doc.id, date: day, name: name);
  }

  @override
  Future<void> deleteHoliday(String holidayId) {
    return _holidays.doc(holidayId).delete();
  }
}
