import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final DateTime? recurrenceEndDate;
  final List<DateTime> exceptions; // cancelled classes
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
    this.recurrenceEndDate,
    this.exceptions = const []
  });

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
      'recurrenceEndDate': recurrenceEndDate,
      'exceptions': exceptions.map((e) => Timestamp.fromDate(e)).toList(),
    };
  }

  factory ScheduleEvent.fromMap(Map<String, dynamic> map) {
    return ScheduleEvent(
      id: map['id'],
      groupId: map['groupId'],
      teacherId: map['teacherId'],
      subject: map['subject'],
      room: map['room'],
      startTime: TimeOfDay(
        hour: map['startTimeHour'],
        minute: map['startTimeMinute'],
      ),
      endTime: TimeOfDay(
        hour: map['endTimeHour'],
        minute: map['endTimeMinute'],
      ),
      dayOfWeek: map['dayOfWeek'],
      isRecurring: map['isRecurring'] as bool? ?? true,
      specificDate: map['specificDate'] != null
          ? (map['specificDate'] as Timestamp).toDate()
          : null,
      recurrenceStartDate: map['recurrenceStartDate'] != null
          ? (map['recurrenceStartDate'] as Timestamp).toDate()
          : DateTime.now(),
      recurrenceEndDate: map['recurrenceEndDate'] != null
          ? (map['recurrenceEndDate'] as Timestamp).toDate()
          : null,
      exceptions:
          (map['exceptions'] as List<dynamic>?)
              ?.map((e) => (e as Timestamp).toDate())
              .toList() ?? [],
    );    
  }
  bool occursOn(DateTime date) {
    final checkDate = DateTime(date.year, date.month, date.day);
    if (!isRecurring) {
      if (specificDate == null) return false;
      final d = DateTime(
        specificDate!.year,
        specificDate!.month,
        specificDate!.day,
      );
      return d == checkDate;
    }
    if (checkDate.weekday != dayOfWeek) return false;
    final start = DateTime(
      recurrenceStartDate.year,
      recurrenceStartDate.month,
      recurrenceStartDate.day,
    );
    if (checkDate.isBefore(start)) return false;
    if (recurrenceEndDate != null) {
      final end = DateTime(
        recurrenceEndDate!.year,
        recurrenceEndDate!.month,
        recurrenceEndDate!.day,
      );
      if (checkDate.isAfter(end)) return false;
    }
    for (var ex in exceptions) {
      final exDate = DateTime(ex.year, ex.month, ex.day);
      if (exDate == checkDate) return false;
    }
    return true;
  }
}
