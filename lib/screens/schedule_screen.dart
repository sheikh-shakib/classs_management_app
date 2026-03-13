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
  // Weekdays mapping from Saturday to Friday
  final List<Map<String, dynamic>> _weekDays = [
    {'name': 'Saturday', 'weekday': 6},
    {'name': 'Sunday', 'weekday': 7},
    {'name': 'Monday', 'weekday': 1},
    {'name': 'Tuesday', 'weekday': 2},
    {'name': 'Wednesday', 'weekday': 3},
    {'name': 'Thursday', 'weekday': 4},
    {'name': 'Friday', 'weekday': 5},
  ];

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
      // RESTORED: Existing Side Drawer
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
          // Conditional Add Routine Tile
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
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              children: [
                Center(child: _buildSectionTitle("Today's Classes")),
                const SizedBox(height: 10),
                _buildTodayContent(provider, canEdit),
                const Divider(height: 40, thickness: 2),
                Center(child: _buildSectionTitle("Weekly Schedule")),
                const SizedBox(height: 15),
                ..._buildWeeklySchedule(provider, canEdit),
              ],
            ),
    );
  }

  // Helper to build Today's content
  Widget _buildTodayContent(ScheduleProvider provider, bool canEdit) {
    final todayEvents = provider.getEventsForDay(DateTime.now());
    if (todayEvents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
            child: Text("No classes today 🎉",
                style: TextStyle(fontSize: 16, color: Colors.grey))),
      );
    }
    return _buildRoutineTable(context, todayEvents, canEdit, provider);
  }

  // Helper to build the full week's tables
  List<Widget> _buildWeeklySchedule(ScheduleProvider provider, bool canEdit) {
    return _weekDays.map((day) {
      final dayEvents = provider.events
          .where((e) => e.dayOfWeek == day['weekday'])
          .toList()
        ..sort((a, b) => (a.startTime.hour * 60 + a.startTime.minute)
            .compareTo(b.startTime.hour * 60 + b.startTime.minute));

      if (dayEvents.isEmpty) return const SizedBox.shrink();

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(day['name'],
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue)),
          ),
          _buildRoutineTable(context, dayEvents, canEdit, provider),
          const SizedBox(height: 25),
        ],
      );
    }).toList();
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold));
  }

  // Table widget centered with horizontal scroll
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
          ),
          child: DataTable(
            columnSpacing: 20,
            headingRowColor: WidgetStateProperty.all(Colors.blue[50]),
            columns: [
              const DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('Room', style: TextStyle(fontWeight: FontWeight.bold))),
              if (canEdit) const DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: events.map((e) {
              return DataRow(cells: [
                DataCell(Text("${e.startTime.format(context)} - ${e.endTime.format(context)}")),
                DataCell(Text(e.subject, style: const TextStyle(fontWeight: FontWeight.w500))),
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