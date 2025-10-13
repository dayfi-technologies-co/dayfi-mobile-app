/// Production configuration for DayFi notifications
/// This file contains production-ready settings and constants
class NotificationConfig {
  // Private constructor to prevent instantiation
  NotificationConfig._();

  // ===== NOTIFICATION CHANNELS =====
  static const String primaryChannelId = 'dayfi_channel';
  static const String primaryChannelName = 'DayFi Notifications';
  static const String primaryChannelDescription = 'Notifications for DayFi app events';
  
  static const String testChannelId = 'test_channel';
  static const String testChannelName = 'Test Notifications';
  static const String testChannelDescription = 'Simple test notifications';

  // ===== NOTIFICATION TYPES =====
  static const String signupSuccessType = 'signup_success';
  static const String sendSuccessType = 'send_success';
  static const String receiveMoneyType = 'receive_money';
  static const String tierUpgradeType = 'tier_upgrade';
  static const String kycSuccessType = 'kyc_success';
  static const String paymentMethodAddedType = 'payment_method_added';
  static const String securityAlertType = 'security_alert';
  static const String testType = 'test';

  // ===== NOTIFICATION ACTIONS =====
  static const String navigateToProfileAction = 'navigate_to_profile';
  static const String navigateToTransactionAction = 'navigate_to_transaction';
  static const String navigateToAccountLimitsAction = 'navigate_to_account_limits';
  static const String navigateToPaymentMethodsAction = 'navigate_to_payment_methods';
  static const String navigateToSecurityAction = 'navigate_to_security';
  static const String testAction = 'test';

  // ===== NOTIFICATION SETTINGS =====
  static const int maxNotificationId = 100000;
  static const int testNotificationId = 999;
  static const int apnsTokenMaxWaitAttempts = 30;
  static const Duration apnsTokenWaitInterval = Duration(seconds: 1);

  // ===== PRODUCTION FLAGS =====
  static const bool enableDebugLogging = false;
  static const bool enableTestMethods = false; // Set to false in production builds
  
  // ===== NOTIFICATION MESSAGES =====
  static const Map<String, String> defaultMessages = {
    'welcome_title': 'Welcome to DayFi! 🎉',
    'welcome_body': 'Hi {userName}! Your account has been successfully created.',
    'transfer_success_title': 'Transfer Successful! ✅',
    'transfer_success_body': 'You sent {currency} {amount} to {recipientName}',
    'money_received_title': 'Money Received! 💰',
    'money_received_body': '{senderName} sent you {currency} {amount}',
    'tier_upgrade_title': 'Tier Upgraded! 🚀',
    'tier_upgrade_body': 'Congratulations! You\'re now on {newTier} with {newLimits}',
    'kyc_success_title': 'Verification Complete! ✅',
    'kyc_success_body': 'Your identity has been successfully verified',
    'payment_method_added_title': 'Payment Method Added! 💳',
    'payment_method_added_body': 'Your {methodType} has been successfully added',
    'security_alert_title': 'Security Alert! 🔒',
    'test_title': 'Test Notification! 🔔',
    'test_body': 'This is a test notification from DayFi',
  };

  // ===== HELPER METHODS =====
  
  /// Get notification message with placeholders replaced
  static String getMessage(String key, Map<String, String> replacements) {
    String message = defaultMessages[key] ?? '';
    
    replacements.forEach((placeholder, value) {
      message = message.replaceAll('{$placeholder}', value);
    });
    
    return message;
  }
  
  /// Check if test methods should be enabled
  static bool shouldEnableTestMethods() {
    return enableTestMethods;
  }
  
  /// Check if debug logging should be enabled
  static bool shouldEnableDebugLogging() {
    return enableDebugLogging;
  }
}



