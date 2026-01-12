import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/models/notification_item.dart';
import 'package:dayfi/services/remote/notification_service.dart';
import 'package:dayfi/app_locator.dart';

class NotificationsState {
  final List<NotificationItem> notifications;
  final bool isLoading;
  final String? errorMessage;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationsState copyWith({
    List<NotificationItem>? notifications,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
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
    // Only show loading state if there's no existing data (initial load)
    final shouldShowLoading = isInitialLoad || state.notifications.isEmpty;
    state = state.copyWith(
      isLoading: shouldShowLoading,
      errorMessage: null,
    );

    try {
      final notifications = await _notificationService.fetchNotifications();

      state = state.copyWith(
        notifications: notifications,
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
    try {
      await _notificationService.markNotificationAsRead(notificationId);
      
      // Update local state
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      // If API call fails, still update local state for better UX
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      state = state.copyWith(notifications: updatedNotifications);
      // Could show error message here if needed
    }
  }

  void markAllAsRead() {
    final updatedNotifications = state.notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();

    state = state.copyWith(notifications: updatedNotifications);
  }
}

// Provider
final notificationsProvider =
    StateNotifierProvider<NotificationsViewModel, NotificationsState>((ref) {
  return NotificationsViewModel(notificationService);
});