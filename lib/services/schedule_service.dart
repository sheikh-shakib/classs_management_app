import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/notification_services.dart';


import '../models/schedule_event.dart';

class ScheduleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //events for students/CR
  Future<List<ScheduleEvent>> getEvents(String groupId) async {
    //uses groupId to fetch all schedule events for that group from firestore
    //snapshot is used instead of doc because we are fetching multiple documents that match the groupId
    final snapshot = await _db
        .collection('schedules')
        .where('groupId', isEqualTo: groupId)
        .get();
    //passes the snapshot docs to map function to convert to event class and then to list
    return snapshot.docs
        .map((doc) => ScheduleEvent.fromMap(doc.data()))
        .toList();
  }

  //events for teacher
  Future<List<ScheduleEvent>> getEventsForTeacher(String teacherId) async {
    //uses teacherId which is the id field of user document to fetch all schedule events for that teacher from firestore that has teacherId field matching the provided teacherId
    final snapshot = await _db
        .collection('schedules')
        .where('teacherId', isEqualTo: teacherId)
        .get();

    ///passes the snapshot docs to map function to convert to event class and then to list
    return snapshot.docs
        .map((doc) => ScheduleEvent.fromMap(doc.data()))
        .toList();
  }
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  // add a new routine by adding a new document to firestore with the event data , event id is auto generated
  Future<void> addEvent(ScheduleEvent event) async {
    await _db.collection('schedules').doc(event.id).set(event.toMap());

    await NotificationService().notifyClassChange(
      title: "Class Added/Updated",
      message:
          "${event.subject} scheduled for ${event.dayOfWeek} at ${_formatTime(event.startTime)}",
      groupId: event.groupId,
      teacherId: event.teacherId,
    );
  }

  // delete a routine from firestore by its document id which is the event id
  Future<void> deleteEvent(String eventId) async {
    final doc = await _db.collection('schedules').doc(eventId).get();
    if (!doc.exists) return;
    
    final event = ScheduleEvent.fromMap({...doc.data()!, 'id': eventId});
    
    await _db.collection('schedules').doc(eventId).delete();

    await NotificationService().notifyClassChange(
      title: "Class Cancelled",
      message: "${event.subject} on ${event.dayOfWeek} has been removed.",
      groupId: event.groupId,
      teacherId: event.teacherId,
    );
  }

  //check for time overlap
  bool isTimeOverlap(
    TimeOfDay aStart,
    TimeOfDay aEnd,
    TimeOfDay bStart,
    TimeOfDay bEnd,
  ) {
    //convert time to minutes for easier comparison
    final aStartMin = aStart.hour * 60 + aStart.minute;
    final aEndMin = aEnd.hour * 60 + aEnd.minute;
    final bStartMin = bStart.hour * 60 + bStart.minute;
    final bEndMin = bEnd.hour * 60 + bEnd.minute;
    //comparison logic for time overlap, two time intervals [aStart, aEnd] and [bStart, bEnd] overlap if aStart is before bEnd and aEnd is after bStart

    return aStartMin < bEndMin && aEndMin > bStartMin;
  }

  //check for conflicts , if the events time overlaps and they are on the same day, then it checks if they have the same room, teacher or group and adds the conflict message to the list of conflicts which is returned at the end
  Future<List<String>> checkConflicts(ScheduleEvent newEvent) async {
    final snapshot = await _db.collection('schedules').get();
    //list to store conflict messages
    List<String> conflicts = [];
    //for each existing event in the schedule, it checks if it is on the same day as the new event and if their time overlaps
    for (var doc in snapshot.docs) {
      final existing = ScheduleEvent.fromMap(doc.data());
      //to prevent comparing the new event with itself when editing an existing event
      if (existing.id == newEvent.id) continue;
      bool sameDay = false;
      if (!newEvent.isRecurring && !existing.isRecurring) {
        sameDay = newEvent.specificDate == existing.specificDate;
      } else {
        sameDay = newEvent.dayOfWeek == existing.dayOfWeek;
      }
      if (!sameDay) continue;
      //calls time overlap fucntion
      if (!isTimeOverlap(
        newEvent.startTime,
        newEvent.endTime,
        existing.startTime,
        existing.endTime,
      )) {
        continue;
      }
      //room overlap check
      if (newEvent.room == existing.room) {
        conflicts.add('Room conflict with ${existing.subject}');
      }
      //teacher overlap check

      if (newEvent.teacherId == existing.teacherId) {
        conflicts.add('Teacher conflict with ${existing.subject}');
      }
      //group overlap check

      if (newEvent.groupId == existing.groupId) {
        conflicts.add('Group conflict with ${existing.subject}');
      }
    }

    return conflicts;
  }

  //one tiem cancel by adding an exception date and then updating the evetn doc
  Future<void> cancelEventOnce(String eventId, DateTime date) async {
    final doc = _db.collection('schedules').doc(eventId);

    final snapshot = await doc.get();

    if (!snapshot.exists) return;
    final event = ScheduleEvent.fromMap({...snapshot.data()!, 'id': eventId});
    final newExceptions = [...event.exceptions, DateTime(date.year, date.month, date.day)];

    await doc.update({
      'exceptions': newExceptions.map((e) => Timestamp.fromDate(e)).toList(),
    });

    await NotificationService().notifyClassChange(
      title: "One-time Cancellation",
      message: "${event.subject} cancelled for ${date.day}/${date.month}.",
      groupId: event.groupId,
      teacherId: event.teacherId,
    );
  }
  //gets list of all teacher

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
      return [];
    }
  }

  //gets list of all room names
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
      return [];
    }
  }

  //gets list of all group names
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
      return [];
    }
  }
}
