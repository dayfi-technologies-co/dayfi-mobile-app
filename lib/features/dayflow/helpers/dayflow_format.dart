import 'package:dayfi/features/dayearn/helpers/dayearn_format.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_wallet_balance.dart';

/// Formatted amount **including** currency symbol (e.g. `₦1,000` — do not prefix `₦` again).
String formatDayFlowAmount(double amount, String currency, {int? decimals}) {
  return formatDayEarnAmount(amount, currency, decimals: decimals);
}

/// Primary USD budget line with optional original NGN the user spoke.
String formatDayFlowBudgetAmount({
  required double amount,
  String currency = kDayFlowWalletCurrency,
  double? sourceAmount,
  String? sourceCurrency,
}) {
  final primary = formatDayFlowAmount(amount, currency);
  if (sourceCurrency == 'NGN' &&
      sourceAmount != null &&
      sourceAmount > 0 &&
      currency.toUpperCase() == kDayFlowWalletCurrency) {
    return '$primary (${formatDayFlowAmount(sourceAmount, 'NGN')})';
  }
  return primary;
}

String currencySymbol(String currency) {
  switch (currency.toUpperCase()) {
    case 'USD':
      return '\$';
    case 'GBP':
      return '£';
    case 'EUR':
      return '€';
    case 'NGN':
    default:
      return '₦';
  }
}
