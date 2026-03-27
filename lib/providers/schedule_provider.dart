import 'package:flutter/material.dart';

import '../models/schedule_event.dart';
import '../models/user_model.dart';
import '../services/schedule_service.dart';

class ScheduleProvider with ChangeNotifier {
  //creates an instance of schedule service
  final ScheduleService _scheduleService = ScheduleService();
  // list of schedule events
  List<ScheduleEvent> _events = [];
  //loading state to show a loading indicator in the UI while the schedule is being loaded
  bool _isLoading = false;
  //get fucntion for private variables
  List<ScheduleEvent> get events => _events;
  bool get isLoading => _isLoading;

  // load schedule
  Future<void> loadSchedule(UserModel user) async {
    //ui change while it loads the schedule
    _isLoading = true;
    notifyListeners();
    try {
      //gets event based on the user role
      //for teacher
      if (user.role == UserRole.teacher) {
        _events = await _scheduleService.getEventsForTeacher(user.id);
      }
      //for students and CR
      else if (user.groupId != null && user.groupId!.isNotEmpty) {
        _events = await _scheduleService.getEvents(user.groupId!);
      }
      //edge case
      else {
        _events = [];
      }
    } catch (e) {
      //the error debug was used incase the loading doesn't work vvimpo
      debugPrint('Error loading schedule: $e');
    }
    //regardless of success or failure, loading is set to false and UI is notified to rebuild accordingly
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //adding event by adding by calling the addEvent function in schedule service
  Future<void> addEvent(ScheduleEvent event) async {
    await _scheduleService.addEvent(event);
    //updates local save
    _events.add(event);
    notifyListeners();
  }

  //deleting event by calling the deleteEvent function in schedule service
  Future<void> deleteEvent(String eventId) async {
    await _scheduleService.deleteEvent(eventId);
    //updates local save
    _events.removeWhere((e) => e.id == eventId);
    notifyListeners();
  }

  Future<void> cancelOnce(String eventId, DateTime date) async {
    await _scheduleService.cancelEventOnce(eventId, date);
    //updates local save
    for (int i = 0; i < _events.length; i++) {
    if (_events[i].id == eventId) {
      _events[i].exceptions.add(
        DateTime(date.year, date.month, date.day),
      );
      break;
    }
  }
    notifyListeners();
  }
}
