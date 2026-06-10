/// Production feature tiers for v1 ship.
///
/// **Tier A** — live: full QA on prod API, primary nav OK.
/// **Tier B** — visible with "Coming soon" / support copy; no failing primary CTA.
/// **Tier C** — no navigation (code may remain on disk).
abstract final class ProductFeatures {
  ProductFeatures._();

  // --- Tier A (live) ---
  static const bool authOnboarding = true;
  static const bool walletAddMoney = true;
  static const bool sendCore = true;
  static const bool payLocalBills = true;
  static const bool dayFlowAutopay = true;
  static const bool budgets = true;
  static const bool dayXOverlay = true;
  static const bool transactionsHistory = true;
  static const bool notifications = true;
  static const bool profileBasics = true;

  /// DayEarn promo on Home + entry from `_onDayEarnTapped`.
  static const bool dayEarnHomePromo = true;

  /// Invest positions in Home ongoing section (requires backend QA).
  static const bool investHomeOngoing = false;

  /// Home ongoing budgets preview (DayFlow-aware).
  static const bool homeOngoingBudgets = true;

  // --- Tier B (limited / labeled) ---
  static const bool payInternationalBills = false;
  static const bool cryptoAddMoney = true;
  static const bool profileNamePhoneSelfServe = false;

  /// In-app account deletion. When false, users are directed to support.
  static const bool profileDeleteAccount = false;

  // --- Tier C (hidden — no routes / nav) ---
  static const bool softPos = false;
  static const bool tapToPayPromo = false;
  static const bool dayFlowChatPrototype = false;
  static const bool dayFlowDeadViews = false;
}
