/// Pay bills user-facing copy.
String payViaTitle(String type) => '$type';

const String kPayBillsHubTitle = 'Pay bills';

const String kPayBillsLocalTitle = 'Local bills';

const String kPayBillsHubDescription =
    'Local Nigerian or international bills.';

const String kPayBillsLocalDescription =
    'Airtime, data, TV, internet, and utilities.';

const String kPayBillsInternationalDescription =
    'International bills are coming soon. Use Local bills for now.';

const String kPayBillFormDescription =
    'Customer details and amount — debited from your global balance at the live rate.';

String payBillsAvailableSubtitle(double ngnEquivalent) {
  return 'Available for bills: ${formatPayNgnAmount(ngnEquivalent)}';
}

String formatPayNgnAmount(double amount) {
  return formatBillNgnAmount(amount, decimals: 2);
}

/// Whole or fixed-decimal NGN for bill pickers and fees (commas, no stray decimals).
String formatBillNgnAmount(double amount, {int decimals = 0}) {
  final fixed = amount.toStringAsFixed(decimals);
  final parts = fixed.split('.');
  var integer = parts[0];
  final buf = StringBuffer('₦');
  for (var i = 0; i < integer.length; i++) {
    if (i > 0 && (integer.length - i) % 3 == 0) buf.write(',');
    buf.write(integer[i]);
  }
  if (decimals > 0 && parts.length > 1) {
    buf.write('.${parts[1]}');
  }
  return buf.toString();
}

const String kPayBillButtonLabel = 'Pay bill';
const String kPayBillAmountHint =
    'Amount is charged in NGN. Your global USD balance is debited at the current FX rate.';

/// Shown when Flutterwave bill float is empty — not the user's Dayfi balance.
const String kBillPartnerUnavailableMessage =
    'Bill payments are temporarily unavailable. Our payment partner cannot process this right now — please try again shortly.';
