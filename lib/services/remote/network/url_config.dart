class UrlConfig {
  //Auth Endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String updateProfile = '/auth/update-profile';
  static const String updateBiometrics = '/auth/update-biometrics';
  
  //Payment Endpoints
  static const String resolveBank = '/payments/resolve-bank';
  static const String createCollection = '/payments/create-collections';
  static const String fetchChannels = '/payments/channels';
  static const String fetchNetworks = '/payments/networks';
  static const String fetchRates = '/payments/rates';
}
