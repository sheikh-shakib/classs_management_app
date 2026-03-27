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

  //adding event
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
}