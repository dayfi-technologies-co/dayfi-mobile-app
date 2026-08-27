import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_draft_details.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_draft_schedules.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_due_date.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';

class DayflowCreateValidation {
  final bool ok;
  final String message;
  final List<String> issues;

  const DayflowCreateValidation({
    required this.ok,
    required this.message,
    this.issues = const [],
  });
}

bool dayflowIsValidRecipientOrBillHint(String hint, String paymentType) {
  final t = hint.trim();
  if (t.isEmpty) return false;
  if (paymentType == 'savings') return true;

  if (paymentType == 'bill') {
    return RegExp(r'\d{6,}').hasMatch(t.replaceAll(RegExp(r'[\s\-]'), '')) ||
        t.contains('@');
  }

  if (RegExp(r'@([a-zA-Z0-9_]{2,})').hasMatch(t)) return true;

  final compact = t.replaceAll(RegExp(r'[\s\-()]'), '');
  if (RegExp(r'0[7-9]\d{9}').hasMatch(compact)) return true;
  if (RegExp(r'\+?234[7-9]\d{9}').hasMatch(compact)) return true;

  if (RegExp(r'\d{10}').hasMatch(compact) &&
      RegExp(
        r'bank|gtb|access|uba|zenith|fcmb|stanbic|wema|fidelity|opay|palmpay|kuda|moniepoint|sterling|union',
        caseSensitive: false,
      ).hasMatch(t)) {
    return true;
  }

  return t.length >= 8;
}

bool dayflowDeliversNonUsd({
  String? toCurrency,
  String? recipientHint,
}) {
  final to = (toCurrency ?? '').trim().toUpperCase();
  if (to.isNotEmpty && to != 'USD') return true;
  final hint = (recipientHint ?? '').toLowerCase();
  return RegExp(
    r'opay|palmpay|naira|ngn|mtn|glo|airtel|9mobile|t2mobile|gtb|access|uba|zenith|bank|nigeria',
    caseSensitive: false,
  ).hasMatch(hint);
}

bool dayflowPaymentHasDualCurrencyAmounts({
  required double usdAmount,
  required String? inputCurrency,
  required double? sourceAmount,
  required String? toCurrency,
  String? recipientHint,
}) {
  if (usdAmount <= 0) return false;
  final spokeNgn = (inputCurrency ?? 'USD').toUpperCase() == 'NGN';
  final deliversNonUsd = dayflowDeliversNonUsd(
    toCurrency: toCurrency,
    recipientHint: recipientHint,
  );
  if (!spokeNgn && !deliversNonUsd) return true;
  return sourceAmount != null && sourceAmount > 0;
}

DayflowCreateValidation validateDraftBeforeCreate(DayFlowPlanDraft draft) {
  final issues = <String>[];
  final inputCurrency = (draft.inputCurrency ?? 'USD').toUpperCase();

  final autopay = collectAutopayDraftItems(draft);
  if (autopay.isEmpty && draft.payments.isEmpty && draft.categories.isEmpty) {
    return const DayflowCreateValidation(
      ok: false,
      message: 'Add at least one payment or category before scheduling.',
    );
  }

  for (final item in autopay) {
    if (!item.autoSend) continue;
    final label = item.title.trim().isEmpty ? 'Payment' : item.title;

    final hint = item.recipientHint ?? '';
    if (!dayflowIsValidRecipientOrBillHint(hint, item.paymentType)) {
      issues.add('$label: ${DayFlowCopy.missingRecipientOrBill}');
    }

    if (item.amount <= 0) {
      issues.add('$label: ${DayFlowCopy.missingUsdAmount}');
    }

    DayFlowPaymentDraft? payment;
    if (!item.fromCategory && item.index >= 0 && item.index < draft.payments.length) {
      payment = draft.payments[item.index];
    }

    final toCurrency = payment?.toCurrency;
    final sourceAmount = payment?.sourceAmount;
    if (!dayflowPaymentHasDualCurrencyAmounts(
      usdAmount: item.amount,
      inputCurrency: inputCurrency,
      sourceAmount: sourceAmount,
      toCurrency: toCurrency,
      recipientHint: hint,
    )) {
      issues.add('$label: ${DayFlowCopy.missingOtherCurrencyAmount}');
    }

    final freq = dayflowFrequencyFromLabel(item.dueLabel ?? draft.periodLabel);
    final nextRunAt = payment?.nextRunAt;
    if (!dayflowHasResolvableSchedule(
      dueLabel: item.dueLabel ?? draft.periodLabel,
      nextRunAt: nextRunAt,
      frequency: freq,
    )) {
      issues.add('$label: ${DayFlowCopy.missingScheduleTime}');
    } else {
      final resolved = dayflowResolveNextRunAtIso(
        dueLabel: item.dueLabel ?? draft.periodLabel,
        nextRunAt: nextRunAt,
        frequency: freq,
      );
      if (freq == 'once' && resolved == null) {
        issues.add('$label: ${DayFlowCopy.missingScheduleTime}');
      }
    }
  }

  if (issues.isEmpty) {
    return const DayflowCreateValidation(ok: true, message: '');
  }
  return DayflowCreateValidation(
    ok: false,
    message: issues.first,
    issues: issues,
  );
}

bool dayflowDraftReadyToCreate(DayFlowPlanDraft draft) {
  return validateDraftBeforeCreate(draft).ok;
}
