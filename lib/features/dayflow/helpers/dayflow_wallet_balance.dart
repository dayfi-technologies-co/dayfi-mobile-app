import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/models/wallet_hub.dart';

/// Single global wallet currency shown in DayBudget (USD pool).
const String kDayFlowWalletCurrency = 'USD';

/// Available balance from the global wallet hub in [currency].
double dayFlowWalletBalance(
  WalletHubSnapshot? hub, {
  String currency = kDayFlowWalletCurrency,
}) {
  if (hub == null) return 0;
  return hub.balanceInDisplayCurrency(currency.toUpperCase());
}

/// Global wallet balance expressed in the budget's currency (for affordability checks).
double dayFlowWalletForBudget(WalletHubSnapshot? hub, String budgetCurrency) {
  if (hub == null) return 0;
  return hub.balanceInDisplayCurrency(budgetCurrency.toUpperCase());
}

bool dayFlowBudgetExceedsWallet({
  required WalletHubSnapshot? hub,
  required double budgetTotal,
  required String budgetCurrency,
}) {
  if (budgetTotal <= 0) return false;
  return budgetTotal > dayFlowWalletForBudget(hub, budgetCurrency);
}

double dayFlowBudgetShortfall({
  required WalletHubSnapshot? hub,
  required double budgetTotal,
  required String budgetCurrency,
}) {
  final available = dayFlowWalletForBudget(hub, budgetCurrency);
  return (budgetTotal - available).clamp(0, double.infinity);
}

String dayFlowWalletWelcomeSuffix(WalletHubSnapshot? hub) {
  final balance = dayFlowWalletBalance(hub);
  if (balance <= 0) return '';
  return '\n\nYou have ${formatDayFlowAmount(balance, kDayFlowWalletCurrency)} ${DayFlowCopy.globalWalletAvailableSuffix}.';
}

DayFlowDashboardSnapshot dayFlowOverlayGlobalWallet(
  DayFlowDashboardSnapshot snap,
  WalletHubSnapshot hub,
) {
  final planCurrency = snap.plan?.currency ?? kDayFlowWalletCurrency;
  final available = dayFlowWalletForBudget(hub, planCurrency);
  final free =
      (available - snap.committedThisPeriod).clamp(0.0, double.infinity).toDouble();
  return DayFlowDashboardSnapshot(
    walletBalance: dayFlowWalletBalance(hub),
    walletCurrency: kDayFlowWalletCurrency,
    safeToSpend: free,
    freeToSpend: free,
    committedThisPeriod: snap.committedThisPeriod,
    budgetPeriodLabel: snap.budgetPeriodLabel,
    scheduleInstances: snap.scheduleInstances,
    healthScore: snap.healthScore,
    forecastMessage: snap.forecastMessage,
    insights: snap.insights,
    plan: snap.plan,
    flows: snap.flows,
    totalFlowHeld: snap.totalFlowHeld,
    hasActivePlan: snap.hasActivePlan,
  );
}
