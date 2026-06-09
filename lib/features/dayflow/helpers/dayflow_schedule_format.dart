import 'package:dayfi/features/dayflow/helpers/dayflow_draft_details.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_draft_schedules.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';

/// Display model for the DayBudget automation list.
class DayBudgetAutomationItem {
  final String id;
  final String title;
  final double amount;
  final String scheduleText;
  final bool autoPay;
  final String? recipientHint;
  final String paymentType;

  const DayBudgetAutomationItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.scheduleText,
    this.autoPay = false,
    this.recipientHint,
    this.paymentType = 'send',
  });

  bool get needsSetup {
    if (!autoPay) return false;
    if (paymentType == 'savings') return false;
    return (recipientHint ?? '').trim().isEmpty;
  }

  factory DayBudgetAutomationItem.fromSchedule(DayFlowEnvelopeSchedule s) {
    return DayBudgetAutomationItem(
      id: s.id.isNotEmpty ? s.id : '${s.title}-${s.amount}',
      title: s.title,
      amount: s.amount,
      scheduleText: formatDayBudgetSchedule(
        dueLabel: s.dueLabel,
        frequency: s.frequency,
        paymentType: s.paymentType,
        title: s.title,
      ),
      autoPay: s.autoPay,
      recipientHint: s.recipientHint,
      paymentType: s.paymentType,
    );
  }

  factory DayBudgetAutomationItem.fromUpcoming(DayFlowUpcomingPayment u, int index) {
    return DayBudgetAutomationItem(
      id: 'upcoming-$index',
      title: u.title,
      amount: u.amount,
      scheduleText: formatDayBudgetSchedule(
        dueLabel: u.dueLabel,
        frequency: 'monthly',
        paymentType: u.autoSend ? 'send' : 'bill',
        title: u.title,
      ),
      autoPay: u.autoSend,
    );
  }
}

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// e.g. "June 2026 Budget"
String formatMonthBudgetTitle({DateTime? date, String? periodLabel}) {
  final d = date ?? DateTime.now();
  if (periodLabel != null &&
      periodLabel.trim().isNotEmpty &&
      periodLabel.toLowerCase() != 'this month') {
    if (periodLabel.toLowerCase().contains('budget')) {
      return periodLabel.trim();
    }
    return '${periodLabel.trim()} Budget';
  }
  return '${_months[d.month - 1]} ${d.year} Budget';
}

/// Centered summary line, e.g. "Your June 2026 Budget has ₦987 total income."
String formatMonthBudgetSummaryParagraph({
  required String monthTitle,
  required double totalIncome,
  required String currency,
  required String totalIncomeLabel,
}) {
  final amount = formatDayFlowAmount(totalIncome, currency);
  final title =
      monthTitle.startsWith('Your ') ? monthTitle : 'Your $monthTitle';
  return '$title has $amount $totalIncomeLabel.';
}

String formatDayBudgetSchedule({
  String? dueLabel,
  String frequency = 'monthly',
  String paymentType = 'send',
  String title = '',
}) {
  final due = dueLabel?.trim();
  if (due != null && due.isNotEmpty) {
    final lower = due.toLowerCase();
    if (lower.contains('automatic') ||
        lower.contains('when low') ||
        lower.contains('auto top')) {
      return due;
    }
    if (RegExp(r'^\d').hasMatch(due) ||
        due.contains('th') ||
        due.contains('st') ||
        due.contains('nd') ||
        due.contains('rd') ||
        due.contains(',')) {
      if (due.toLowerCase().contains('every')) return due;
      if (due.contains(',')) return due;
      return '$due of every month';
    }
    if (due.toLowerCase().startsWith('due ')) {
      return '${due.substring(4)} of every month';
    }
    return due;
  }

  final lowerTitle = title.toLowerCase();
  if (lowerTitle.contains('electric') ||
      lowerTitle.contains('when low') ||
      paymentType == 'bill' && lowerTitle.contains('top')) {
    return 'automatically when low';
  }

  switch (frequency.toLowerCase()) {
    case 'weekly':
      return 'every week';
    case 'biweekly':
      return 'every two weeks';
    case 'once':
      return 'one time';
    case 'monthly':
    default:
      return 'every month';
  }
}

String formatAutomationLine(DayBudgetAutomationItem item) {
  final amount = formatDayFlowAmount(item.amount, 'NGN');
  final hint = item.recipientHint?.trim();
  if (hint != null && hint.isNotEmpty) {
    return '${item.title} · $amount · $hint — ${item.scheduleText}';
  }
  final verb = _actionVerb(item.title);
  final name = _displayName(item.title, verb);
  if (verb != null && name.isNotEmpty) {
    return '$verb $amount to $name — ${item.scheduleText}';
  }
  return '${item.title} — $amount — ${item.scheduleText}';
}

String? _actionVerb(String title) {
  final t = title.toLowerCase();
  if (t.startsWith('send ')) return 'Send';
  if (t.startsWith('buy ') || t.contains('data') || t.contains('airtime')) {
    return 'Buy';
  }
  if (t.contains('netflix') ||
      t.contains('spotify') ||
      t.contains('subscription')) {
    return null;
  }
  if (t.contains('electric') || t.contains('bill')) return null;
  if (t.contains('to ')) return 'Send';
  return null;
}

String _displayName(String title, String? verb) {
  var t = title.trim();
  if (verb == 'Send') {
    t = t.replaceFirst(RegExp(r'^send\s+', caseSensitive: false), '');
    if (t.toLowerCase().startsWith('to ')) {
      t = t.substring(3);
    }
    return t;
  }
  if (verb == 'Buy') {
    t = t.replaceFirst(RegExp(r'^buy\s+', caseSensitive: false), '');
    return t;
  }
  return t;
}

List<DayBudgetAutomationItem> collectAutomationItems({
  required List<DayFlowEnvelope> flows,
  DayFlowPlan? plan,
}) {
  final items = <DayBudgetAutomationItem>[];
  final seen = <String>{};

  void addItem(DayBudgetAutomationItem item) {
    final key = '${item.title}|${item.amount}|${item.scheduleText}';
    if (seen.add(key)) items.add(item);
  }

  for (final flow in flows) {
    if (flow.schedules.isNotEmpty) {
      for (final s in flow.schedules) {
        addItem(DayBudgetAutomationItem.fromSchedule(s));
      }
    } else {
      for (final c in flow.categories) {
        if (!dayflowCategoryNeedsAutopaySchedule(c.name)) continue;
        addItem(
          DayBudgetAutomationItem(
            id: '${flow.id}-${c.name}',
            title: c.name,
            amount: c.allocated,
            scheduleText: formatDayBudgetSchedule(
              dueLabel: flow.periodLabel,
              frequency: flow.budgetType ?? flow.flowType,
              paymentType: dayflowPaymentTypeForTitle(c.name),
              title: c.name,
            ),
            autoPay: true,
          ),
        );
      }
    }
  }

  if (plan != null) {
    if (plan.upcoming.isNotEmpty) {
      for (var i = 0; i < plan.upcoming.length; i++) {
        addItem(DayBudgetAutomationItem.fromUpcoming(plan.upcoming[i], i));
      }
    } else {
      for (var i = 0; i < plan.categories.length; i++) {
        final c = plan.categories[i];
        if (!dayflowCategoryNeedsAutopaySchedule(c.name)) continue;
        addItem(
          DayBudgetAutomationItem(
            id: 'plan-cat-$i',
            title: c.name,
            amount: c.allocated,
            scheduleText: formatDayBudgetSchedule(
              dueLabel: plan.periodLabel,
              frequency: plan.budgetType,
              paymentType: dayflowPaymentTypeForTitle(c.name),
              title: c.name,
            ),
            autoPay: true,
          ),
        );
      }
    }
  }

  return items;
}
