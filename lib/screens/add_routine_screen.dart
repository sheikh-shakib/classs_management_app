import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/schedule_event.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/schedule_provider.dart';

class AddRoutineScreen extends StatefulWidget {
  const AddRoutineScreen({super.key});

  @override
  State<AddRoutineScreen> createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _roomController = TextEditingController();
  
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  
  // Day selection (1 = Monday, 7 = Sunday - Based on ISO 8601)
  int _selectedDay = DateTime.now().weekday; 

  final List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    // Get the current user to auto-assign the Group ID
    final user = context.watch<AuthProvider>().user;
    
    // Safety check: ensure we have a user
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Error: User not found.")));
    }

    // Determine the target group based on role
    // If CR, they MUST add to their own group. 
    // If Teacher, they might need a dropdown, but for now, we use their assigned groupId or a default.
    String targetGroupId = user.groupId ?? "Unknown Group";
    
    // We only show the dropdown if the user is a teacher and needs to assign to different groups.
    // For a CR, this variable is fixed.
    bool isTeacher = user.role == UserRole.teacher;
    // Temporary dropdown value for teachers if needed, otherwise ignored.
    String _teacherSelectedGroupId = 'g1'; 

    return Scaffold(
      appBar: AppBar(title: const Text("Add New Class Routine")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // If it's a CR, show them which group they are adding for
            if (!isTeacher)
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  "Adding routine for: Group $targetGroupId",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),

            // If it IS a teacher, they get the dropdown to pick the group
            if (isTeacher)
              DropdownButtonFormField<String>(
                value: _teacherSelectedGroupId,
                decoration: const InputDecoration(labelText: "Target Group", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'g1', child: Text("Group 1")),
                  DropdownMenuItem(value: 'g2', child: Text("Group 2")),
                ],
                onChanged: (val) => setState(() => _teacherSelectedGroupId = val!),
              ),
            if (isTeacher) const SizedBox(height: 15),

            // Subject Input
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: "Subject Name", border: OutlineInputBorder()),
              validator: (val) => val!.isEmpty ? "Enter Subject Name" : null,
            ),
            const SizedBox(height: 15),

            // Room Input
            TextFormField(
              controller: _roomController,
              decoration: const InputDecoration(labelText: "Room Number", border: OutlineInputBorder()),
              validator: (val) => val!.isEmpty ? "Enter Room Number" : null,
            ),
            const SizedBox(height: 15),

            // Day Selection Dropdown
            DropdownButtonFormField<int>(
              value: _selectedDay,
              decoration: const InputDecoration(labelText: "Select Day", border: OutlineInputBorder()),
              items: List.generate(7, (index) => DropdownMenuItem(
                value: index + 1,
                child: Text(_days[index]),
              )),
              onChanged: (val) => setState(() => _selectedDay = val!),
            ),
            const SizedBox(height: 15),

            // Start Time Picker
            ListTile(
              tileColor: Colors.blue[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Text("Start Time: ${_startTime.format(context)}"),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: _startTime);
                if (time != null) setState(() => _startTime = time);
              },
            ),
            const SizedBox(height: 10),

            // End Time Picker
            ListTile(
              tileColor: Colors.blue[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Text("End Time: ${_endTime.format(context)}"),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: _endTime);
                if (time != null) setState(() => _endTime = time);
              },
            ),

            const SizedBox(height: 30),

            // Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Determine final group ID based on role
                  String finalGroupId = isTeacher ? _teacherSelectedGroupId : targetGroupId;

                  final newEvent = ScheduleEvent(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    groupId: finalGroupId, 
                    teacherId: user.id, // CR or Teacher ID
                    subject: _subjectController.text,
                    room: _roomController.text,
                    startTime: _startTime,
                    endTime: _endTime,
                    dayOfWeek: _selectedDay,
                    recurrenceStartDate: DateTime.now(),
                  );

                  try {
                    debugPrint("Saving Routine for Group: $finalGroupId");
                    await context.read<ScheduleProvider>().addEvent(newEvent);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Routine Saved Successfully!")),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    debugPrint("Error while saving: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to save: $e")),
                    );
                  }
                }
              },
              child: const Text("Save Routine", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}