class UrlConfig {
  // Auth endpoints
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

  // Payment endpoints
  static const String resolveBank = '/payments/resolve-bank';
  static const String createCollection = '/payments/create-collections';
  static const String fetchChannels = '/payments/channels';
  static const String paymentCapabilities = '/payments/capabilities';
  static const String cryptoChannels = '/payments/crypto-channels';
  static const String fetchNetworks = '/payments/networks';
  static const String fetchRates = '/payments/rates';
  static const String fetchFees = '/payments/fees';
  static const String fetchNgBanks = '/payments/banks/ng';
  static const String walletDetails = '/payments/wallet-details';
  static const String greyAccounts = '/payments/grey/accounts';
  static const String receiveCrypto = '/payments/receive/crypto';
  static const String cryptoSendConfig = '/payments/crypto/send-config';
  static const String cryptoBalances = '/payments/crypto/balances';
  static const String cryptoSend = '/payments/crypto/send';
  static const String cryptoSyncInflows = '/payments/crypto/sync-inflows';
  static const String walletFundedYellowCardSend = '/payments/send/yellowcard';
  static const String bankTransfer = '/payments/bank-transfer';
  static const String receiveUsBank = '/payments/receive/us-bank';
  static const String exchangeRate = '/payments/exchange-rate';
  static const String walletExchangeRates = '/payments/exchange-rates/wallet';
  static const String walletSwap = '/payments/wallets/swap';
  static const String createWallet = '/payments/wallets';
  static const String provisionNgnFiat = '/payments/wallets/add/fiat/ngn';

  // Investment
  static const String investment = '/payments/investment';
  static const String investmentPlans = '/payments/investment/plans';
  static const String investmentPositions = '/payments/investment/positions';
  static const String investmentQuote = '/payments/investment/quote';
  static const String investmentDeposit = '/payments/investment/deposit';
  static const String investmentWithdraw = '/payments/investment/withdraw';
  static const String investmentAcceptRisk = '/payments/investment/accept-risk';
  static String investmentClaim(String positionId) =>
      '/payments/investment/positions/$positionId/claim';

  // DayEarn
  static const String dayEarn = '/payments/dayearn';
  static const String dayEarnPreview = '/payments/dayearn/preview';
  static const String dayEarnPots = '/payments/dayearn/pots';
  static String dayEarnPot(String potId) => '/payments/dayearn/pots/$potId';
  static String dayEarnPotDeposit(String potId) =>
      '/payments/dayearn/pots/$potId/deposit';
  static String dayEarnPotWithdraw(String potId) =>
      '/payments/dayearn/pots/$potId/withdraw';

  // Wallet provisioning
  /// Async job: returns `job_id` (or completed payload in `data`).
  static const String walletProvisionStart = '/payments/wallet-provision/start';
  /// GET with path suffix `/{job_id}` — see [WalletProvisionService].
  static const String walletProvisionStatus = '/payments/wallet-provision/status';
  static const String walletRecoveryPhrase =
      '/payments/wallet-provision/recovery-phrase';
  /// Optional: mark user as having confirmed recovery phrase backup.
  static const String walletBackupConfirmed = '/auth/wallet-backup-confirmed';

  // Budgets
  static const String budgets = '/payments/budgets';
  static String budgetDetail(String id) => '/payments/budgets/$id';
  static String budgetPause(String id) => '/payments/budgets/$id/pause';
  static String budgetResume(String id) => '/payments/budgets/$id/resume';

  // Bills
  static const String billCategories = '/payments/bills/categories';
  static const String billBillers = '/payments/bills/categories';
  static const String billItems = '/payments/bills/billers';
  static const String billValidate = '/payments/bills/validate';
  static const String billPay = '/payments/bills/pay';
  static const String featureActivity = '/payments/feature-activity';
  static const String beneficiaries = '/payments/beneficiaries';

  // Smile KYC
  // KYC
  static const String kycVerifyIdentity = '/kyc/verify-identity';
  static const String smileKycStatus = '/kyc/status';
  static const String smileComplete = '/kyc/smile/complete';
  static const String smilePrepareBvn = '/kyc/smile/prepare-bvn';
  static const String smileVerifyBvn = '/kyc/smile/verify-bvn';
  static const String smileVerifyNin = '/kyc/smile/verify-nin';

  // Notification endpoints
  static const String fetchNotifications = '/notifications';
  static const String markNotificationAsRead = '/notifications';
  static const String unreadNotificationCount = '/notifications/unread-count';
  static const String readAllNotifications = '/notifications/read-all';
}
