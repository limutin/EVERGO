/// Notification types
enum NotificationType { 
  busArrival,
  delay, 
  scheduleChange, 
  system,
}

/// Notification item model
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  // Legacy getter for backwards compatibility
  String get body => message;

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String? ?? map['body'] as String,
      type: _parseType(map['type'] as String?),
      timestamp: DateTime.parse(map['timestamp'] as String),
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  static NotificationType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'busarrival':
      case 'bus_arrival':
      case 'arrival':
        return NotificationType.busArrival;
      case 'delay':
        return NotificationType.delay;
      case 'schedulechange':
      case 'schedule_change':
      case 'schedule':
        return NotificationType.scheduleChange;
      case 'system':
      case 'info':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}
