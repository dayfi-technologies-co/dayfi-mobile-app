class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.actionUrl,
    this.metadata,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.name,
      'actionUrl': actionUrl,
      'metadata': metadata,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      actionUrl: json['actionUrl'],
      metadata: json['metadata'],
    );
  }

  factory NotificationItem.fromApiJson(Map<String, dynamic> json) {
    // Extract data from the API response structure
    final payload = json['payload'] as Map<String, dynamic>?;
    final notification = payload?['notification'] as Map<String, dynamic>?;
    final data = payload?['data'] as Map<String, dynamic>?;

    // Parse timestamp from created_at
    DateTime timestamp;
    if (json['created_at'] is Map<String, dynamic>) {
      final createdAt = json['created_at'] as Map<String, dynamic>;
      final seconds = createdAt['_seconds'] as int?;
      if (seconds != null) {
        timestamp = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      } else {
        timestamp = DateTime.now();
      }
    } else {
      timestamp = DateTime.now();
    }

    // Determine notification type based on data.type
    NotificationType type;
    final apiType = data?['type'] as String?;
    switch (apiType) {
      case 'P2P_RECEIVE':
      case 'P2P_SEND':
        type = NotificationType.transaction;
        break;
      default:
        type = NotificationType.general;
    }

    return NotificationItem(
      id: json['id'] ?? '',
      title: notification?['title'] ?? 'Notification',
      message: notification?['body'] ?? '',
      timestamp: timestamp,
      isRead: json['read'] ?? false,
      type: type,
      metadata: data,
    );
  }
}

enum NotificationType {
  transaction,
  security,
  promotion,
  system,
  general,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.transaction:
        return 'Transaction';
      case NotificationType.security:
        return 'Security';
      case NotificationType.promotion:
        return 'Promotion';
      case NotificationType.system:
        return 'System';
      case NotificationType.general:
        return 'General';
    }
  }

  String get emoji {
    switch (this) {
      case NotificationType.transaction:
        return '💰';
      case NotificationType.security:
        return '🔒';
      case NotificationType.promotion:
        return '🎉';
      case NotificationType.system:
        return '⚙️';
      case NotificationType.general:
        return '📢';
    }
  }
}
