/// Analytics event constants for consistent tracking across the app
class AnalyticsEvents {
  // App Lifecycle Events
  static const String appLaunched = 'app_launched';
  static const String appBackgrounded = 'app_backgrounded';
  static const String appForegrounded = 'app_foregrounded';
  static const String appCrashed = 'app_crashed';

  // Authentication Events
  static const String loginStarted = 'login_started';
  static const String loginCompleted = 'login_completed';
  static const String loginFailed = 'login_failed';
  static const String signupStarted = 'signup_started';
  static const String signupCompleted = 'signup_completed';
  static const String signupFailed = 'signup_failed';
  static const String passcodeEntered = 'passcode_entered';
  static const String passcodeFailed = 'passcode_failed';
  static const String biometricAuthAttempted = 'biometric_auth_attempted';
  static const String biometricAuthSuccess = 'biometric_auth_success';
  static const String biometricAuthFailed = 'biometric_auth_failed';
  static const String logout = 'logout';

  // Transaction Events
  static const String transactionInitiated = 'transaction_initiated';
  static const String transactionCompleted = 'transaction_completed';
  static const String transactionFailed = 'transaction_failed';
  static const String transactionCancelled = 'transaction_cancelled';
  static const String transactionViewed = 'transaction_viewed';
  static const String transactionSearched = 'transaction_searched';
  static const String transactionFiltered = 'transaction_filtered';

  // Send Money Flow Events
  static const String sendMoneyStarted = 'send_money_started';
  static const String recipientSelected = 'recipient_selected';
  static const String amountEntered = 'amount_entered';
  static const String paymentMethodSelected = 'payment_method_selected';
  static const String sendMoneyCompleted = 'send_money_completed';
  static const String sendMoneyFailed = 'send_money_failed';
  static const String sendMoneyCancelled = 'send_money_cancelled';

  // Recipient Management Events
  static const String recipientAdded = 'recipient_added';
  static const String recipientEdited = 'recipient_edited';
  static const String recipientDeleted = 'recipient_deleted';
  static const String recipientSearched = 'recipient_searched';

  // Screen View Events
  static const String screenViewed = 'screen_viewed';
  static const String screenExited = 'screen_exited';

  // Feature Usage Events
  static const String searchPerformed = 'search_performed';
  static const String filterApplied = 'filter_applied';
  static const String buttonClicked = 'button_clicked';
  static const String menuOpened = 'menu_opened';
  static const String settingsChanged = 'settings_changed';

  // API Events
  static const String apiCallStarted = 'api_call_started';
  static const String apiCallCompleted = 'api_call_completed';
  static const String apiCallFailed = 'api_call_failed';

  // Error Events
  static const String errorOccurred = 'error_occurred';
  static const String networkError = 'network_error';
  static const String validationError = 'validation_error';

  // Business Events
  static const String walletBalanceViewed = 'wallet_balance_viewed';
  static const String profileUpdated = 'profile_updated';
  static const String notificationReceived = 'notification_received';
  static const String notificationTapped = 'notification_tapped';
}

/// Analytics event properties for consistent data structure
class AnalyticsProperties {
  // User Properties
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String userPhone = 'user_phone';
  static const String userRegistrationDate = 'user_registration_date';

  // Transaction Properties
  static const String transactionId = 'transaction_id';
  static const String transactionAmount = 'transaction_amount';
  static const String transactionCurrency = 'transaction_currency';
  static const String transactionStatus = 'transaction_status';
  static const String transactionType = 'transaction_type';
  static const String recipientId = 'recipient_id';
  static const String recipientName = 'recipient_name';
  static const String paymentMethod = 'payment_method';

  // Screen Properties
  static const String screenName = 'screen_name';
  static const String previousScreen = 'previous_screen';
  static const String timeOnScreen = 'time_on_screen';

  // Error Properties
  static const String errorCode = 'error_code';
  static const String errorMessage = 'error_message';
  static const String errorStack = 'error_stack';

  // API Properties
  static const String apiEndpoint = 'api_endpoint';
  static const String apiMethod = 'api_method';
  static const String apiResponseTime = 'api_response_time';
  static const String apiStatusCode = 'api_status_code';

  // Feature Properties
  static const String featureName = 'feature_name';
  static const String buttonName = 'button_name';
  static const String searchQuery = 'search_query';
  static const String filterType = 'filter_type';

  // App Properties
  static const String appVersion = 'app_version';
  static const String platform = 'platform';
  static const String deviceModel = 'device_model';
  static const String osVersion = 'os_version';
  static const String networkType = 'network_type';
  static const String timestamp = 'timestamp';
}
