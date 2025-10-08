import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dayfi/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dayfi/common/utils/app_logger.dart';

/// DayFi Notification Service
/// Handles both local and push notifications for DayFi events
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _fcmToken;

  /// Initialize the notification service
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _initLocalNotifications();
      await _initFirebaseMessaging();
      _isInitialized = true;
      AppLogger.info('NotificationService initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize NotificationService: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(initSettings);
  }

  /// Handle iOS local notification tap
  void _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {
    print('🔔 iOS local notification received: $title - $body');
  }

  /// Initialize Firebase messaging
  Future<void> _initFirebaseMessaging() async {
    // Request permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.info('Notification permissions granted');
    } else {
      AppLogger.warning('Notification permissions denied');
    }

    // For iOS, wait for APNS token before getting FCM token
    if (Platform.isIOS) {
      AppLogger.info('Waiting for APNS token on iOS...');
      await _waitForAPNSToken();
    }

    // Get and store FCM token
    _fcmToken = await _messaging.getToken();
    AppLogger.info('FCM Token: $_fcmToken');
    print('🔥 FCM Token: $_fcmToken'); // Also print to console for easy copying

    // Set up message handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle initial message (app was terminated)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info('Foreground message received: ${message.messageId}');
    // For foreground messages, we'll show them as local notifications
    _showLocalNotification(
      message.notification?.title ?? 'DayFi',
      message.notification?.body ?? 'You have a new notification',
      message.data,
    );
  }

  /// Handle message opened app
  void _handleMessageOpenedApp(RemoteMessage message) {
    AppLogger.info('Message opened app: ${message.messageId}');
    _handleNotificationTap(message.data);
  }

  /// Handle notification tap
  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final action = data['action'] as String?;
    
    AppLogger.info('Notification tapped - Type: $type, Action: $action');
    
    // Handle different notification types
    switch (type) {
      case 'signup_success':
        // Navigate to profile or welcome screen
        break;
      case 'send_success':
        // Navigate to transaction details
        break;
      case 'receive_money':
        // Navigate to transaction details
        break;
      case 'tier_upgrade':
        // Navigate to account limits
        break;
      default:
        // Navigate to home or default screen
        break;
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    print('🔔 Creating local notification: $title - $body');
    
    const androidDetails = AndroidNotificationDetails(
      'dayfi_channel',
      'DayFi Notifications',
      channelDescription: 'Notifications for DayFi app events',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      badgeNumber: 1,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        notificationDetails,
        payload: data.toString(),
      );
      print('✅ Local notification shown successfully');
      
      // For iOS, also check if we need to request permissions again
      if (Platform.isIOS) {
        final settings = await _messaging.getNotificationSettings();
        print('🔔 iOS notification settings: ${settings.authorizationStatus}');
      }
      
    } catch (e) {
      print('❌ Error showing local notification: $e');
      rethrow;
    }
  }

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Refresh FCM token
  Future<String?> refreshToken() async {
    _fcmToken = await _messaging.getToken();
    AppLogger.info('FCM Token refreshed: $_fcmToken');
    return _fcmToken;
  }

  // ===== DAYFI-SPECIFIC EVENT TRIGGERS =====

  /// Trigger sign up success notification
  Future<void> triggerSignUpSuccess(String userName) async {
    print('🔔 Attempting to show notification for: $userName');
    try {
      await _showLocalNotification(
        'Welcome to DayFi! 🎉',
        'Hi $userName! Your account has been successfully created.',
        {
          'type': 'signup_success',
          'action': 'navigate_to_profile',
          'userName': userName,
        },
      );
      print('✅ Notification triggered successfully');
    } catch (e) {
      print('❌ Error triggering notification: $e');
    }
  }

  /// Force show notification (for testing)
  Future<void> forceShowNotification() async {
    print('🔔 Force showing notification...');
    try {
      await _showLocalNotification(
        'Test Notification! 🔔',
        'This is a test notification from DayFi',
        {
          'type': 'test',
          'action': 'test',
        },
      );
      print('✅ Force notification shown');
    } catch (e) {
      print('❌ Error showing force notification: $e');
    }
  }

  /// Trigger send money success notification
  Future<void> triggerSendSuccess({
    required String recipientName,
    required String amount,
    required String currency,
    required String transactionId,
  }) async {
    await _showLocalNotification(
      'Transfer Successful! ✅',
      'You sent $currency $amount to $recipientName',
      {
        'type': 'send_success',
        'action': 'navigate_to_transaction',
        'transactionId': transactionId,
        'amount': amount,
        'currency': currency,
        'recipient': recipientName,
      },
    );
  }

  /// Trigger receive money notification
  Future<void> triggerReceiveMoney({
    required String senderName,
    required String amount,
    required String currency,
    required String transactionId,
  }) async {
    await _showLocalNotification(
      'Money Received! 💰',
      '$senderName sent you $currency $amount',
      {
        'type': 'receive_money',
        'action': 'navigate_to_transaction',
        'transactionId': transactionId,
        'amount': amount,
        'currency': currency,
        'sender': senderName,
      },
    );
  }

  /// Trigger tier upgrade notification
  Future<void> triggerTierUpgrade({
    required String newTier,
    required String newLimits,
  }) async {
    await _showLocalNotification(
      'Tier Upgraded! 🚀',
      'Congratulations! You\'re now on $newTier with $newLimits',
      {
        'type': 'tier_upgrade',
        'action': 'navigate_to_account_limits',
        'newTier': newTier,
        'newLimits': newLimits,
      },
    );
  }

  /// Trigger KYC verification success
  Future<void> triggerKycSuccess() async {
    await _showLocalNotification(
      'Verification Complete! ✅',
      'Your identity has been successfully verified',
      {
        'type': 'kyc_success',
        'action': 'navigate_to_profile',
      },
    );
  }

  /// Trigger payment method added
  Future<void> triggerPaymentMethodAdded(String methodType) async {
    await _showLocalNotification(
      'Payment Method Added! 💳',
      'Your $methodType has been successfully added',
      {
        'type': 'payment_method_added',
        'action': 'navigate_to_payment_methods',
        'methodType': methodType,
      },
    );
  }

  /// Trigger security alert
  Future<void> triggerSecurityAlert({
    required String alertType,
    required String message,
  }) async {
    await _showLocalNotification(
      'Security Alert! 🔒',
      message,
      {
        'type': 'security_alert',
        'action': 'navigate_to_security',
        'alertType': alertType,
      },
    );
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Wait for APNS token on iOS
  Future<void> _waitForAPNSToken() async {
    if (!Platform.isIOS) return;
    
    int attempts = 0;
    const maxAttempts = 30; // Wait up to 30 seconds
    
    while (attempts < maxAttempts) {
      try {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          AppLogger.info('APNS token received: ${apnsToken.substring(0, 10)}...');
          return;
        }
      } catch (e) {
        AppLogger.warning('APNS token attempt $attempts failed: $e');
      }
      
      await Future.delayed(const Duration(seconds: 1));
      attempts++;
    }
    
    AppLogger.warning('APNS token not received after $maxAttempts attempts, continuing anyway...');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AppLogger.info('Background message received: ${message.messageId}');
}
