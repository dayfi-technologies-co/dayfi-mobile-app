import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/models/notification_item.dart';
import 'package:dayfi/services/remote/network/api_error.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/services/remote/network/url_config.dart';

class NotificationService {
  NetworkService _networkService;
  NotificationService({required NetworkService networkService})
    : _networkService = networkService;

  void updateNetworkService() =>
      _networkService = NetworkService(baseUrl: F.baseUrl);

  /// Fetch user notifications
  /// GET /api/v1/notifications
  Future<List<NotificationItem>> fetchNotifications() async {
    try {
      final response = await _networkService.call(
        F.baseUrl + UrlConfig.fetchNotifications,
        RequestMethod.get,
      );

      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        // Try to parse JSON string
        responseData = json.decode(response.data);
      } else {
        throw Exception('Invalid response format');
      }

      if (responseData['status'] == 'success' && responseData['data'] is List) {
        return (responseData['data'] as List)
            .whereType<Map>()
            .map((item) => _fromDayfiApi(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch notifications');
      }
    } on ApiError catch (e) {
      // Backend may omit /notifications entirely, or return 404 for local/dev.
      // NetworkService wraps Dio failures into ApiError, so handle that too.
      if (e.errorType == 404) {
        return [];
      }
      rethrow;
    } on DioException catch (e) {
      // Local/dev backends often omit this route — treat as no notifications instead of error UI.
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch unread notification count
  /// GET /api/v1/notifications/unread-count
  Future<int> fetchUnreadCount() async {
    try {
      final response = await _networkService.call(
        F.baseUrl + UrlConfig.unreadNotificationCount,
        RequestMethod.get,
      );

      final responseData = _parseResponseMap(response.data);
      if (responseData['status'] == 'success' &&
          responseData['data'] is Map<String, dynamic>) {
        final count = responseData['data']['count'];
        if (count is num) return count.toInt();
        return int.tryParse('$count') ?? 0;
      }
      return 0;
    } on ApiError catch (e) {
      if (e.errorType == 404) return 0;
      rethrow;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return 0;
      rethrow;
    }
  }

  /// Mark all notifications as read
  /// PUT /api/v1/notifications/read-all
  Future<void> markAllNotificationsAsRead() async {
    try {
      final response = await _networkService.call(
        F.baseUrl + UrlConfig.readAllNotifications,
        RequestMethod.put,
      );

      final responseData = _parseResponseMap(response.data);
      if (responseData['status'] != 'success') {
        throw Exception(
          responseData['message'] ?? 'Failed to mark notifications as read',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> _parseResponseMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) return Map<String, dynamic>.from(json.decode(data));
    throw Exception('Invalid response format');
  }

  /// Mark a notification as read
  /// PUT /api/v1/notifications/{notificationId}
  Future<String> markNotificationAsRead(String notificationId) async {
    try {
      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.markNotificationAsRead}/$notificationId',
        RequestMethod.put,
      );

      final responseData = _parseResponseMap(response.data);

      if (responseData['status'] == 'success') {
        return responseData['data']['notificationId'] ?? notificationId;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to mark notification as read');
      }
    } catch (e) {
      rethrow;
    }
  }

  NotificationItem _fromDayfiApi(Map<String, dynamic> json) {
    final typeRaw = json['type']?.toString() ?? '';
    NotificationType type;
    switch (typeRaw) {
      case 'P2P_RECEIVE':
      case 'P2P_SEND':
      case 'NGN_DEPOSIT':
      case 'BANK_SEND':
      case 'BILL_PAY':
        type = NotificationType.transaction;
        break;
      case 'BILL_PAY_FAILED':
        type = NotificationType.system;
        break;
      case 'BUDGET_REMINDER':
      case 'BUDGET_BILL_REMINDER':
      case 'BUDGET_SEND_REMINDER':
      case 'BUDGET_DAILY_EARN_REMINDER':
      case 'BUDGET_SPENDING_CAP_REMINDER':
        type = NotificationType.budget;
        break;
      default:
        type = NotificationType.general;
    }

    DateTime timestamp = DateTime.now();
    final created = json['created_at'];
    if (created is String) {
      timestamp = DateTime.tryParse(created) ?? timestamp;
    }

    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      timestamp: timestamp,
      isRead: json['read'] == true,
      type: type,
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }
}