import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/schedule_event.dart';
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

  // --- NEW: Group Selection Variables ---
  // In a real app, you might fetch this list from Firebase.
  // For now, I'm adding a static list based on your screenshots.
  String _selectedGroupId = 'g2'; // Default to g2
  final List<Map<String, String>> _availableGroups = [
    {'id': 'g1', 'name': 'Group 1'},
    {'id': 'g2', 'name': 'Group 2'},
    // Add more groups here if needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Class Routine")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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

            // --- NEW: Group Selection Dropdown ---
            DropdownButtonFormField<String>(
              value: _selectedGroupId,
              decoration: const InputDecoration(labelText: "Target Group", border: OutlineInputBorder()),
              items: _availableGroups.map((group) => DropdownMenuItem(
                value: group['id'],
                child: Text(group['name']!),
              )).toList(),
              onChanged: (val) => setState(() => _selectedGroupId = val!),
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
                  final auth = context.read<AuthProvider>();
                  
                  // --- CRUCIAL CHANGE: Use the specifically selected group ---
                  String targetGroupId = _selectedGroupId; 

                  final newEvent = ScheduleEvent(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    groupId: targetGroupId, 
                    teacherId: auth.user!.id,
                    subject: _subjectController.text,
                    room: _roomController.text,
                    startTime: _startTime,
                    endTime: _endTime,
                    dayOfWeek: _selectedDay,
                    recurrenceStartDate: DateTime.now(),
                  );

                  try {
                    debugPrint("Saving Routine for Group: $targetGroupId");
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