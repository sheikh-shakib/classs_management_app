import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/schedule_event.dart';
import '../models/user_model.dart';

class AddRoutineScreen extends StatefulWidget {
  final UserModel user;
  final ScheduleEvent? existingEvent;
  final List<ScheduleEvent> allEvents;
  final Future<void> Function(ScheduleEvent) onSave;
  final List<String> teacherList;
  final List<String> roomList;
  final List<String> groupList;

  const AddRoutineScreen({
    super.key,
    required this.user,
    required this.onSave,
    required this.allEvents,
    required this.teacherList,
    required this.roomList,
    this.existingEvent,
    required this.groupList,
  });

  @override
  State<AddRoutineScreen> createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  // Controllers
  final subjectController = TextEditingController();
  
  // State Variables
  TimeOfDay start = TimeOfDay.now();
  TimeOfDay end = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0);
  
  String? selectedTeacher;
  String? selectedRoom;
  String? selectedGroup;

  bool isRecurring = true;
  DateTime? selectedDate;
  int selectedDay = DateTime.now().weekday;

  final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    // Pre-fill data if editing an existing event
    if (widget.existingEvent != null) {
      final event = widget.existingEvent!;
      
      subjectController.text = event.subject;
      selectedTeacher = event.teacherId;
      selectedRoom = event.room;
      selectedGroup = event.groupId;
      
      start = event.startTime;
      end = event.endTime;
      isRecurring = event.isRecurring;
      selectedDay = event.dayOfWeek;
      selectedDate = event.specificDate;
    }
  }

  @override
  void dispose() {
    subjectController.dispose();
    super.dispose();
  }

  Future<void> pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? start : end,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          start = picked;
        } else {
          end = picked;
        }
      });
    }
  }

  Future<void> save() async {
    // Validation: Ensure required fields are selected
    if (subjectController.text.isEmpty || selectedTeacher == null || selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final newEvent = ScheduleEvent(
      id: widget.existingEvent?.id ?? const Uuid().v4(),
      groupId: selectedGroup ?? (widget.user.role == UserRole.cr ? "YourDefaultGroup" : ""), 
      teacherId: selectedTeacher!,
      subject: subjectController.text,
      room: selectedRoom!,
      startTime: start,
      endTime: end,
      dayOfWeek: selectedDay,
      isRecurring: isRecurring,
      specificDate: isRecurring ? null : selectedDate,
      recurrenceStartDate: widget.existingEvent?.recurrenceStartDate ?? DateTime.now(),
    );

    Navigator.pop(context);
    await widget.onSave(newEvent);
  }

  @override
  Widget build(BuildContext context) {
    final isCR = widget.user.role == UserRole.cr;

    return Dialog(
      backgroundColor: const Color(0xFF1C1F2E),
      child: SingleChildScrollView( // Added scroll view to prevent overflow on keyboard popup
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.existingEvent == null ? "Add Class" : "Edit Class",
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),

              TextField(
                controller: subjectController,
                style: const TextStyle(color: Colors.blue),
                decoration: const InputDecoration(
                  labelText: "Subject",
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),

              if (!isCR)
                DropdownButtonFormField<String>(
                  value: selectedGroup, // Corrected from initialValue to value
                  dropdownColor: const Color(0xFF1C1F2E),
                  decoration: const InputDecoration(labelText: "Group", labelStyle: TextStyle(color: Colors.grey)),
                  items: widget.groupList.map((group) {
                    return DropdownMenuItem(
                      value: group,
                      child: Text(group, style: const TextStyle(color: Colors.blue)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedGroup = value),
                ),

              DropdownButtonFormField<String>(
                value: selectedTeacher,
                dropdownColor: const Color(0xFF1C1F2E),
                decoration: const InputDecoration(labelText: "Teacher", labelStyle: TextStyle(color: Colors.grey)),
                items: widget.teacherList.map((teacher) {
                  return DropdownMenuItem(
                    value: teacher,
                    child: Text(teacher, style: const TextStyle(color: Colors.blue)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedTeacher = value),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedRoom,
                dropdownColor: const Color(0xFF1C1F2E),
                decoration: const InputDecoration(labelText: "Room", labelStyle: TextStyle(color: Colors.grey)),
                items: widget.roomList.map((room) {
                  return DropdownMenuItem(
                    value: room,
                    child: Text(room, style: const TextStyle(color: Colors.blue)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedRoom = value),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ChoiceChip(
                    label: const Text("Recurring"),
                    selected: isRecurring,
                    onSelected: (_) => setState(() => isRecurring = true),
                  ),
                  ChoiceChip(
                    label: const Text("One-time"),
                    selected: !isRecurring,
                    onSelected: (_) => setState(() => isRecurring = false),
                  ),
                ],
              ),
              
              const SizedBox(height: 10),

              if (isRecurring)
                DropdownButton<int>(
                  dropdownColor: Colors.indigo,
                  value: selectedDay,
                  items: List.generate(7, (i) {
                    return DropdownMenuItem(
                      value: i + 1,
                      child: Text(
                        dayNames[i],
                        style: const TextStyle(color: Colors.blue),
                      ),
                    );
                  }),
                  onChanged: (v) => setState(() => selectedDay = v!),
                )
              else
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: Text(
                    selectedDate == null
                        ? "Pick date"
                        : "Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                  ),
                ),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => pickTime(true),
                      child: Text("Start: ${start.format(context)}"),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => pickTime(false),
                      child: Text("End: ${end.format(context)}"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: save,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("Save Routine", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}