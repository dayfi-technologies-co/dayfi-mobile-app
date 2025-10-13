import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/app_locator.dart';

class TransactionMonitorService {
  final PaymentService _paymentService;
  final WalletService _walletService;
  Timer? _monitoringTimer;
  final Map<String, Map<String, dynamic>> _pendingTransactions = {};

  TransactionMonitorService(this._paymentService, this._walletService);

  /// Start monitoring pending transactions
  void startMonitoring() {
    print('🔄 Starting transaction monitoring...');

    // Check every 30 seconds
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) => _checkPendingTransactions(),
    );

    // Also check immediately
    _checkPendingTransactions();
  }

  /// Stop monitoring
  void stopMonitoring() {
    print('⏹️ Stopping transaction monitoring...');
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  /// Add a transaction to monitoring
  void addTransactionToMonitoring({
    required String transactionId,
    required String collectionSequenceId,
    required Map<String, dynamic> paymentData,
  }) {
    _pendingTransactions[transactionId] = {
      'collectionSequenceId': collectionSequenceId,
      'paymentData': paymentData,
      'lastChecked': DateTime.now(),
      'retryCount': 0,
    };

    print('📝 Added transaction $transactionId to monitoring');
  }

  /// Remove a transaction from monitoring
  void removeTransactionFromMonitoring(String transactionId) {
    _pendingTransactions.remove(transactionId);
    print('🗑️ Removed transaction $transactionId from monitoring');
  }

  /// Check all pending transactions
  Future<void> _checkPendingTransactions() async {
    if (_pendingTransactions.isEmpty) return;

    print('🔍 Checking ${_pendingTransactions.length} pending transactions...');

    for (final entry in _pendingTransactions.entries) {
      final transactionId = entry.key;
      final data = entry.value;

      try {
        await _checkTransactionStatus(transactionId, data);
      } catch (e) {
        print('❌ Error checking transaction $transactionId: $e');
      }
    }
  }

  /// Check individual transaction status
  Future<void> _checkTransactionStatus(
    String transactionId,
    Map<String, dynamic> data,
  ) async {
    final collectionSequenceId = data['collectionSequenceId'] as String;
    final retryCount = data['retryCount'] as int;

    // Skip if we've retried too many times
    if (retryCount >= 20) {
      // 20 * 30 seconds = 10 minutes
      print(
        '⏰ Transaction $transactionId exceeded retry limit, removing from monitoring',
      );
      removeTransactionFromMonitoring(transactionId);
      return;
    }

    try {
      // Check collection status
      final status = await _paymentService.checkCollectionStatus(
        collectionSequenceId,
      );

      print('📊 Transaction $transactionId status: $status');

      // Update retry count
      data['retryCount'] = retryCount + 1;
      data['lastChecked'] = DateTime.now();

      if (status == 'success-collection') {
        print(
          '✅ Transaction $transactionId reached success-collection, creating payment...',
        );
        await _createPaymentForTransaction(transactionId, data);
        removeTransactionFromMonitoring(transactionId);
      } else if (status == 'failed' || status == 'failed-collection') {
        print('❌ Transaction $transactionId failed with status: $status');
        removeTransactionFromMonitoring(transactionId);
      } else if (status == 'unknown') {
        print('⚠️ Transaction $transactionId status unknown, will retry...');
      } else {
        print(
          '⏳ Transaction $transactionId still pending with status: $status',
        );
      }
    } catch (e) {
      print('❌ Error checking status for transaction $transactionId: $e');
      data['retryCount'] = retryCount + 1;
    }
  }

  /// Create payment for a transaction that reached success-collection
  Future<void> _createPaymentForTransaction(
    String transactionId,
    Map<String, dynamic> data,
  ) async {
    try {
      final paymentData = data['paymentData'] as Map<String, dynamic>;
      final collectionSequenceId = data['collectionSequenceId'] as String;

      // Add collection sequence ID to payment data
      paymentData['collectionSequenceId'] = collectionSequenceId;

      print('💳 Creating payment for transaction $transactionId...');
      final paymentResponse = await _paymentService.createPayment(paymentData);

      if (paymentResponse.error) {
        print(
          '❌ Payment creation failed for transaction $transactionId: ${paymentResponse.message}',
        );
      } else {
        print('✅ Payment created successfully for transaction $transactionId');

        // Refresh transactions to show updated status
        await _refreshTransactions();
      }
    } catch (e) {
      print('❌ Error creating payment for transaction $transactionId: $e');
    }
  }

  /// Refresh transactions list
  Future<void> _refreshTransactions() async {
    try {
      // This would typically trigger a refresh in the transactions view
      // For now, we'll just log it
      print('🔄 Refreshing transactions list...');

      // TODO: Implement proper refresh mechanism
      // This could use a callback or event system to notify the UI
    } catch (e) {
      print('❌ Error refreshing transactions: $e');
    }
  }

  /// Get pending transactions count
  int get pendingTransactionsCount => _pendingTransactions.length;

  /// Get pending transactions
  Map<String, Map<String, dynamic>> get pendingTransactions =>
      Map.from(_pendingTransactions);
}

// Provider for the transaction monitor service
final transactionMonitorProvider = Provider<TransactionMonitorService>((ref) {
  return TransactionMonitorService(
    locator<PaymentService>(),
    locator<WalletService>(),
  );
});
