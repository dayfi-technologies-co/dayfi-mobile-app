import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';

/// Whether the backend expects a paired NGN [sourceAmount] with USD [amount].
bool dayflowAutomationNeedsNgnSource({
  required String paymentType,
  String? recipientHint,
  String? toCurrency,
}) {
  final to = (toCurrency ?? '').trim().toUpperCase();
  if (to.isNotEmpty && to != 'USD') return true;
  if (paymentType == 'bill') return true;

  final hint = (recipientHint ?? '').toLowerCase();
  return RegExp(
    r'opay|palmpay|naira|ngn|mtn|glo|airtel|9mobile|gtb|access|uba|zenith|bank|nigeria|momo',
  ).hasMatch(hint);
}

/// Converts a USD wallet debit to NGN delivery amount using live rates.
Future<double?> dayflowNgnAmountForUsd(double usdAmount) async {
  if (usdAmount <= 0) return null;
  try {
    final rate = await walletService.fetchExchangeRate(
      fromCurrency: 'USD',
      toCurrency: 'NGN',
    );
    if (rate <= 0) return null;
    return (usdAmount * rate).roundToDouble();
  } catch (_) {
    return null;
  }
}

String? dayflowNgnEstimateLabel(double? ngnAmount) {
  if (ngnAmount == null || ngnAmount <= 0) return null;
  return 'Recipient receives ${formatDayFlowAmount(ngnAmount, 'NGN')}';
}
