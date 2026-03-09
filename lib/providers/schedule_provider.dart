import 'package:flutter/material.dart';
import '../models/schedule_event.dart';
import '../services/schedule_service.dart';
import '../models/user_model.dart';

class ScheduleProvider with ChangeNotifier {
  final ScheduleService _scheduleService = ScheduleService();
  List<ScheduleEvent> _events = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  List<ScheduleEvent> get events => _events;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;

  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> loadSchedule(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (user.role == UserRole.teacher) {
        _events = await _scheduleService.getEventsForTeacher(user.id);
      } else if (user.groupId != null && user.groupId!.isNotEmpty) {
        String groupId = user.groupId!;
        _events = await _scheduleService.getEvents(groupId);
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
  Future<void> updateEvent(ScheduleEvent event) async {
    await _scheduleService.updateEvent(event);
    int index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
     
    }
    notifyListeners();
  }
  Future<void> deleteEvent(String groupId, String eventId) async {
    await _scheduleService.deleteEvent(groupId, eventId);
    _events.removeWhere((e) => e.id == eventId);
    notifyListeners();
  }
  List<ScheduleEvent> getEventsForDay(DateTime date) {
    return _events.where((event) => event.occursOn(date)).toList()
    ..sort((a, b) {

      final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
      final bMinutes = b.startTime.hour * 60 + b.startTime.minute;

      return aMinutes.compareTo(bMinutes);

    });
  }
}
