import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/schedule_event.dart';

class ScheduleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch events for students/CR based on groupId
  Future<List<ScheduleEvent>> getEvents(String groupId) async {
    final snapshot = await _db
        .collection('schedules')
        .where('groupId', isEqualTo: groupId)
        .get();
    return snapshot.docs.map((doc) => ScheduleEvent.fromMap(doc.data())).toList();
  }

  // Fetch events for a specific teacher
  Future<List<ScheduleEvent>> getEventsForTeacher(String teacherId) async {
    final snapshot = await _db
        .collection('schedules')
        .where('teacherId', isEqualTo: teacherId)
        .get();
    return snapshot.docs.map((doc) => ScheduleEvent.fromMap(doc.data())).toList();
  }

  // Add a new routine
  Future<void> addEvent(ScheduleEvent event) async {
    await _db.collection('schedules').doc(event.id).set(event.toMap());
  }

  // Delete a routine using only eventId
  Future<void> deleteEvent(String eventId) async {
    await _db.collection('schedules').doc(eventId).delete();
  }
}