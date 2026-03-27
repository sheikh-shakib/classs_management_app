import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//schedule event class
class ScheduleEvent {
  final String id;
  final String groupId;
  final String teacherId;
  final String subject;
  final String room;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int dayOfWeek; //1 is monday and 7 is sunday
  final bool isRecurring;
  final DateTime? specificDate; // used for one time classes
  final DateTime recurrenceStartDate;
  final List<DateTime> exceptions; // cancelled classes
  //constructor
  ScheduleEvent({
    required this.id,
    required this.groupId,
    required this.teacherId,
    required this.subject,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    this.isRecurring = true,
    this.specificDate,
    required this.recurrenceStartDate,
    this.exceptions = const []
  });
  //convert to map for firebase store
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'teacherId': teacherId,
      'subject': subject,
      'room': room,
      'startTimeHour': startTime.hour,
      'startTimeMinute': startTime.minute,
      'endTimeHour': endTime.hour,
      'endTimeMinute': endTime.minute,
      'dayOfWeek': dayOfWeek,
      'isRecurring': isRecurring,
      'specificDate': specificDate,
      'recurrenceStartDate': recurrenceStartDate,
      'exceptions': exceptions.map((e) => Timestamp.fromDate(e)).toList(),
    };
  }
 //factory constructor to load from firebase map
  factory ScheduleEvent.fromMap(Map<String, dynamic> map) {
    return ScheduleEvent(
      id: map['id'],
      groupId: map['groupId'],
      teacherId: map['teacherId'],
      subject: map['subject'],
      room: map['room'],

      //firebase stores time as separate hour and minute fields, we need to convert it back to TimeOfDay
      startTime: TimeOfDay(
        hour: map['startTimeHour'],
        minute: map['startTimeMinute'],
      ),
      endTime: TimeOfDay(
        hour: map['endTimeHour'],
        minute: map['endTimeMinute'],
      ),
      dayOfWeek: map['dayOfWeek'],

      //checks if it's onday event or recurring,if oneday it should have soecific date
      isRecurring: map['isRecurring'] as bool? ?? true,
      //firebase stores date as timestamp, we need to convert it back to datetime
      specificDate: map['specificDate'] != null
          ? (map['specificDate'] as Timestamp).toDate()
          : null,
      recurrenceStartDate: map['recurrenceStartDate'] != null
          ? (map['recurrenceStartDate'] as Timestamp).toDate()
          : DateTime.now(),
      //list of exceptions, if any, also converted from timestamp to datetime
      exceptions:
          (map['exceptions'] as List<dynamic>?)
              ?.map((e) => (e as Timestamp).toDate())
              .toList() ?? [],
    );    
  }
  //checks if event occurs on a given date
  bool occursOn(DateTime date) {
    //date of the day
    final checkDate = DateTime(date.year, date.month, date.day);
    //first it checks if it's a one day event, if it is then it compares the specific date with the check date
    if (!isRecurring) {
      if (specificDate == null) return false;
      final d = DateTime(
        specificDate!.year,
        specificDate!.month,
        specificDate!.day,
      );
      return d == checkDate;
    }
    // if not one day event then it checks if the weekday of the check date matches the event's day of week
    if (checkDate.weekday != dayOfWeek) return false;
    final start = DateTime(
      recurrenceStartDate.year,
      recurrenceStartDate.month,
      recurrenceStartDate.day,
    );
    //checks if the day is before the start of the recurring event
    if (checkDate.isBefore(start)) return false;
    //finally runs through the list of dates when classes are cancelled 
    for (var ex in exceptions) {
      final exDate = DateTime(ex.year, ex.month, ex.day);
      if (exDate == checkDate) return false;
    }
    return true;
  }
}
