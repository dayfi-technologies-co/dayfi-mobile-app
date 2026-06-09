import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/helpers/transaction_pin_flow.dart';
import 'package:dayfi/common/utils/api_error_message.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/common/widgets/transaction_success_view.dart';
import 'package:dayfi/features/dayx/services/dayx_flow_execute_result.dart';
import 'package:dayfi/features/dayx/services/dayx_flow_pin_retry.dart';
import 'package:dayfi/features/dayx/widgets/dayx_inline_success.dart';
import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';
import 'package:dayfi/common/services/feature_activity_service.dart';
import 'package:dayfi/services/remote/bills_service.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Runs flow `execute` payloads after the user enters their transaction PIN.
class DayxFlowExecutor {
  DayxFlowExecutor._();

  static Future<DayxFlowExecuteResult> run({
    required BuildContext context,
    required WidgetRef ref,
    required Map<String, dynamic> execute,
  }) async {
    final type = execute['type']?.toString() ?? '';
    final inlinePin = execute['pin']?.toString();
    try {
      switch (type) {
        case 'ngn_bank':
          return await _runNgnBank(
            context,
            ref,
            execute,
            inlinePin: inlinePin,
          );
        case 'dayfi_tag':
          return await _runDayfiTag(
            context,
            ref,
            execute,
            inlinePin: inlinePin,
          );
        case 'swap':
          TopSnackbar.showSafe(
            context,
            message:
                'Currency swap is no longer needed — you have one global balance. Pick a pay-with currency when you send.',
          );
          return DayxFlowExecuteResult.failure('Swap is not available');
        case 'pay_bill':
          return await _runPayBill(
            context,
            ref,
            execute,
            inlinePin: inlinePin,
          );
        default:
          TopSnackbar.showSafe(
            context,
            message: 'This flow step is not supported yet.',
            isError: true,
          );
          return DayxFlowExecuteResult.failure(
            'This flow step is not supported yet.',
          );
      }
    } catch (e) {
      return _failureFromError(context, e, fallback: 'Transaction failed');
    }
  }

  static DayxFlowExecuteResult _failureFromError(
    BuildContext context,
    Object error, {
    required String fallback,
  }) {
    final message = messageFromApiError(error, fallback: fallback);
    final invalidPin = DayxFlowPinRetry.isInvalidPinError(message);
    if (context.mounted && !invalidPin) {
      TopSnackbar.showSafe(context, message: message, isError: true);
    }
    return DayxFlowExecuteResult.failure(message, invalidPin: invalidPin);
  }

  static Future<DayxFlowExecuteResult> _runNgnBank(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> execute, {
    String? inlinePin,
  }) async {
    final amount = (execute['amount'] as num?)?.toDouble() ?? 0;
    final fee = (execute['fee'] as num?)?.toDouble() ?? 0;

    Future<bool> task(String pin) async {
      final paymentService = locator<PaymentService>();
      final response = await paymentService.bankTransfer(
        amount: amount,
        accountNumber: execute['accountNumber']?.toString() ?? '',
        bankCode: execute['bankCode']?.toString() ?? '',
        bankName: execute['bankName']?.toString() ?? 'Bank',
        accountName: execute['accountName']?.toString() ?? 'Recipient',
        fee: fee,
        pin: pin,
        spendCurrency:
            execute['spendCurrency']?.toString().toUpperCase() ?? 'NGN',
      );
      if (response.error == true) {
        throw Exception(
          response.message.isNotEmpty
              ? response.message
              : 'Bank transfer failed',
        );
      }
      await ref.read(walletHubProvider.notifier).refresh();
      FeatureActivityService.instance.invalidate();
      return true;
    }

    final bool? result;
    if (inlinePin != null && inlinePin.length >= 4) {
      try {
        result = await task(inlinePin);
      } catch (e) {
        return _failureFromError(context, e, fallback: 'Bank transfer failed');
      }
    } else {
      result = await TransactionPinFlow.requestPinAndRun<bool>(
        context: context,
        ref: ref,
        task: task,
      );
    }

    if (result != true || !context.mounted) {
      return DayxFlowExecuteResult.failure('Transaction cancelled');
    }

    return DayxFlowExecuteResult.ok(
      receipt: DayxInlineSuccess(
        headline: 'Transfer sent',
        title: execute['accountName']?.toString() ?? 'Recipient',
        amountText: 'NGN ${amount.toStringAsFixed(0)}',
        subtitle: execute['bankName']?.toString(),
      ),
    );
  }

  static Future<DayxFlowExecuteResult> _runDayfiTag(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> execute, {
    String? inlinePin,
  }) async {
    final amount = (execute['amount'] as num?)?.toInt() ?? 0;
    final tag = execute['dayfiId']?.toString() ?? '';
    final debit =
        execute['debitCurrency']?.toString().toUpperCase() ?? 'USD';

    Future<bool> task(String pin) async {
      final paymentService = locator<PaymentService>();
      final response = await paymentService.initiateWalletTransfer(
        dayfiId: tag,
        amount: amount,
        encryptedPin: pin,
        debitCurrency: debit,
      );
      if (response.error == true) {
        throw Exception(
          response.message.isNotEmpty ? response.message : 'Transfer failed',
        );
      }
      await ref.read(walletHubProvider.notifier).refresh();
      FeatureActivityService.instance.invalidate();
      return true;
    }

    final bool? result;
    if (inlinePin != null && inlinePin.length >= 4) {
      try {
        result = await task(inlinePin);
      } catch (e) {
        return _failureFromError(context, e, fallback: 'Transfer failed');
      }
    } else {
      result = await TransactionPinFlow.requestPinAndRun<bool>(
        context: context,
        ref: ref,
        task: task,
      );
    }

    if (result != true || !context.mounted) {
      return DayxFlowExecuteResult.failure('Transaction cancelled');
    }

    return DayxFlowExecuteResult.ok(
      receipt: DayxInlineSuccess(
        headline: 'Transfer sent',
        title: '@$tag',
        amountText: '$debit $amount',
      ),
    );
  }

  static Future<DayxFlowExecuteResult> _runPayBill(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> execute, {
    String? inlinePin,
  }) async {
    final amount = (execute['amount'] as num?)?.toDouble() ?? 0;
    final billsService = locator<BillsService>();

    Future<Map<String, dynamic>> task(String pin) async {
      final payResult = await billsService.payBill(
        categoryCode: execute['categoryCode']?.toString() ?? '',
        billerCode: execute['billerCode']?.toString() ?? '',
        itemCode: execute['itemCode']?.toString() ?? '',
        customerId: execute['customerId']?.toString() ?? '',
        amount: amount,
        pin: pin,
        billerName: execute['billerName']?.toString(),
        itemName: execute['itemName']?.toString(),
      );
      await ref.read(walletHubProvider.notifier).refresh();
      FeatureActivityService.instance.invalidate();
      return payResult;
    }

    Map<String, dynamic>? result;
    if (inlinePin != null && inlinePin.length >= 4) {
      try {
        result = await task(inlinePin);
      } catch (e) {
        return _failureFromError(context, e, fallback: 'Bill payment failed');
      }
    } else {
      result = await TransactionPinFlow.requestPinAndRun<Map<String, dynamic>>(
        context: context,
        ref: ref,
        task: task,
      );
    }

    if (result == null || !context.mounted) {
      return DayxFlowExecuteResult.failure('Transaction cancelled');
    }

    final reference = result['reference']?.toString() ?? '';
    final token = result['rechargeToken']?.toString();
    final details = <TransactionSuccessDetail>[
      if (reference.isNotEmpty)
        TransactionSuccessDetail(label: 'Reference', value: reference),
      if (token != null && token.isNotEmpty)
        TransactionSuccessDetail(label: 'Token', value: token),
    ];

    return DayxFlowExecuteResult.ok(
      receipt: DayxInlineSuccess(
        headline: 'Payment successful',
        title: execute['billerName']?.toString() ?? 'Bill',
        amountText: '₦${amount.toStringAsFixed(2)}',
        details: details,
      ),
    );
  }
}
