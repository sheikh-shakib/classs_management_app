// lib/screens/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user!.id; // Get current logged in user ID

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: notificationProvider.notifications.isEmpty
          ? const Center(child: Text("No notifications yet"))
          : ListView.builder(
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                
                return Container(
                  // Highlight unread notifications with a light blue color
                  color: notification.isRead ? Colors.transparent : Colors.blue.shade50,
                  child: ListTile(
                    leading: Icon(
                      Icons.circle,
                      size: 12,
                      // Show a blue dot for unread notifications
                      color: notification.isRead ? Colors.transparent : Colors.blue,
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.message),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, h:mm a').format(notification.timestamp),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Mark as read when the user taps on it
                      if (!notification.isRead) {
                        notificationProvider.markAsRead(userId, notification.id);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}