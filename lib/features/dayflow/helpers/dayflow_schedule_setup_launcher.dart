import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/navigation/dayfi_page_transitions.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_automation_currency.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/services/dayflow_api_service.dart';
import 'package:dayfi/features/pay/constants/bill_category_presets.dart';
import 'package:dayfi/features/pay/constants/flutterwave_bill_presets.dart';
import 'package:dayfi/features/pay/models/bill_models.dart';
import 'package:dayfi/features/pay/views/bill_pay_view.dart';
import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/features/recipients/widgets/recipient_picker_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// When a schedule row opens Pay or Send, this ties the result back to DayBudget.
class DayFlowScheduleSetupContext {
  final String flowId;
  final String scheduleId;
  final VoidCallback? onLinked;

  const DayFlowScheduleSetupContext({
    required this.flowId,
    required this.scheduleId,
    this.onLinked,
  });
}

/// Opens Pay bills or Recipients/Send with fields prefilled from a schedule row.
abstract final class DayFlowScheduleSetupLauncher {
  DayFlowScheduleSetupLauncher._();

  static Future<void> open(
    BuildContext context,
    DayBudgetScheduleInstance item, {
    VoidCallback? onUpdated,
  }) async {
    final setup = DayFlowScheduleSetupContext(
      flowId: item.flowId,
      scheduleId: item.scheduleId,
      onLinked: onUpdated,
    );

    if (_isBill(item)) {
      await _openBill(context, item, setup);
      return;
    }

    await _openSend(context, item, setup);
  }

  static bool _isBill(DayBudgetScheduleInstance item) {
    if (item.paymentType == 'bill') return true;
    if (item.paymentType == 'send' || item.paymentType == 'savings') {
      return false;
    }
    final text = '${item.title} ${item.recipientHint ?? ''}'.toLowerCase();
    return text.contains('airtime') ||
        text.contains('data bundle') ||
        text.contains('mobile data') ||
        text.contains('cable') ||
        text.contains('dstv') ||
        text.contains('gotv') ||
        text.contains('electric') ||
        text.contains('utility') ||
        text.contains('internet') ||
        text.contains('wifi') ||
        text.contains('bill pay');
  }

  static BillCategory _billCategory(DayBudgetScheduleInstance item) {
    final text = item.title.toLowerCase();
    if (text.contains('data')) {
      return billCategoryPresets.firstWhere((c) => c.code == 'MOBILEDATA');
    }
    if (text.contains('cable') ||
        text.contains('dstv') ||
        text.contains('gotv') ||
        text.contains('startimes')) {
      return billCategoryPresets.firstWhere((c) => c.code == 'CABLEBILLS');
    }
    if (text.contains('electric') || text.contains('utility')) {
      return billCategoryPresets.firstWhere((c) => c.code == 'UTILITYBILLS');
    }
    if (text.contains('internet') || text.contains('wifi')) {
      return billCategoryPresets.firstWhere((c) => c.code == 'INTSERVICE');
    }
    return billCategoryPresets.firstWhere((c) => c.code == 'AIRTIME');
  }

  static String? _extractPhone(String? hint, String? title) {
    for (final raw in [hint, title]) {
      if (raw == null || raw.trim().isEmpty) continue;
      final compact = raw.replaceAll(RegExp(r'[\s\-()]'), '');
      final local = RegExp(r'0[7-9]\d{9}').firstMatch(compact);
      if (local != null) return local.group(0);
      final intl = RegExp(r'(?:\+?234)([7-9]\d{9})').firstMatch(compact);
      if (intl != null) return '0${intl.group(1)}';
    }
    return null;
  }

  static BillBiller _pickAirtimeBiller(String phone, List<BillBiller> billers) {
    if (billers.isEmpty) {
      throw StateError('No billers for category');
    }
    final prefix = phone.length >= 4 ? phone.substring(0, 4) : phone;
    String network = 'MTN';
    if (prefix.startsWith('0805') ||
        prefix.startsWith('0807') ||
        prefix.startsWith('0705') ||
        prefix.startsWith('0815') ||
        prefix.startsWith('0811') ||
        prefix.startsWith('0905')) {
      network = 'Glo';
    } else if (prefix.startsWith('0802') ||
        prefix.startsWith('0808') ||
        prefix.startsWith('0708') ||
        prefix.startsWith('0812') ||
        prefix.startsWith('0701') ||
        prefix.startsWith('0902') ||
        prefix.startsWith('0907') ||
        prefix.startsWith('0901')) {
      network = 'Airtel';
    } else if (prefix.startsWith('0809') ||
        prefix.startsWith('0817') ||
        prefix.startsWith('0818') ||
        prefix.startsWith('0909') ||
        prefix.startsWith('0908')) {
      network = 'T2mobile';
    }

    for (final biller in billers) {
      if (billerMatchesTelcoNetwork(biller, network)) {
        return biller;
      }
    }
    return billers.first;
  }

  static Future<void> _openBill(
    BuildContext context,
    DayBudgetScheduleInstance item,
    DayFlowScheduleSetupContext setup,
  ) async {
    final category = _billCategory(item);
    final billers = flutterwavePreviewBillersFor(category.code);
    final phone = _extractPhone(item.recipientHint, item.title);
    final biller =
        phone != null &&
                (category.code == 'AIRTIME' || category.code == 'MOBILEDATA')
            ? _pickAirtimeBiller(phone, billers)
            : billers.first;

    await Navigator.push<void>(
      context,
      DayfiPageRoute<void>(
        builder:
            (_) => BillPayView(
              category: category,
              biller: biller,
              usePreviewFlow: true,
              initialCustomerId: phone,
              initialAmount: item.amount > 0 ? item.amount : null,
              dayflowSetup: setup,
            ),
      ),
    );
  }

  static Future<void> _openSend(
    BuildContext context,
    DayBudgetScheduleInstance item,
    DayFlowScheduleSetupContext setup,
  ) async {
    final picked = await showRecipientPickerBottomSheet(context);
    if (picked == null || !context.mounted) return;

    final recipientId = picked.beneficiary.id;
    final label = RecipientHistoryHelper.primaryLabel(
      picked.beneficiary,
      picked.source,
    );
    final channel = RecipientHistoryHelper.recipientChannelLabel(picked);
    final recipientHint =
        channel.isNotEmpty ? '$label · $channel' : label;

    double? sourceAmount;
    if (item.amount > 0 &&
        dayflowAutomationNeedsNgnSource(
          paymentType: 'send',
          recipientHint: recipientHint,
          toCurrency: 'NGN',
        )) {
      sourceAmount = await dayflowNgnAmountForUsd(item.amount);
    }

    try {
      await dayFlowApiService.updateFlowSchedule(
        flowId: setup.flowId,
        scheduleId: setup.scheduleId,
        paymentType: 'send',
        recipientId: recipientId,
        recipientHint: recipientHint,
        sourceAmount: sourceAmount,
        execution: const {'toCurrency': 'NGN'},
      );
      setup.onLinked?.call();
      if (context.mounted) {
        TopSnackbar.show(
          context,
          message: DayFlowCopy.scheduleLinkedToBudget,
        );
      }
    } catch (e) {
      if (context.mounted) {
        TopSnackbar.show(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
      }
    }
  }
}
