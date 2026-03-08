import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_event.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addEvent(ScheduleEvent event) async {
    await _firestore
        .collection('groups')
        .doc(event.groupId)
        .collection('events')
        .doc(event.id)
        .set(event.toMap());
  }

  Future<List<ScheduleEvent>> getEvents(String groupId) async {
    final snapshot = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('events')
        .get();
    return snapshot.docs
        .map((doc) => ScheduleEvent.fromMap(doc.data()))
        .toList();
  }

  Future<void> updateEvent(ScheduleEvent event) async {
    await _firestore
        .collection('groups')
        .doc(event.groupId)
        .collection('events')
        .doc(event.id)
        .set(event.toMap());
  }

  Future<void> deleteEvent(String groupId, String eventId) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('events')
        .doc(eventId)
        .delete();
  }
  Future<List<ScheduleEvent>> getEventsForTeacher(String teacherId) async {
    final snapshot = await _firestore
        .collection('groups')
        .where('teacherId', isEqualTo: teacherId)
        .get();
    return snapshot.docs
        .map((doc) => ScheduleEvent.fromMap(doc.data()))
        .toList();
  }
}
