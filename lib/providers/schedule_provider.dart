import 'package:flutter/material.dart';

import '../models/schedule_event.dart';
import '../models/user_model.dart';
import '../services/schedule_service.dart';

class ScheduleProvider with ChangeNotifier {
  final ScheduleService _scheduleService = ScheduleService();
  List<ScheduleEvent> _events = [];
  bool _isLoading = false;

  List<ScheduleEvent> get events => _events;
  bool get isLoading => _isLoading;

  // load schedule
  Future<void> loadSchedule(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (user.role == UserRole.teacher) {
        _events = await _scheduleService.getEventsForTeacher(user.id);
      } else if (user.groupId != null && user.groupId!.isNotEmpty) {
        _events = await _scheduleService.getEvents(user.groupId!);
      } else {
        _events = [];
      }
    } catch (e) {
      debugPrint('Error loading schedule: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEvent(ScheduleEvent event) async {
    await _scheduleService.addEvent(event);
    _events.add(event);
    notifyListeners();
  }

  // corrected to 1 argument
  Future<void> deleteEvent(String eventId) async {
    await _scheduleService.deleteEvent(eventId);
    _events.removeWhere((e) => e.id == eventId);
    notifyListeners();
  }

  // get and sort classes by time for today
  List<ScheduleEvent> getEventsForDay(DateTime date) {
    return _events.where((event) => event.occursOn(date)).toList()
      ..sort((a, b) {
        final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
        final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aMinutes.compareTo(bMinutes);
      });
  }
}