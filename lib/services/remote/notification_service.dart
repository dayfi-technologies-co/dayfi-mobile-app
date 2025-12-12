import 'dart:convert';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/models/notification_item.dart';
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

      // Handle response data - check if it's a Map or String
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
        final notifications = (responseData['data'] as List)
            .map((item) => NotificationItem.fromApiJson(item))
            .toList();
        return notifications;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch notifications');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Mark a notification as read
  /// PUT /api/v1/notifications/{notificationId}
  Future<String> markNotificationAsRead(String notificationId) async {
    try {
      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.markNotificationAsRead}/$notificationId',
        RequestMethod.put,
      );

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        // Try to parse JSON string
        responseData = json.decode(response.data);
      } else {
        throw Exception('Invalid response format');
      }

      if (responseData['status'] == 'success') {
        return responseData['data']['notificationId'] ?? notificationId;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to mark notification as read');
      }
    } catch (e) {
      rethrow;
    }
  }
}