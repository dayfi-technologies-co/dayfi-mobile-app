import 'package:dayfi/features/dayflow/helpers/dayflow_draft_schedules.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_draft_validation.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';

/// One row that may need a recipient or bill detail before the budget goes live.
class DayFlowAutopayDraftItem {
  final int index;
  final String title;
  final double amount;
  final String? dueLabel;
  final String? recipientHint;
  final bool autoSend;
  final String paymentType;
  final bool fromCategory;

  const DayFlowAutopayDraftItem({
    required this.index,
    required this.title,
    required this.amount,
    this.dueLabel,
    this.recipientHint,
    this.autoSend = true,
    required this.paymentType,
    this.fromCategory = false,
  });

  bool get needsDetail {
    if (!autoSend) return false;
    if (paymentType == 'savings') return false;
    return !dayflowIsValidRecipientOrBillHint(
      recipientHint ?? '',
      paymentType,
    );
  }

  DayFlowAutopayDraftItem copyWith({String? recipientHint, bool? autoSend}) {
    return DayFlowAutopayDraftItem(
      index: index,
      title: title,
      amount: amount,
      dueLabel: dueLabel,
      recipientHint: recipientHint ?? this.recipientHint,
      autoSend: autoSend ?? this.autoSend,
      paymentType: paymentType,
      fromCategory: fromCategory,
    );
  }
}

bool dayflowCategoryNeedsAutopaySchedule(String name) {
  final t = name.toLowerCase();
  if (t.contains('airtime') ||
      t.contains('data') ||
      t.contains('electric') ||
      t.contains('utility') ||
      t.contains('cable') ||
      t.contains('dstv') ||
      t.contains('gotv') ||
      t.contains('internet') ||
      t.contains('bill')) {
    return true;
  }
  if (t.contains('family') ||
      t.contains('support') ||
      t.contains('allowance') ||
      t.contains('mom') ||
      t.contains('dad') ||
      t.contains('rent')) {
    return true;
  }
  if (t.contains('saving') || t.contains('emergency')) return true;
  return false;
}

List<DayFlowAutopayDraftItem> collectAutopayDraftItems(DayFlowPlanDraft draft) {
  if (draft.payments.isNotEmpty) {
    return List.generate(draft.payments.length, (i) {
      final p = draft.payments[i];
      return DayFlowAutopayDraftItem(
        index: i,
        title: p.title,
        amount: p.amount,
        dueLabel: p.dueLabel,
        recipientHint: p.recipientHint,
        autoSend: p.autoSend,
        paymentType: dayflowPaymentTypeForTitle(p.title),
        fromCategory: false,
      );
    });
  }

  final items = <DayFlowAutopayDraftItem>[];
  for (var i = 0; i < draft.categories.length; i++) {
    final c = draft.categories[i];
    if (!dayflowCategoryNeedsAutopaySchedule(c.name)) continue;
    items.add(
      DayFlowAutopayDraftItem(
        index: i,
        title: c.name,
        amount: c.allocated,
        autoSend: true,
        paymentType: dayflowPaymentTypeForTitle(c.name),
        fromCategory: true,
      ),
    );
  }
  return items;
}

bool dayflowDraftAutopayComplete(DayFlowPlanDraft draft) {
  return collectAutopayDraftItems(draft).every((item) => !item.needsDetail);
}

bool dayflowDraftAutopayCompleteForCreate(DayFlowPlanDraft draft) {
  return dayflowDraftReadyToCreate(draft);
}

String dayflowDetailHintLabel(String paymentType) {
  switch (paymentType) {
    case 'bill':
      return 'Bill details (phone & network, or meter & DISCO)';
    case 'savings':
      return 'Savings target';
    default:
      return 'Recipient (@username, phone, Opay, or bank name)';
  }
}

String dayflowDetailHintPlaceholder(String paymentType, String title) {
  final t = title.toLowerCase();
  if (paymentType == 'bill') {
    if (t.contains('electric') || t.contains('utility')) {
      return 'e.g. 1234567890 IKEDC';
    }
    if (t.contains('data') || t.contains('airtime')) {
      return 'e.g. 08131208415 MTN';
    }
    if (t.contains('cable') || t.contains('dstv')) {
      return 'e.g. 1234567890 DSTV';
    }
    return 'e.g. customer ID & provider';
  }
  return 'e.g. @freddy001 or 9072672767 Opay';
}

String formatAutopayDetailLine({
  required String title,
  required double amount,
  String? recipientHint,
}) {
  final hint = recipientHint?.trim();
  if (hint != null && hint.isNotEmpty) return hint;
  return title;
}
