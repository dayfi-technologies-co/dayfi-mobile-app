import 'package:dayfi/models/notification_item.dart';

const budgetNotificationTypes = {
  'BUDGET_REMINDER',
  'BUDGET_BILL_REMINDER',
  'BUDGET_SEND_REMINDER',
  'BUDGET_DAILY_EARN_REMINDER',
  'BUDGET_SPENDING_CAP_REMINDER',
};

bool isBudgetNotification(NotificationItem item) {
  final code = item.metadata?['type']?.toString() ?? '';
  return budgetNotificationTypes.contains(code) ||
      item.type == NotificationType.budget;
}

String? budgetIdFromNotification(NotificationItem item) {
  final id = item.metadata?['budgetId']?.toString();
  if (id == null || id.isEmpty) return null;
  return id;
}
