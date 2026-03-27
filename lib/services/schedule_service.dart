import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/schedule_event.dart';

class ScheduleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //events for students/CR
  Future<List<ScheduleEvent>> getEvents(String groupId) async {
    final snapshot = await _db
        .collection('schedules')
        .where('groupId', isEqualTo: groupId)
        .get();
    return snapshot.docs
        .map((doc) => ScheduleEvent.fromMap(doc.data()))
        .toList();
  }

  //events for teacher
  Future<List<ScheduleEvent>> getEventsForTeacher(String teacherId) async {
    final snapshot = await _db
        .collection('schedules')
        .where('teacherId', isEqualTo: teacherId)
        .get();
    return snapshot.docs
        .map((doc) => ScheduleEvent.fromMap(doc.data()))
        .toList();
  }

  // add a new routine
  Future<void> addEvent(ScheduleEvent event) async {
    await _db.collection('schedules').doc(event.id).set(event.toMap());
  }

  // delete a routine
  Future<void> deleteEvent(String eventId) async {
    await _db.collection('schedules').doc(eventId).delete();
  }

  //check for time overlap
  bool isTimeOverlap(
    TimeOfDay aStart,
    TimeOfDay aEnd,
    TimeOfDay bStart,
    TimeOfDay bEnd,
  ) {
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
      if (existing.id == newEvent.id) continue;
      bool sameDay = false;
      if (!newEvent.isRecurring && !existing.isRecurring) {
        sameDay = newEvent.specificDate == existing.specificDate;
      } else {
        sameDay = newEvent.dayOfWeek == existing.dayOfWeek;
      }
      if (!sameDay) continue;
      if (!isTimeOverlap(
        newEvent.startTime,
        newEvent.endTime,
        existing.startTime,
        existing.endTime,
      )) {
        continue;
      }
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
    final event = ScheduleEvent.fromMap({...data, 'id': doc.id});

    final newExceptions = [
      ...event.exceptions,
      DateTime(date.year, date.month, date.day),
    ];

    await doc.update({
      'exceptions': newExceptions.map((e) => Timestamp.fromDate(e)).toList(),
    });
  }

  Future<List<String>> getTeacherIds() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'teacher')
          .get();

      List<String> teacherIds = querySnapshot.docs.map((doc) {
        return doc['id'] as String;
      }).toList();

      return teacherIds;
    } catch (e) {
      print("Error fetching teachers: $e");
      return [];
    }
  }

  Future<List<String>> getAllRoomNames() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Rooms')
          .get();

      List<String> roomNames = querySnapshot.docs.map((doc) {
        return doc['Name'] as String;
      }).toList();

      return roomNames;
    } catch (e) {
      print("Error fetching rooms: $e");
      return [];
    }
  }
  Future<List<String>> getAllgroups() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .get();

      List<String> groupNames = querySnapshot.docs.map((doc) {
        return doc['id'] as String;
      }).toList();

      return groupNames;
    } catch (e) {
      print("Error fetching groups: $e");
      return [];
    }
  }
}
