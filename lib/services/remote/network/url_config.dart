class UrlConfig {
  //Auth Endpoints
  static const String login = '/auth/login';
  static const String googleAuth = '/auth/google-auth';
  static const String appleAuth = '/auth/apple-auth';
  /// Kept for backwards compatibility; prefer [googleAuth].
  static const String checkEmail = googleAuth;
    static const String validateEmail = '/auth/validate-email';
  static const String signup = '/auth/signup';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String updateProfile = '/auth/update-profile';
  static const String updateBiometrics = '/auth/update-biometrics';
  static const String verifyBvn = '/auth/verify-bvn';
  static const String addDayfiId = '/payments/add-dayfi-id';
  static const String validateDayfiId = '/payments/validate-dayfi-id';
  static const String changeTransactionPin = '/auth/change-transaction-pin';
  static const String resetTransactionPin = '/auth/update-transaction-pin';
  static const String deleteAccount = '/auth/delete-account';

  //Payment Endpoints
  static const String resolveBank = '/payments/resolve-bank';
  static const String createCollection = '/payments/create-collections';
  static const String fetchChannels = '/payments/channels';
  static const String paymentCapabilities = '/payments/capabilities';
  static const String cryptoChannels = '/payments/crypto-channels';
  static const String fetchNetworks = '/payments/networks';
  static const String fetchRates = '/payments/rates';
  static const String fetchFees = '/payments/fees';
  /// Async job: returns `job_id` (or completed payload in `data`).
  static const String walletProvisionStart = '/payments/wallet-provision/start';
  /// GET with path suffix `/{job_id}` — see [WalletProvisionService].
  static const String walletProvisionStatus = '/payments/wallet-provision/status';

  /// Optional: mark user as having confirmed recovery phrase backup.
  static const String walletBackupConfirmed = '/auth/wallet-backup-confirmed';

  //Notification Endpoints
  static const String fetchNotifications = '/notifications';
  static const String markNotificationAsRead = '/notifications';
}
