import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/models/notification_item.dart';
import 'package:dayfi/services/remote/notification_service.dart';
import 'package:dayfi/app_locator.dart';

class NotificationsState {
  final List<NotificationItem> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? errorMessage;

  const NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationsState copyWith({
    List<NotificationItem>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class NotificationsViewModel extends StateNotifier<NotificationsState> {
  final NotificationService _notificationService;

  NotificationsViewModel(this._notificationService)
      : super(const NotificationsState());

  Future<void> loadNotifications({bool isInitialLoad = false}) async {
    final shouldShowLoading = isInitialLoad || state.notifications.isEmpty;
    state = state.copyWith(
      isLoading: shouldShowLoading,
      errorMessage: null,
    );

    try {
      final results = await Future.wait([
        _notificationService.fetchNotifications(),
        _notificationService.fetchUnreadCount(),
      ]);
      final notifications = results[0] as List<NotificationItem>;
      final unreadCount = results[1] as int;

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final wasUnread = state.notifications.any(
      (n) => n.id == notificationId && !n.isRead,
    );

    try {
      await _notificationService.markNotificationAsRead(notificationId);
    } catch (_) {}

    final updatedNotifications = state.notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: wasUnread && state.unreadCount > 0
          ? state.unreadCount - 1
          : state.unreadCount,
    );
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllNotificationsAsRead();
    } catch (_) {}

    final updatedNotifications = state.notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: 0,
    );
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsViewModel, NotificationsState>((ref) {
  return NotificationsViewModel(notificationService);
});
