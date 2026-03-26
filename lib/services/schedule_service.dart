import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  //check for time overlap 
  bool isTimeOverlap(TimeOfDay aStart, TimeOfDay aEnd,
                   TimeOfDay bStart, TimeOfDay bEnd) {
  final aStartMin = aStart.hour * 60 + aStart.minute;
  final aEndMin = aEnd.hour * 60 + aEnd.minute;
  final bStartMin = bStart.hour * 60 + bStart.minute;
  final bEndMin = bEnd.hour * 60 + bEnd.minute;

  return aStartMin < bEndMin && aEndMin > bStartMin;
}
//check for conflicts

Future<List<String>> checkConflicts(ScheduleEvent newEvent) async {
  final snapshot = await _db.collection('schedules').get();

  List<String> conflicts = [];

  for (var doc in snapshot.docs) {
    final existing = ScheduleEvent.fromMap(doc.data());

    // skip self (important for edit)
    if (existing.id == newEvent.id) continue;

    // check if both occur on same date
    bool sameDay = false;

    if (!newEvent.isRecurring && !existing.isRecurring) {
      sameDay = newEvent.specificDate == existing.specificDate;
    } else {
      // for recurring, compare weekday
      sameDay = newEvent.dayOfWeek == existing.dayOfWeek;
    }

    if (!sameDay) continue;

    // check time overlap
    if (!isTimeOverlap(
        newEvent.startTime,
        newEvent.endTime,
        existing.startTime,
        existing.endTime)) continue;

    // Conflict checks
    if (newEvent.room == existing.room) {
      conflicts.add('Room conflict with ${existing.subject}');
    }

    if (newEvent.teacherId == existing.teacherId) {
      conflicts.add('Teacher conflict with ${existing.subject}');
    }

    if (newEvent.groupId == existing.groupId) {
      conflicts.add('Group conflict with ${existing.subject}');
    }
  }

  return conflicts;
}
Future<void> cancelEventOnce(String eventId, DateTime date) async {
  final doc = _db.collection('schedules').doc(eventId);

  final snapshot = await doc.get();

  if (!snapshot.exists) return;

  final data = snapshot.data()!;
  final event = ScheduleEvent.fromMap({
    ...data,
    'id': doc.id,
  });

  final newExceptions = [
    ...event.exceptions,
    DateTime(date.year, date.month, date.day),
  ];

  await doc.update({
    'exceptions': newExceptions
        .map((e) => Timestamp.fromDate(e))
        .toList(),
  });
}


}