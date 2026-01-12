import 'package:dayfi/models/wallet_transaction.dart';

/// Utility class for calculating available balance by accounting for pending transactions.
///
/// This prevents users from initiating multiple transactions that would exceed
/// their actual available balance while other transactions are still processing.
///
/// Formula: Available Balance = Current Balance - Σ(Pending Transactions Amount + Fees)
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

    // DEBUG: Log all transaction statuses
    print(
      '🔍 [AvailableBalanceCalculator] Total transactions: ${transactions.length}',
    );
    for (final transaction in transactions) {
      print(
        '   📋 TX: ${transaction.id.substring(0, 8)}... | status: "${transaction.status}" | sendAmount: ${transaction.sendAmount} | fee: ${transaction.fee}',
      );
    }

    for (final transaction in transactions) {
      // Check if transaction is in a pending state
      final status = transaction.status.toLowerCase();

      print(
        '   🔎 Checking status: "$status" | isPending: ${_isPendingStatus(status)} | containsPayment: ${status.contains('payment')}',
      );

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
        print(
          '   ⏰ EXPIRED TX SKIPPED: ${transaction.id.substring(0, 8)}... (pending >12 hours)',
        );
        continue;
      }

      // Add send amount + fee for this pending transaction
      final sendAmount = transaction.sendAmount ?? 0.0;
      final fee = transaction.fee ?? 0.0;
      totalPending += sendAmount + fee;

      print(
        '   ✅ PENDING TX FOUND: sendAmount=$sendAmount, fee=$fee, runningTotal=$totalPending',
      );
    }

    print('🔍 [AvailableBalanceCalculator] Final pending total: $totalPending');
    return totalPending;
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

  /// Calculate available balance by subtracting pending amounts from current balance
  ///
  /// [currentBalance] - The wallet's current balance (as string, may contain commas)
  /// [transactions] - List of all user transactions
  /// [currency] - Optional currency filter
  ///
  /// Returns the available balance as a double
  static double calculateAvailableBalance(
    String currentBalance,
    List<WalletTransaction> transactions, {
    String? currency,
  }) {
    // Parse current balance (remove commas if present)
    final balance = double.tryParse(currentBalance.replaceAll(',', '')) ?? 0.0;

    // Calculate total pending amount
    final pendingAmount = calculatePendingAmount(
      transactions,
      currency: currency,
    );

    // Available balance = current balance - pending amounts
    final availableBalance = balance - pendingAmount;

    // Ensure we don't return negative balance
    return availableBalance > 0 ? availableBalance : 0.0;
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
        breakdown.add(
          PendingTransactionInfo(
            id: transaction.id,
            beneficiaryName: transaction.beneficiary.name,
            amount: transaction.sendAmount ?? 0.0,
            fee: transaction.fee ?? 0.0,
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
