import 'dart:async';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/navigation/navigator_key.dart';
import 'package:dayfi/features/main/views/main_view.dart';
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

  /// Keeps [MainView] under the success screen so returning is a fast pop.
  static bool keepMainViewRoute(Route<dynamic> route) =>
      route.settings.name == AppRoute.mainView;

  static Future<T?> navigateToPaymentSuccess<T extends Object?>(
    Object arguments,
  ) {
    return appRouter.pushNamedAndRemoveUntil<T>(
      AppRoute.sendPaymentSuccessView,
      keepMainViewRoute,
      arguments: arguments,
    );
  }

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

  static WalletTransaction? findInProvider(WidgetRef ref, String? transactionId) {
    final id = transactionId?.trim();
    if (id == null || id.isEmpty) return null;
    return findTransaction(ref.read(transactionsProvider).transactions, id);
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

    final inMemory = findInProvider(ref, transactionId);
    if (inMemory != null) return inMemory;

    try {
      await ref.read(transactionsProvider.notifier).loadTransactions();
      final match = findInProvider(ref, transactionId);
      if (match != null) return match;
      AppLogger.error('Transaction not found: $transactionId');
    } catch (e) {
      AppLogger.error('Failed to resolve transaction: $e');
    }
    return null;
  }

  static void _refreshRecipients(WidgetRef ref) {
    unawaited(ref.read(recipientsProvider.notifier).loadBeneficiaries());
  }

  static void _selectTransactionsTab() {
    mainViewKey.currentState?.changeTab(transactionsTabIndex);
  }

  /// Pops back to Main (fast) or rebuilds Main when needed, then opens details.
  static Future<void> openTransactionDetailsOrList({
    required WidgetRef ref,
    String? transactionId,
    WalletTransaction? prefetchedTransaction,
  }) async {
    final id = transactionId?.trim();
    var transaction =
        prefetchedTransaction ?? (id != null ? findInProvider(ref, id) : null);

    final navigator = NavigatorKey.appNavigatorKey.currentState;
    if (navigator == null) return;

    if (navigator.canPop()) {
      navigator.pop();
      _selectTransactionsTab();
    } else {
      await appRouter.pushNamedAndRemoveUntil(
        AppRoute.mainView,
        (Route route) => false,
        arguments: transactionsTabIndex,
      );
      _selectTransactionsTab();
    }

    _refreshRecipients(ref);

    if (transaction != null) {
      unawaited(
        appRouter.pushNamed(
          AppRoute.transactionDetailsView,
          arguments: transaction,
        ),
      );
      return;
    }

    if (id == null || id.isEmpty) return;

    unawaited(
      resolveTransaction(ref: ref, transactionId: id).then((resolved) {
        if (resolved != null) {
          appRouter.pushNamed(
            AppRoute.transactionDetailsView,
            arguments: resolved,
          );
          return;
        }

        final navContext = NavigatorKey.appNavigatorKey.currentContext;
        if (navContext != null) {
          TopSnackbar.show(
            navContext,
            message:
                'Transaction details aren\'t ready yet. Check your transactions list.',
          );
        }
      }),
    );
  }
}
