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
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );
    
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
    
    // Create notification channels for Android
    await _createNotificationChannels();
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    const androidChannel = AndroidNotificationChannel(
      'dayfi_channel',
      'DayFi Notifications',
      description: 'Notifications for DayFi app events',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle notification response (when user taps notification)
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    AppLogger.info('Notification tapped: ${response.payload}');
    // Handle notification tap based on payload
    if (response.payload != null) {
      try {
        // Parse payload and handle navigation
        // This can be expanded based on your needs
      } catch (e) {
        AppLogger.error('Error handling notification response: $e');
      }
    }
  }

  /// Handle iOS local notification tap
  void _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {
    AppLogger.info('iOS local notification received: $title - $body');
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
    AppLogger.info('Message title: ${message.notification?.title}');
    AppLogger.info('Message body: ${message.notification?.body}');
    AppLogger.info('Message data: ${message.data}');
    
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
    try {
      AppLogger.info('Attempting to show local notification: $title');
      
      // Check if local notifications are initialized
      if (!_isInitialized) {
        AppLogger.warning('NotificationService not initialized, initializing now...');
        await init();
      }
    
      final androidDetails = AndroidNotificationDetails(
        'dayfi_channel',
        'DayFi Notifications',
        channelDescription: 'Notifications for DayFi app events',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        showWhen: true,
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
        interruptionLevel: InterruptionLevel.active,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      await _localNotifications.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: data.toString(),
      );
      
      AppLogger.info('Local notification shown successfully with ID: $notificationId');
      
    } catch (e) {
      AppLogger.error('Error showing local notification: $e');
      // Don't rethrow in production - notifications are non-critical
    }
  }

  /// Show a local notification directly (public method)
  Future<void> showLocalNotification(
    String title,
    String body, {
    Map<String, dynamic>? data,
  }) async {
    await _showLocalNotification(
      title,
      body,
      data ?? {},
    );
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
    try {
      AppLogger.info('=== TRIGGERING WELCOME NOTIFICATION ===');
      AppLogger.info('User name: $userName');
      AppLogger.info('Is initialized: $_isInitialized');
      
      // Ensure service is initialized
      if (!_isInitialized) {
        AppLogger.info('NotificationService not initialized, initializing now...');
        await init();
      }
      
      // Add a small delay to ensure everything is ready
      await Future.delayed(const Duration(milliseconds: 300));
      
      await _showLocalNotification(
        'Welcome to DayFi! 🎉',
        'Hi $userName! Your account is ready. Send money to those who matter.',
        {
          'type': 'signup_success',
          'action': 'navigate_to_profile',
          'userName': userName,
        },
      );
      
      AppLogger.info('Sign up success notification triggered successfully for: $userName');
    } catch (e) {
      AppLogger.error('Error triggering sign up notification: $e');
      // Retry once if failed
      try {
        AppLogger.info('Retrying notification...');
        await Future.delayed(const Duration(milliseconds: 500));
        await _showLocalNotification(
          'Welcome to DayFi! 🎉',
          'Hi $userName! Your account is ready. Send money to those who matter.',
          {
            'type': 'signup_success',
            'action': 'navigate_to_profile',
            'userName': userName,
          },
        );
        AppLogger.info('Retry successful');
      } catch (retryError) {
        AppLogger.error('Retry also failed: $retryError');
      }
    }
  }

  /// Force show notification (for testing - remove in production)
  @Deprecated('This method is for testing only. Remove in production builds.')
  Future<void> forceShowNotification() async {
    AppLogger.info('Force showing test notification...');
    try {
      await _showLocalNotification(
        'Test Notification! 🔔',
        'This is a test notification from DayFi',
        {
          'type': 'test',
          'action': 'test',
        },
      );
      AppLogger.info('Force notification shown successfully');
    } catch (e) {
      AppLogger.error('Error showing force notification: $e');
    }
  }

  /// Test welcome notification (for testing)
  Future<void> testWelcomeNotification() async {
    AppLogger.info('Testing welcome notification...');
    try {
      await showLocalNotification(
        'Welcome to DayFi! 🎉',
        'Your account is ready. Send money to those who matter.',
        data: {
          'type': 'welcome',
          'action': 'navigate_to_profile',
        },
      );
      AppLogger.info('Welcome notification test completed');
    } catch (e) {
      AppLogger.error('Error testing welcome notification: $e');
    }
  }

  /// Simple notification test (no Firebase required - remove in production)
  @Deprecated('This method is for testing only. Remove in production builds.')
  Future<void> simpleNotificationTest() async {
    AppLogger.info('Testing simple notification...');
    try {
      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Simple test notifications',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
        interruptionLevel: InterruptionLevel.active,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        999,
        'Simple Test! 🎉',
        'This is a simple notification test',
        notificationDetails,
      );
      AppLogger.info('Simple notification test completed successfully');
    } catch (e) {
      AppLogger.error('Error in simple notification test: $e');
    }
  }

  /// Trigger send money success notification
  Future<void> triggerSendSuccess({
    required String recipientName,
    required String amount,
    required String currency,
    required String transactionId,
  }) async {
    try {
      await _showLocalNotification(
        'Transfer Complete',
        '$currency $amount sent to $recipientName',
        {
          'type': 'send_success',
          'action': 'navigate_to_transaction',
          'transactionId': transactionId,
          'amount': amount,
          'currency': currency,
          'recipient': recipientName,
        },
      );
      AppLogger.info('Send success notification triggered for transaction: $transactionId');
    } catch (e) {
      AppLogger.error('Error triggering send success notification: $e');
    }
  }

  /// Trigger receive money notification
  Future<void> triggerReceiveMoney({
    required String senderName,
    required String amount,
    required String currency,
    required String transactionId,
  }) async {
    try {
      await _showLocalNotification(
        'Money Received',
        '$currency $amount from $senderName',
        {
          'type': 'receive_money',
          'action': 'navigate_to_transaction',
          'transactionId': transactionId,
          'amount': amount,
          'currency': currency,
          'sender': senderName,
        },
      );
      AppLogger.info('Receive money notification triggered for transaction: $transactionId');
    } catch (e) {
      AppLogger.error('Error triggering receive money notification: $e');
    }
  }

  /// Trigger tier upgrade notification
  Future<void> triggerTierUpgrade({
    required String newTier,
    required String newLimits,
  }) async {
    try {
      await _showLocalNotification(
        'Account Upgraded',
        'You\'re now on $newTier with $newLimits',
        {
          'type': 'tier_upgrade',
          'action': 'navigate_to_account_limits',
          'newTier': newTier,
          'newLimits': newLimits,
        },
      );
      AppLogger.info('Tier upgrade notification triggered for: $newTier');
    } catch (e) {
      AppLogger.error('Error triggering tier upgrade notification: $e');
    }
  }

  /// Trigger KYC verification success
  Future<void> triggerKycSuccess() async {
    try {
      await _showLocalNotification(
        'Verification Complete',
        'Your identity has been verified',
        {
          'type': 'kyc_success',
          'action': 'navigate_to_profile',
        },
      );
      AppLogger.info('KYC success notification triggered');
    } catch (e) {
      AppLogger.error('Error triggering KYC success notification: $e');
    }
  }

  /// Trigger payment method added
  Future<void> triggerPaymentMethodAdded(String methodType) async {
    try {
      await _showLocalNotification(
        'Payment Method Added',
        'Your $methodType has been added',
        {
          'type': 'payment_method_added',
          'action': 'navigate_to_payment_methods',
          'methodType': methodType,
        },
      );
      AppLogger.info('Payment method added notification triggered for: $methodType');
    } catch (e) {
      AppLogger.error('Error triggering payment method added notification: $e');
    }
  }

  /// Trigger security alert
  Future<void> triggerSecurityAlert({
    required String alertType,
    required String message,
  }) async {
    try {
      await _showLocalNotification(
        'Security Alert',
        message,
        {
          'type': 'security_alert',
          'action': 'navigate_to_security',
          'alertType': alertType,
        },
      );
      AppLogger.info('Security alert notification triggered: $alertType');
    } catch (e) {
      AppLogger.error('Error triggering security alert notification: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      AppLogger.info('All notifications cleared');
    } catch (e) {
      AppLogger.error('Error clearing notifications: $e');
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      final isEnabled = settings.authorizationStatus == AuthorizationStatus.authorized;
      AppLogger.info('Notifications enabled: $isEnabled');
      return isEnabled;
    } catch (e) {
      AppLogger.error('Error checking notification status: $e');
      return false;
    }
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
