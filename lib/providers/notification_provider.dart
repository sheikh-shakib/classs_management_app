// lib/providers/notification_provider.dart
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_services.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service = NotificationService();
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Call this once after user logs in
  void listenToNotifications(String userId) {
    _service.getNotifications(userId).listen((data) {
      _notifications = data;
      notifyListeners();
    });
  }

  Future<void> markAsRead(String userId, String notifId) async {
    await _service.markAsRead(userId, notifId);
  }
}