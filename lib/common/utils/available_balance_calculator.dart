import 'package:dayfi/models/wallet_transaction.dart';

/// Utility for wallet balance display and pending-outbound summaries.
///
/// [totalAvailableBalance] from the wallet hub already reflects debits for
/// in-flight outbound payments. The home balance must use that value directly.
/// Pending totals are shown separately for information only.
class AvailableBalanceCalculator {
  /// Pending transaction statuses that should be considered for balance calculation
  /// Only tracking pending-payment (outgoing money) - not pending-collection (incoming money)
  static const List<String> pendingStatuses = ['pending-payment'];

  /// Duration after which a pending payment transaction is considered expired (12 hours)
  static const Duration expiryDuration = Duration(hours: 12);

  /// Calculate the total amount held in pending transactions (amount + fees)
  ///
  /// [transactions] - List of all user transactions
  /// [currency] - The currency to filter by (e.g., 'NGN')
  ///
  /// Returns the total amount that should be subtracted from current balance
  static double calculatePendingAmount(
    List<WalletTransaction> transactions, {
    String? currency,
  }) {
    double totalPending = 0.0;

    for (final transaction in transactions) {
      // Check if transaction is in a pending state
      final status = transaction.status.toLowerCase();

      if (!_isPendingStatus(status)) {
        continue;
      }

      // Only consider outgoing payments (pending-payment)
      // We don't subtract pending-collection as that's money coming IN
      if (!status.contains('payment')) {
        continue;
      }

      // Skip expired transactions - they no longer hold the balance
      if (_isTransactionExpired(transaction)) {
        continue;
      }

      totalPending += _pendingOutboundTotal(transaction);
    }

    return totalPending;
  }

  /// USD (or ledger) total reserved for a pending outbound payment.
  static double _pendingOutboundTotal(WalletTransaction transaction) {
    final fee = transaction.fee ?? 0.0;
    final metaSend = transaction.ledgerMetadata?['sendAmount'];
    if (metaSend is num && metaSend > 0) {
      return metaSend.toDouble() + fee;
    }
    final parsedMeta = double.tryParse('${metaSend ?? ''}');
    if (parsedMeta != null && parsedMeta > 0) {
      return parsedMeta + fee;
    }

    final raw = transaction.sendAmount;
    if (raw != null && raw > 0 && _looksLikeUsdDebit(raw, transaction)) {
      return raw + fee;
    }

    if (raw != null && raw > 0) {
      final receive = transaction.receiveAmount ?? transaction.ngnAmount ?? raw;
      final metaRate = transaction.ledgerMetadata?['rate'];
      if (metaRate is num && metaRate > 50) {
        final usd = receive / metaRate.toDouble();
        if (usd > 0) return usd + fee;
      }
      final fx = transaction.fxNgnToUsd;
      if (fx != null && fx > 0 && receive >= 50) {
        final ngnPerUsd = fx < 1 ? 1 / fx : fx;
        if (ngnPerUsd > 50) return (receive / ngnPerUsd) + fee;
      }
    }

    return (raw ?? 0.0) + fee;
  }

  static bool _looksLikeUsdDebit(double amount, WalletTransaction transaction) {
    if (amount <= 0) return false;
    final local = transaction.receiveAmount ?? transaction.ngnAmount;
    if (local != null && local >= 100) {
      return amount < local * 0.05;
    }
    return amount < 100_000;
  }

  /// Check if a transaction status is considered "pending"
  static bool _isPendingStatus(String status) {
    final lowerStatus = status.toLowerCase();
    return pendingStatuses.any((s) => lowerStatus.contains(s));
  }

  /// Check if a pending payment transaction has expired (been pending for more than 12 hours)
  static bool _isTransactionExpired(WalletTransaction transaction) {
    if (!_isPendingStatus(transaction.status) || !transaction.status.toLowerCase().contains('payment')) {
      return false;
    }

    try {
      // Parse the timestamp
      final transactionTime = DateTime.parse(transaction.timestamp);
      final now = DateTime.now();
      final difference = now.difference(transactionTime);
      
      return difference > expiryDuration;
    } catch (e) {
      // If we can't parse the timestamp, assume it's not expired
      return false;
    }
  }

  /// Parses [currentBalance] from hub `totalAvailableBalance` (already net of debits).
  static double calculateAvailableBalance(
    String currentBalance,
    List<WalletTransaction> transactions, {
    String? currency,
  }) {
    final balance = double.tryParse(currentBalance.replaceAll(',', '')) ?? 0.0;
    return balance > 0 ? balance : 0.0;
  }

  /// Check if a transaction amount would exceed available balance
  ///
  /// [currentBalance] - The wallet's current balance
  /// [transactions] - List of all user transactions
  /// [transactionAmount] - The amount the user wants to send
  /// [transactionFee] - The fee for the transaction
  /// [currency] - Optional currency filter
  ///
  /// Returns true if the transaction would exceed available balance
  static bool wouldExceedAvailableBalance(
    String currentBalance,
    List<WalletTransaction> transactions,
    double transactionAmount,
    double transactionFee, {
    String? currency,
  }) {
    final availableBalance = calculateAvailableBalance(
      currentBalance,
      transactions,
      currency: currency,
    );

    final totalTransactionAmount = transactionAmount + transactionFee;

    return totalTransactionAmount > availableBalance;
  }

  /// Get the number of pending transactions
  static int getPendingTransactionCount(List<WalletTransaction> transactions) {
    return transactions.where((t) {
      final status = t.status.toLowerCase();
      return _isPendingStatus(status) && status.contains('payment') && !_isTransactionExpired(t);
    }).length;
  }

  /// Format balance as a string with 2 decimal places
  static String formatBalance(double balance) {
    return balance.toStringAsFixed(2);
  }

  /// Get the effective status of a transaction (considering expiry for pending payments)
  static String getEffectiveStatus(WalletTransaction transaction) {
    if (_isTransactionExpired(transaction)) {
      return 'expired-payment';
    }
    return transaction.status;
  }
  static List<PendingTransactionInfo> getPendingTransactionsBreakdown(
    List<WalletTransaction> transactions,
  ) {
    final List<PendingTransactionInfo> breakdown = [];

    for (final transaction in transactions) {
      final status = transaction.status.toLowerCase();
      if (_isPendingStatus(status) && status.contains('payment') && !_isTransactionExpired(transaction)) {
        final total = _pendingOutboundTotal(transaction);
        final fee = transaction.fee ?? 0.0;
        breakdown.add(
          PendingTransactionInfo(
            id: transaction.id,
            beneficiaryName: transaction.beneficiary.name,
            amount: (total - fee).clamp(0.0, total),
            fee: fee,
            timestamp: transaction.timestamp,
          ),
        );
      }
    }

    return breakdown;
  }
}

/// Information about a pending transaction for display purposes
class PendingTransactionInfo {
  final String id;
  final String beneficiaryName;
  final double amount;
  final double fee;
  final String timestamp;

  PendingTransactionInfo({
    required this.id,
    required this.beneficiaryName,
    required this.amount,
    required this.fee,
    required this.timestamp,
  });

  double get total => amount + fee;
}
