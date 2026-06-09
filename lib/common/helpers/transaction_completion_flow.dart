import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/common/widgets/transaction_processing_overlay.dart';
import 'package:dayfi/core/navigation/dayfi_page_transitions.dart';
import 'package:dayfi/common/widgets/transaction_success_view.dart';
import 'package:dayfi/features/pay/constants/pay_copy.dart';
import 'package:flutter/material.dart';

/// After PIN: block UI with overlay, run API, navigate to success.
class TransactionCompletionFlow {
  TransactionCompletionFlow._();

  static Future<T?> runWithOverlay<T>({
    required BuildContext context,
    required Future<T> Function() task,
    bool showErrorSnackbar = true,
  }) async {
    if (!context.mounted) return null;
    TransactionProcessingOverlay.show(context);
    try {
      return await task();
    } catch (e) {
      if (showErrorSnackbar && context.mounted) {
        TopSnackbar.show(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
      }
      return null;
    } finally {
      TransactionProcessingOverlay.hide();
    }
  }

  static Future<void> pushSuccess(
    BuildContext context, {
    required TransactionSuccessView screen,
    bool useRootNavigator = true,
  }) async {
    if (!context.mounted) return;
    final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
    await navigator.pushReplacement(
      DayfiPageRoute<void>(builder: (_) => screen),
    );
  }

  static TransactionSuccessView billSuccess({
    required String billerName,
    required double amount,
    required String reference,
    String? token,
    double? newBalance,
  }) {
    return TransactionSuccessView(
      headline: 'Payment successful',
      title: billerName,
      amountText: '₦${amount.toStringAsFixed(2)}',
      details: [
        if (reference.isNotEmpty)
          TransactionSuccessDetail(label: 'Reference', value: reference),
        if (token != null && token.isNotEmpty)
          TransactionSuccessDetail(label: 'Token', value: token),
        if (newBalance != null)
          TransactionSuccessDetail(
            label: 'Available for bills',
            value: formatPayNgnAmount(newBalance),
          ),
      ],
    );
  }

  static TransactionSuccessView swapSuccess({
    required String fromSymbol,
    required String toSymbol,
    required String fromAmount,
    required String toAmount,
  }) {
    return TransactionSuccessView(
      headline: 'Swap complete',
      title: 'Your wallets have been updated',
      amountText: '$fromSymbol$fromAmount → $toSymbol$toAmount',
    );
  }

  static TransactionSuccessView investLockSuccess({
    required double amount,
    required int lockDays,
    required double apyPercent,
    String? lockName,
  }) {
    final nameSuffix =
        lockName != null && lockName.trim().isNotEmpty ? ' · $lockName' : '';
    return TransactionSuccessView(
      headline: 'Funds locked',
      title: '$lockDays-day lock started$nameSuffix',
      amountText: '\$${amount.toStringAsFixed(2)}',
      subtitle: '${apyPercent.toStringAsFixed(1)}% APY',
    );
  }

  static TransactionSuccessView investClaimSuccess({
    required double amount,
  }) {
    return TransactionSuccessView(
      headline: 'Funds claimed',
      title: 'Returned to your USD wallet',
      amountText: '\$${amount.toStringAsFixed(2)}',
    );
  }
}
