import 'package:dayfi/features/dayflow/helpers/dayflow_draft_details.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_due_date.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';

String dayflowPaymentTypeForTitle(String title) {
  final lower = title.toLowerCase();
  if (lower.contains('electric') ||
      lower.contains('data') ||
      lower.contains('airtime') ||
      lower.contains('dstv') ||
      lower.contains('gotv') ||
      lower.contains('bill')) {
    return 'bill';
  }
  if (lower.contains('saving') || lower.contains('emergency')) {
    return 'savings';
  }
  return 'send';
}

String dayflowFrequencyFromLabel(String? label) {
  final lower = (label ?? '').toLowerCase();
  if (lower.contains('every week') ||
      lower.contains('each week') ||
      lower.contains('weekly') ||
      lower.contains('per week')) {
    return 'weekly';
  }
  if (lower.contains('two week') ||
      lower.contains('biweekly') ||
      lower.contains('bi-weekly') ||
      lower.contains('every 2 week')) {
    return 'biweekly';
  }
  if (lower.contains('every day') || lower.contains('daily')) {
    return 'daily';
  }
  if (lower.contains('once')) return 'once';
  return 'monthly';
}

String dayflowScheduleFrequency(DayFlowPlanDraft draft) {
  final t = draft.budgetType.toLowerCase().trim();
  if (t == 'weekly' ||
      t == 'biweekly' ||
      t == 'once' ||
      t == 'daily') {
    return t;
  }

  final fromPeriod = dayflowFrequencyFromLabel(draft.periodLabel);
  if (fromPeriod != 'monthly') return fromPeriod;

  for (final p in draft.payments) {
    final fromPayment = dayflowFrequencyFromLabel(p.dueLabel);
    if (fromPayment != 'monthly') return fromPayment;
  }

  return 'monthly';
}

String dayflowScheduleDueLabel(DayFlowPlanDraft draft) {
  final label = draft.periodLabel.trim();
  if (label.isNotEmpty && label.toLowerCase() != 'this month') {
    return label;
  }
  switch (dayflowScheduleFrequency(draft)) {
    case 'weekly':
      return 'Every week';
    case 'biweekly':
      return 'Every two weeks';
    default:
      return 'Every month';
  }
}

String dayflowScheduleTitle({
  required String categoryName,
  DayFlowPlanDraft? draft,
  DayFlowPaymentDraft? payment,
}) {
  if (payment != null && payment.title.trim().isNotEmpty) {
    return payment.title.trim();
  }
  final name = categoryName.trim();
  final lower = name.toLowerCase();
  if (lower.contains('airtime') || lower.contains('data')) {
    final hint = draft?.payments
        .map((p) => p.recipientHint)
        .whereType<String>()
        .where((h) => h.trim().isNotEmpty)
        .firstOrNull;
    if (hint != null) {
      return 'Airtime to $hint';
    }
    return name;
  }
  return name;
}

/// Flow API schedule rows — uses explicit payments, else one row per category.
List<Map<String, dynamic>> dayflowSchedulesPayloadFromDraft(
  DayFlowPlanDraft draft,
) {
  final frequency = dayflowScheduleFrequency(draft);
  final dueLabel = dayflowScheduleDueLabel(draft);

  if (draft.payments.isNotEmpty) {
    return draft.payments.map((p) {
      final title = dayflowScheduleTitle(
        categoryName: p.title,
        payment: p,
        draft: draft,
      );
      final paymentDue = p.dueLabel ?? dueLabel;
      final paymentFreq = dayflowFrequencyFromLabel(paymentDue);
      final resolvedNextRun = dayflowResolveNextRunAtIso(
        dueLabel: paymentDue,
        nextRunAt: p.nextRunAt,
        frequency: paymentFreq != 'monthly' ? paymentFreq : frequency,
      );
      final toCurrency = p.toCurrency?.trim().toUpperCase();
      return {
        'title': title,
        'amount': p.amount,
        if (p.sourceAmount != null && p.sourceAmount! > 0)
          'sourceAmount': p.sourceAmount,
        if (paymentDue.isNotEmpty) 'dueLabel': paymentDue,
        if (resolvedNextRun != null) 'nextRunAt': resolvedNextRun,
        if (p.recipientHint != null && p.recipientHint!.trim().isNotEmpty)
          'recipientHint': p.recipientHint!.trim(),
        'autoPay': p.autoSend,
        'paymentType': dayflowPaymentTypeForTitle(p.title),
        'frequency': paymentFreq != 'monthly' ? paymentFreq : frequency,
        if (toCurrency != null && toCurrency.isNotEmpty)
          'execution': {'toCurrency': toCurrency},
      };
    }).toList();
  }

  return draft.categories
      .where((c) => dayflowCategoryNeedsAutopaySchedule(c.name))
      .map((c) {
    return {
      'title': dayflowScheduleTitle(categoryName: c.name, draft: draft),
      'amount': c.allocated,
      'dueLabel': dueLabel,
      'autoPay': true,
      'paymentType': dayflowPaymentTypeForTitle(c.name),
      'frequency': frequency,
    };
  }).toList();
}

List<DayFlowUpcomingPayment> dayflowUpcomingFromDraft(DayFlowPlanDraft draft) {
  final dueLabel = dayflowScheduleDueLabel(draft);
  if (draft.payments.isNotEmpty) {
    return draft.payments
        .map(
          (p) => DayFlowUpcomingPayment(
            title: dayflowScheduleTitle(categoryName: p.title, payment: p, draft: draft),
            amount: p.amount,
            currency: draft.currency,
            dueLabel: p.dueLabel ?? dueLabel,
            recipientHint: p.recipientHint,
            autoSend: p.autoSend,
          ),
        )
        .toList();
  }
  return draft.categories
      .map(
        (c) => DayFlowUpcomingPayment(
          title: dayflowScheduleTitle(categoryName: c.name, draft: draft),
          amount: c.allocated,
          currency: draft.currency,
          dueLabel: dueLabel,
          autoSend: true,
        ),
      )
      .toList();
}

/// Merge collected autopay hints into a draft ready for flow creation.
DayFlowPlanDraft dayflowDraftWithAutopayDetails(
  DayFlowPlanDraft draft,
  Map<int, String> hintsByAutopayIndex,
) {
  if (draft.payments.isNotEmpty) {
    final payments = List<DayFlowPaymentDraft>.of(draft.payments);
    for (final entry in hintsByAutopayIndex.entries) {
      if (entry.key < 0 || entry.key >= payments.length) continue;
      payments[entry.key] = payments[entry.key].copyWith(
        recipientHint: entry.value,
        autoSend: true,
      );
    }
    return draft.copyWith(payments: payments);
  }

  final autopayCategories =
      draft.categories
          .where((c) => dayflowCategoryNeedsAutopaySchedule(c.name))
          .toList();
  final payments = <DayFlowPaymentDraft>[];
  for (var i = 0; i < autopayCategories.length; i++) {
    final c = autopayCategories[i];
    payments.add(
      DayFlowPaymentDraft(
        title: c.name,
        amount: c.allocated,
        recipientHint: hintsByAutopayIndex[i],
        autoSend: true,
      ),
    );
  }
  return draft.copyWith(payments: payments);
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
