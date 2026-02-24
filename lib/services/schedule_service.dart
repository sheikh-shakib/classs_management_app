import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_event.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createEvent(ScheduleEvent event) async {
    await _firestore.collection('groups').doc(event.groupId).collection('events').add(event.toMap());
  }

  Future<List<ScheduleEvent>> getEvents(String groupId) async {
    final snapshot = await _firestore.collection('groups').doc(groupId).collection('events').get();
    return snapshot.docs
        .map((doc) => ScheduleEvent.fromMap(doc.data()))
        .toList();
  }

  Future<void> updateEvent(ScheduleEvent event) async {
    await _firestore
        .collection('schedule_events')
        .doc(event.id)
        .update(event.toMap());
  }

  Future<void> deleteEvent(String id) async {
    await _firestore.collection('schedule_events').doc(id).delete();
  }
}
