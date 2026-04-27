// lib/screens/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();

    const backgroundColor = Color(0xFF0F1117);
    const cardColor = Color(0xFF1C1F2E);

    final userId = FirebaseAuth.instance.currentUser?.uid ?? ''; 

    return Scaffold(
      backgroundColor: backgroundColor, 
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: notificationProvider.notifications.isEmpty
          ? const Center(
              child: Text(
                "No notifications yet",
                style: TextStyle(color: Colors.white38),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: notification.isRead ? cardColor : cardColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: notification.isRead 
                        ? null 
                        : Border.all(color: Colors.blue.withOpacity(0.5), width: 1),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.notifications_active,
                      color: notification.isRead ? Colors.white38 : Colors.blue,
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('MMM d, h:mm a').format(notification.timestamp),
                          style: const TextStyle(fontSize: 11, color: Colors.white38),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (!notification.isRead && userId.isNotEmpty) {
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