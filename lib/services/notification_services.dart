import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // sends notification to all students in a group and the teacher
  Future<void> notifyClassChange({
    required String title,
    required String message,
    required String groupId,
    required String teacherId,
  }) async {
    // get all users in the specific group
    final userSnap = await _db.collection('users').where('groupId', isEqualTo: groupId).get();
    List<String> userIds = userSnap.docs.map((doc) => doc.id).toList();
    if (!userIds.contains(teacherId)) userIds.add(teacherId);

    for (String uid in userIds) {
      final notifRef = _db.collection('users').doc(uid).collection('notifications').doc();
      final notification = NotificationModel(
        id: notifRef.id,
        title: title,
        message: message,
        timestamp: DateTime.now(),
        isRead: false,
      );
      await notifRef.set(notification.toMap());
    }
  }

  // real-time stream for the current user
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _db.collection('users').doc(userId).collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => NotificationModel.fromMap(doc.data())).toList());
  }

  Future<void> markAsRead(String userId, String notifId) async {
    await _db.collection('users').doc(userId).collection('notifications').doc(notifId).update({'isRead': true});
  }
}
