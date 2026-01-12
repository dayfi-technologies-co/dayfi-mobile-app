import 'package:dayfi/common/utils/app_logger.dart';

/// Web/no-op implementation of NotificationService used to keep imports stable on web.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;

  Future<void> init() async {
    _isInitialized = true;
    AppLogger.info('NotificationService stub initialized (web/no-op)');
  }

  Future<void> showLocalNotification(String title, String body, {Map<String, dynamic>? data}) async {
    AppLogger.info('showLocalNotification (stub) - $title: $body');
  }

  String? get fcmToken => null;

  Future<String?> refreshToken() async => null;

  Future<void> triggerSignUpSuccess(String userName) async {
    AppLogger.info('triggerSignUpSuccess (stub) for $userName');
  }

  @Deprecated('For testing only')
  Future<void> forceShowNotification() async {}

  Future<void> testWelcomeNotification() async {}

  Future<void> triggerSendSuccess({required String recipientName, required String amount, required String currency, required String transactionId}) async {}

  Future<void> triggerReceiveMoney({required String senderName, required String amount, required String currency, required String transactionId}) async {}

  Future<void> triggerTierUpgrade({required String newTier, required String newLimits}) async {}

  Future<void> triggerKycSuccess() async {}

  Future<void> triggerPaymentMethodAdded(String methodType) async {}

  Future<void> triggerSecurityAlert({required String alertType, required String message}) async {}

  Future<void> clearAllNotifications() async {}

  Future<bool> areNotificationsEnabled() async => false;
}
