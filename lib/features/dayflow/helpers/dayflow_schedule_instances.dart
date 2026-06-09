import 'package:dayfi/features/dayflow/helpers/dayflow_draft_schedules.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_wallet_balance.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

const _weekdays = {
  'sunday': DateTime.sunday,
  'monday': DateTime.monday,
  'tuesday': DateTime.tuesday,
  'wednesday': DateTime.wednesday,
  'thursday': DateTime.thursday,
  'friday': DateTime.friday,
  'saturday': DateTime.saturday,
};

({DateTime start, DateTime end, String label}) currentPeriodBounds([
  DateTime? ref,
]) {
  final now = ref ?? DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  const months = [
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
  return (
    start: start,
    end: end,
    label: '${months[now.month - 1]} ${now.year}',
  );
}

int? _parseWeekday(String? label) {
  if (label == null || label.trim().isEmpty) return null;
  final lower = label.toLowerCase();
  for (final e in _weekdays.entries) {
    if (lower.contains(e.key)) return e.value;
  }
  return null;
}

bool _scheduleNeedsSetup({
  required String paymentType,
  String? recipientId,
  String? recipientHint,
}) {
  if (paymentType == 'savings') return false;
  if (paymentType == 'bill') {
    return (recipientHint ?? '').trim().isEmpty;
  }
  final tag = (recipientId ?? recipientHint ?? '').trim();
  return tag.isEmpty;
}

DayBudgetInstanceStatus _resolveStatus({
  required DateTime dueAt,
  required DateTime now,
  DayFlowEnvelopeSchedule? schedule,
}) {
  if (!_startOfDay(dueAt).isBefore(_startOfDay(now))) {
    return DayBudgetInstanceStatus.upcoming;
  }
  if (schedule?.nextRunAt != null) {
    final lastRun = DateTime.tryParse(schedule!.nextRunAt!);
    if (lastRun != null) {
      final diff = _startOfDay(lastRun).difference(_startOfDay(dueAt)).inDays.abs();
      if (diff <= 1) return DayBudgetInstanceStatus.paid;
    }
  }
  return DayBudgetInstanceStatus.overdue;
}

List<DayBudgetScheduleInstance> _expandSchedule({
  required DayFlowEnvelope flow,
  required DayFlowEnvelopeSchedule schedule,
  required DateTime periodStart,
  required DateTime periodEnd,
  required DateTime now,
}) {
  final freq = schedule.frequency.isNotEmpty
      ? schedule.frequency
      : dayflowFrequencyFromLabel(
          schedule.dueLabel ?? flow.periodLabel ?? flow.budgetType ?? flow.flowType,
        );
  final dueLabel = schedule.dueLabel ?? flow.periodLabel ?? '';
  final scheduleId = schedule.id.isNotEmpty ? schedule.id : schedule.title;
  final paymentType = schedule.paymentType;
  final needsSetup = _scheduleNeedsSetup(
    paymentType: paymentType,
    recipientId: schedule.recipientId,
    recipientHint: schedule.recipientHint,
  );

  DayBudgetScheduleInstance build(DateTime due) {
    return DayBudgetScheduleInstance(
      id: '${flow.id}:$scheduleId:${due.toIso8601String().substring(0, 10)}',
      flowId: flow.id,
      scheduleId: scheduleId,
      title: schedule.title,
      amount: schedule.amount,
      dueAt: due,
      status: _resolveStatus(dueAt: due, now: now, schedule: schedule),
      autoPay: schedule.autoPay,
      paymentType: paymentType,
      recipientHint: schedule.recipientHint,
      recipientId: schedule.recipientId,
      needsSetup: needsSetup,
      flowTitle: flow.title,
      dueLabel: dueLabel,
    );
  }

  final weekday = _parseWeekday(dueLabel);
  if (freq == 'weekly' || weekday != null) {
    final target = weekday ?? _anchorWeekday(schedule, now);
    var anchor = _startOfDay(periodStart);
    final today = _startOfDay(now);
    if (schedule.nextRunAt != null) {
      final next = DateTime.tryParse(schedule.nextRunAt!);
      if (next != null) {
        anchor = _startOfDay(next);
      }
    }
    if (anchor.isBefore(today)) anchor = today;

    var cur = anchor;
    while (cur.weekday != target && !cur.isAfter(periodEnd)) {
      cur = cur.add(const Duration(days: 1));
    }
    final out = <DayBudgetScheduleInstance>[];
    while (!cur.isAfter(periodEnd)) {
      out.add(build(cur));
      cur = cur.add(const Duration(days: 7));
    }
    return out;
  }

  if (freq == 'daily') {
    final out = <DayBudgetScheduleInstance>[];
    var cur = _startOfDay(periodStart);
    while (!cur.isAfter(periodEnd)) {
      out.add(build(cur));
      cur = cur.add(const Duration(days: 1));
    }
    return out;
  }

  if (freq == 'once') {
    final due = schedule.nextRunAt != null
        ? (DateTime.tryParse(schedule.nextRunAt!) ?? periodStart)
        : periodStart;
    return [build(due)];
  }

  final due = DateTime(periodStart.year, periodStart.month, 1);
  return [build(due)];
}

int _anchorWeekday(DayFlowEnvelopeSchedule schedule, DateTime now) {
  if (schedule.nextRunAt != null) {
    final next = DateTime.tryParse(schedule.nextRunAt!);
    if (next != null) return next.weekday;
  }
  return now.weekday;
}

DayFlowEnvelopeSchedule _categoryAsSchedule(DayFlowEnvelope flow, DayFlowCategory cat) {
  return DayFlowEnvelopeSchedule(
    id: 'cat-${cat.name}',
    title: cat.name,
    amount: cat.allocated,
    dueLabel: flow.periodLabel,
    frequency: flow.budgetType ?? 'monthly',
    autoPay: true,
    paymentType: dayflowPaymentTypeForTitle(cat.name),
  );
}

DayBudgetScheduleInstances collectLocalScheduleInstances({
  required List<DayFlowEnvelope> flows,
  DayFlowPlan? plan,
  DateTime? now,
}) {
  final ref = now ?? DateTime.now();
  final period = currentPeriodBounds(ref);
  final active = flows.where((f) => f.isActive).toList();

  final sourceFlows = active.isNotEmpty
      ? active
      : plan != null
          ? [
              DayFlowEnvelope(
                id: plan.id,
                title: plan.title,
                flowType: plan.budgetType,
                status: 'active',
                totalAmount: plan.totalBudget,
                heldAmount: 0,
                spentAmount: plan.spent,
                remainingAmount: plan.leftover,
                currency: plan.currency,
                categories: plan.categories,
                periodLabel: plan.periodLabel,
                budgetType: plan.budgetType,
                schedules: plan.upcoming
                    .asMap()
                    .entries
                    .map(
                      (e) => DayFlowEnvelopeSchedule(
                        id: 'up-${e.key}',
                        title: e.value.title,
                        amount: e.value.amount,
                        dueLabel: e.value.dueLabel,
                        recipientHint: e.value.recipientHint,
                        recipientId: e.value.recipientId,
                        autoPay: e.value.autoSend,
                        frequency: plan.budgetType,
                        paymentType: e.value.autoSend ? 'send' : 'bill',
                      ),
                    )
                    .toList(),
              ),
            ]
          : <DayFlowEnvelope>[];

  final all = <DayBudgetScheduleInstance>[];
  for (final flow in sourceFlows) {
    final schedules = flow.schedules.isNotEmpty
        ? flow.schedules
        : flow.categories.map((c) => _categoryAsSchedule(flow, c)).toList();
    for (final s in schedules) {
      if (s.amount <= 0) continue;
      all.addAll(
        _expandSchedule(
          flow: flow,
          schedule: s,
          periodStart: period.start,
          periodEnd: period.end,
          now: ref,
        ),
      );
    }
  }

  all.sort((a, b) => a.dueAt.compareTo(b.dueAt));
  final today = _startOfDay(ref);
  final upcoming = <DayBudgetScheduleInstance>[];
  final past = <DayBudgetScheduleInstance>[];

  for (final inst in all) {
    if (inst.status == DayBudgetInstanceStatus.upcoming ||
        !_startOfDay(inst.dueAt).isBefore(today)) {
      upcoming.add(inst);
    } else {
      past.add(inst);
    }
  }

  past.sort((a, b) => b.dueAt.compareTo(a.dueAt));

  return DayBudgetScheduleInstances(
    upcoming: upcoming,
    past: past,
    committedThisPeriod: upcoming.fold<double>(0, (s, i) => s + i.amount),
    periodLabel: period.label,
  );
}

String formatInstanceDueDate(DateTime due) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[due.month - 1]} ${due.day}';
}

String formatInstanceLine(
  DayBudgetScheduleInstance item, {
  String currency = kDayFlowWalletCurrency,
}) {
  final date = formatInstanceDueDate(item.dueAt);
  final amount = formatDayFlowAmount(item.amount, currency);
  return '${item.title} · $amount · $date';
}
