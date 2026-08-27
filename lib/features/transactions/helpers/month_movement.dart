import 'package:dayfi/common/helpers/wallet_transaction_display.dart';
import 'package:dayfi/common/helpers/wallet_transaction_labels.dart';
import 'package:dayfi/models/wallet_transaction.dart';

class MonthMovement {
  final double receivedUsd;
  final double sentUsd;
  final int counted;
  final int inMonth;

  const MonthMovement({
    required this.receivedUsd,
    required this.sentUsd,
    required this.counted,
    required this.inMonth,
  });

  bool get isReliable => inMonth > 0 && counted * 2 >= inMonth;
}

/// USD in/out for the current calendar month from the loaded wallet history.
/// Returns null when there isn't enough USD-denominated data to show honestly.
MonthMovement? monthMovementFrom(List<WalletTransaction> transactions) {
  final now = DateTime.now();
  var received = 0.0;
  var sent = 0.0;
  var counted = 0;
  var inMonth = 0;

  for (final tx in transactions) {
    DateTime? when;
    try {
      when = DateTime.parse(tx.timestamp).toLocal();
    } catch (_) {
      continue;
    }
    if (when.year != now.year || when.month != now.month) continue;
    inMonth++;

    if (WalletTransactionLabels.isCredit(tx)) {
      final usd = tx.usdCredited;
      final ledger = (tx.ledgerCurrency ?? '').toUpperCase();
      final amount =
          (usd != null && usd > 0)
              ? usd
              : (ledger == 'USD' &&
                      tx.receiveAmount != null &&
                      tx.receiveAmount! > 0
                  ? tx.receiveAmount
                  : null);
      if (amount == null) continue;
      received += amount;
      counted++;
    } else if (WalletTransactionLabels.isDebit(tx)) {
      final usd = WalletTransactionDisplay.outboundTransferAmount(tx);
      if (usd == null || usd <= 0) continue;
      sent += usd;
      counted++;
    }
  }

  final movement = MonthMovement(
    receivedUsd: received,
    sentUsd: sent,
    counted: counted,
    inMonth: inMonth,
  );
  if (!movement.isReliable) return null;
  return movement;
}
