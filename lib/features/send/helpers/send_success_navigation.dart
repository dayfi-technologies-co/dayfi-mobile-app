import 'dart:async';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/navigation/navigator_key.dart';
import 'package:dayfi/features/recipients/vm/recipients_viewmodel.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// After a send succeeds: land on Transactions tab, optionally open details.
class SendSuccessNavigation {
  SendSuccessNavigation._();

  static const transactionsTabIndex = 1;

  static WalletTransaction? findTransaction(
    List<WalletTransaction> transactions,
    String transactionId,
  ) {
    final normalized = transactionId.trim();
    if (normalized.isEmpty) return null;

    for (final txn in transactions) {
      if (_matchesId(txn, normalized)) return txn;
    }
    return null;
  }

  static bool _matchesId(WalletTransaction txn, String id) {
    if (txn.id == id) return true;

    final external = txn.externalReference?.trim();
    if (external != null && external.isNotEmpty && external == id) {
      return true;
    }

    final sourceId = txn.source.id?.trim();
    if (sourceId != null && sourceId.isNotEmpty && sourceId == id) return true;

    final meta = txn.ledgerMetadata;
    if (meta == null) return false;

    for (final key in [
      'sequenceId',
      'paymentSequenceId',
      'collectionId',
      'paymentId',
      'id',
    ]) {
      final value = meta[key]?.toString().trim();
      if (value != null && value.isNotEmpty && value == id) return true;
    }
    return false;
  }

  static Future<WalletTransaction?> resolveTransaction({
    required WidgetRef ref,
    required String transactionId,
    WalletTransaction? cached,
  }) async {
    if (cached != null) return cached;

    try {
      await ref.read(transactionsProvider.notifier).loadTransactions();
      final transactions = ref.read(transactionsProvider).transactions;
      final match = findTransaction(transactions, transactionId);
      if (match != null) return match;
      AppLogger.error('Transaction not found: $transactionId');
    } catch (e) {
      AppLogger.error('Failed to resolve transaction: $e');
    }
    return null;
  }

  static void _refreshRelatedData(WidgetRef ref) {
    unawaited(ref.read(transactionsProvider.notifier).loadTransactions());
    unawaited(ref.read(recipientsProvider.notifier).loadBeneficiaries());
  }

  /// Clears the send stack to Main → Transactions, then opens details when found.
  static Future<void> openTransactionDetailsOrList({
    required WidgetRef ref,
    String? transactionId,
    WalletTransaction? prefetchedTransaction,
  }) async {
    WalletTransaction? transaction = prefetchedTransaction;
    final id = transactionId?.trim();

    if (transaction == null && id != null && id.isNotEmpty) {
      transaction = await resolveTransaction(ref: ref, transactionId: id);
    } else {
      _refreshRelatedData(ref);
    }

    await appRouter.pushNamedAndRemoveUntil(
      AppRoute.mainView,
      (Route route) => false,
      arguments: transactionsTabIndex,
    );

    if (transaction != null) {
      await appRouter.pushNamed(
        AppRoute.transactionDetailsView,
        arguments: transaction,
      );
      return;
    }

    if (id != null && id.isNotEmpty) {
      final navContext = NavigatorKey.appNavigatorKey.currentContext;
      if (navContext != null) {
        TopSnackbar.show(
          navContext,
          message:
              'Transaction details aren\'t ready yet. Check your transactions list.',
        );
      }
    }
  }
}
