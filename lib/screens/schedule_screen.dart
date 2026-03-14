import 'package:class_management_app/models/user_model.dart';
import 'package:class_management_app/screens/add_routine_screen.dart';
import 'package:class_management_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/schedule_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // State variable to track the currently viewed date (defaults to today)
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Fetch schedule data on initialization
    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<ScheduleProvider>().loadSchedule(auth.user!);
      }
    });
  }

  Future<void> signOut() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
  }

  // Helper method to go to the next day
  void _nextDay() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
    });
  }

  // Helper method to go to the previous day
  void _previousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
    });
  }

  // Helper method to format the day title
  String _getDayTitle(DateTime date) {
    final now = DateTime.now();
    // Check if the selected date is today
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "Today's Classes";
    }
    // Otherwise, return the specific weekday name
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return "${days[date.weekday - 1]} Classes";
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final canEdit = user?.role == UserRole.teacher || user?.role == UserRole.cr;
    final provider = context.watch<ScheduleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Class Routine"),
        backgroundColor: const Color.fromARGB(255, 147, 214, 253),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.person),
              color: Colors.black,
            ),
          ),
        ],
      ),
      drawer: NavigationDrawer(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 50),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text("Welcome to Classroom Manager")),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home Page"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text("Class Schedule"),
            onTap: () => Navigator.pop(context),
          ),
          if (canEdit)
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Add Routine"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddRoutineScreen()),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Dashboard"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              await signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // --- Navigation Bar (Previous, Title, Next) ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
                        onPressed: _previousDay,
                        tooltip: "Previous Day",
                      ),
                      Text(
                        _getDayTitle(_currentDate),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                        onPressed: _nextDay,
                        tooltip: "Next Day",
                      ),
                    ],
                  ),
                ),
                
                const Divider(thickness: 1),

                // --- Daily Routine Content ---
                Expanded(
                  child: _buildDailyContent(provider, canEdit),
                ),
              ],
            ),
    );
  }

  // Helper to build the content for the selected day
  Widget _buildDailyContent(ScheduleProvider provider, bool canEdit) {
    // Get events specifically for the currently selected date
    final dailyEvents = provider.getEventsForDay(_currentDate);

    if (dailyEvents.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "No classes scheduled for this day 🎉",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildRoutineTable(context, dailyEvents, canEdit, provider),
    );
  }

  // Table widget containing the Group Column
  Widget _buildRoutineTable(BuildContext context, List events, bool canEdit,
      ScheduleProvider provider) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DataTable(
            columnSpacing: 20,
            headingRowColor: WidgetStateProperty.all(Colors.blue[50]),
            columns: [
              const DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
              // --- NEW: Group Column ---
              const DataColumn(label: Text('Group', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('Room', style: TextStyle(fontWeight: FontWeight.bold))),
              if (canEdit) const DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: events.map((e) {
              return DataRow(cells: [
                DataCell(Text("${e.startTime.format(context)} - ${e.endTime.format(context)}")),
                DataCell(Text(e.subject, style: const TextStyle(fontWeight: FontWeight.w500))),
                // Display the groupId assigned to the routine
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(e.groupId.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  )
                ),
                DataCell(Text(e.room)),
                if (canEdit)
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(context, provider, e.id),
                    ),
                  ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ScheduleProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Delete this class?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              provider.deleteEvent(id);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}