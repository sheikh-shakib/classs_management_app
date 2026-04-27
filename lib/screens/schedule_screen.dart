import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../models/notification_model.dart';
import '../models/schedule_event.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/schedule_provider.dart';
import '../services/notification_services.dart';
import '../services/schedule_service.dart';
import 'add_routine_screen.dart';
import 'login_screen.dart';
import 'notification_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _weekStart;
  List<String> teacherList = [];
  List<String> roomList = [];
  List<String> groupList = [];

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  void initState() {
    super.initState();
    _weekStart = _getWeekStart(_selectedDate);

    loadDropdownData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<ScheduleProvider>().loadSchedule(user);
      }
    });
  }

  Future<void> loadDropdownData() async {
    final service = ScheduleService();

    final t = await service.getTeacherIds();
    final r = await service.getAllRoomNames();
    final g = await service.getAllgroups();

    if (mounted) {
      setState(() {
        teacherList = t;
        roomList = r;
        groupList = g;
      });
    }
  }

  void _openAdd(UserModel user, {ScheduleEvent? event}) {
    showDialog(
      context: context,
      builder: (_) => AddRoutineScreen(
        user: user,
        existingEvent: event,
        allEvents: context.read<ScheduleProvider>().events,
        teacherList: teacherList,
        roomList: roomList,
        groupList: groupList,
        onSave: (e) async {
          final conflicts = await ScheduleService().checkConflicts(e);

          if (conflicts.isNotEmpty) {
            _showConflictDialog(conflicts);
            return;
          }

          if (event != null) {
            await context.read<ScheduleProvider>().deleteEvent(event.id);
          }

          await context.read<ScheduleProvider>().addEvent(e);
        },
      ),
    );
  }

  void _showConflictDialog(List<String> conflicts) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Conflict"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: conflicts.map((e) => Text(e)).toList(),
        ),
      ),
    );
  }

  void _cancelOnce(ScheduleEvent e) async {
    await context.read<ScheduleProvider>().cancelOnce(e.id, _selectedDate);

    final user = context.read<AuthProvider>().user;
    if (user != null && mounted) {
      context.read<ScheduleProvider>().loadSchedule(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final schedule = context.watch<ScheduleProvider>();

    if (user == null) return const Scaffold();

    final events =
        schedule.events.where((e) => e.occursOn(_selectedDate)).toList()
          ..sort((a, b) {
            final aMin = a.startTime.hour * 60 + a.startTime.minute;
            final bMin = b.startTime.hour * 60 + b.startTime.minute;
            return aMin.compareTo(bMin);
          });

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      floatingActionButton:
          (user.role == UserRole.teacher || user.role == UserRole.cr)
              ? FloatingActionButton(
                  onPressed: () => _openAdd(user),
                  child: const Icon(Icons.add),
                )
              : null,
      body: SafeArea(
        child: Column(
          children: [
            _header(user),
            _weekNav(),
            _daysRow(),
            Expanded(
              child: schedule.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : events.isEmpty
                      ? const Center(
                          child: Text(
                            "No classes",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (_, i) {
                            final e = events[i];
                            final conflict = _hasConflict(e, schedule.events);
                            return _card(e, user, conflict);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasConflict(ScheduleEvent e, List<ScheduleEvent> all) {
    final service = ScheduleService();

    for (var other in all) {
      if (other.id == e.id) continue;
      if (e.dayOfWeek != other.dayOfWeek) continue;

      if (!service.isTimeOverlap(
        e.startTime,
        e.endTime,
        other.startTime,
        other.endTime,
      )) {
        continue;
      }

      if (e.room == other.room ||
          e.teacherId == other.teacherId ||
          e.groupId == other.groupId) {
        return true;
      }
    }
    return false;
  }

  Widget _header(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),

          StreamBuilder<List<NotificationModel>>(
            stream: NotificationService().getNotifications(FirebaseAuth.instance.currentUser!.uid),
            builder: (context, snapshot) {
              int unreadCount =
                  snapshot.data?.where((n) => !n.isRead).length ?? 0;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      // Ensure NotificationProvider is listening before navigating
                      context.read<NotificationProvider>().listenToNotifications(FirebaseAuth.instance.currentUser!.uid);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationScreen()),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          IconButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _weekNav() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () {
            setState(() {
              _weekStart = _weekStart.subtract(const Duration(days: 7));
              _selectedDate = _weekStart;
            });
          },
        ),
        const Spacer(),
        Text(
          "${_weekStart.day}/${_weekStart.month}",
          style: const TextStyle(color: Colors.white),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.white),
          onPressed: () {
            setState(() {
              _weekStart = _weekStart.add(const Duration(days: 7));
              _selectedDate = _weekStart;
            });
          },
        ),
      ],
    );
  }

  Widget _daysRow() {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      children: List.generate(7, (i) {
        final day = _weekStart.add(Duration(days: i));
        final selected =
            _selectedDate.year == day.year &&
            _selectedDate.month == day.month &&
            _selectedDate.day == day.day;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDate = day),
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: selected ? Colors.blue : Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    labels[i],
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${day.day}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _card(ScheduleEvent e, UserModel user, bool conflict) {
    return Card(
      color: const Color(0xFF1C1F2E),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(e.subject, style: const TextStyle(color: Colors.white)),
            Text(e.teacherId, style: const TextStyle(color: Colors.white)),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${e.startTime.format(context)} - ${e.endTime.format(context)}",
              style: const TextStyle(color: Colors.white54),
            ),
            Text(e.room, style: const TextStyle(color: Colors.white54)),
          ],
        ),
        trailing: (user.role == UserRole.teacher || user.role == UserRole.cr)
            ? PopupMenuButton<String>(
                iconColor: Colors.white,
                onSelected: (v) {
                  if (v == "edit") _openAdd(user, event: e);
                  if (v == "cancel_once") _cancelOnce(e);
                  if (v == "delete") {
                    context.read<ScheduleProvider>().deleteEvent(e.id);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: "edit", child: Text("Edit")),
                  PopupMenuItem(
                    value: "cancel_once",
                    child: Text("Cancel Once"),
                  ),
                  PopupMenuItem(value: "delete", child: Text("Delete")),
                ],
              )
            : null,
      ),
    );
  }
}