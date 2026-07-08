import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'firebase_service.dart';

/// Service for managing notifications
class NotificationService extends FirebaseService {
  CollectionReference get notificationsCollection =>
      firestore.collection('notifications');

  /// Watch notifications for current user
  Stream<List<NotificationItem>> watchUserNotifications() {
    if (!isAuthenticated) {
      return Stream.value([]);
    }

    return notificationsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return _notificationFromFirestore(doc);
      }).toList();
    });
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await notificationsCollection.doc(notificationId).update({
      'isRead': true,
    });
  }

  /// Mark all notifications as read for current user
  Future<void> markAllAsRead() async {
    if (!isAuthenticated) return;

    final batch = firestore.batch();
    final snapshot = await notificationsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  /// Create a new notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
  }) async {
    await notificationsCollection.add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  /// Convert Firestore document to NotificationItem
  NotificationItem _notificationFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['timestamp'] as Timestamp?;

    return NotificationItem(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: _parseType(data['type'] as String?),
      timestamp: timestamp?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  /// Parse notification type from string
  NotificationType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'arrival':
        return NotificationType.arrival;
      case 'schedule':
        return NotificationType.schedule;
      case 'delay':
        return NotificationType.delay;
      case 'info':
        return NotificationType.info;
      default:
        return NotificationType.info;
    }
  }
}
