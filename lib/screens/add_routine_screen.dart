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

  const AddRoutineScreen({
    super.key,
    required this.user,
    required this.onSave,
    required this.allEvents,
    required this.teacherList,
    required this.roomList,
    this.existingEvent,
  });

  @override
  State<AddRoutineScreen> createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  final subject = TextEditingController();
  final room = TextEditingController();
  final teacher = TextEditingController();
  final group = TextEditingController();

  TimeOfDay start = TimeOfDay.now();
  TimeOfDay end = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0);
  String? selectedTeacher;
  String? selectedRoom;

  bool isRecurring = true;
  DateTime? selectedDate;
  int selectedDay = DateTime.now().weekday;

  final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Future<void> pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? start : end,
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          start = picked;
        else
          end = picked;
      });
    }
  }

  Future<void> save() async {
    final newEvent = ScheduleEvent(
      id: widget.existingEvent?.id ?? const Uuid().v4(),
      groupId: group.text,
      teacherId: teacher.text,
      subject: subject.text,
      room: room.text,
      startTime: start,
      endTime: end,
      dayOfWeek: selectedDay,
      isRecurring: isRecurring,
      specificDate: isRecurring ? null : selectedDate,
      recurrenceStartDate: DateTime.now(),
    );

    Navigator.pop(context);
    await widget.onSave(newEvent);
  }

  @override
  Widget build(BuildContext context) {
    final isCR = widget.user.role == UserRole.cr;

    return Dialog(
      backgroundColor: const Color(0xFF1C1F2E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Add Class", style: TextStyle(color: Colors.white)),

            TextField(
              controller: subject,
              style: TextStyle(color: Colors.blue),
              decoration: const InputDecoration(labelText: "Subject"),
            ),

            if (!isCR)
              TextField(
                controller: group,
                style: TextStyle(color: Colors.blue),
                decoration: const InputDecoration(labelText: "Group"),
              ),

            DropdownButtonFormField<String>(
              value: selectedTeacher,
              decoration: const InputDecoration(labelText: "Teacher"),
              items: widget.teacherList.map((teacher) {
                return DropdownMenuItem(
                  value: teacher,
                  child: Text(teacher, style: TextStyle(color: Colors.blue)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTeacher = value!;
                });
              },
            ),

            SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedRoom,
              decoration: const InputDecoration(labelText: "Room"),
              items: widget.roomList.map((room) {
                return DropdownMenuItem(
                  value: room,
                  child: Text(room, style: TextStyle(color: Colors.blue)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRoom = value!;
                });
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ChoiceChip(
                  label: const Text("Recurring"),
                  selected: isRecurring,
                  onSelected: (_) => setState(() => isRecurring = true),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("One-time"),
                  selected: !isRecurring,
                  onSelected: (_) => setState(() => isRecurring = false),
                ),
                if (isRecurring)
                  DropdownButton<int>(
                    focusColor: Colors.white,
                    iconEnabledColor: Colors.grey,
                    value: selectedDay,
                    items: List.generate(7, (i) {
                      return DropdownMenuItem(
                        value: i + 1,
                        child: Text(
                          dayNames[i],
                          style: const TextStyle(
                            color: Color.fromARGB(255, 24, 113, 187),
                          ),
                        ),
                      );
                    }),
                    onChanged: (v) => setState(() => selectedDay = v!),
                  ),
                if (!isRecurring)
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
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
                            : "${selectedDate!.day}/${selectedDate!.month}",
                      ),
                    ),
                  ),
              ],
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

            const SizedBox(height: 10),

            ElevatedButton(onPressed: save, child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}
