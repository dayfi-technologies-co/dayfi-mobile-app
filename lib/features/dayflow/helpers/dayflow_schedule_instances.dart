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

int? _parseMonthDay(String? label, DateTime ref) {
  if (label == null || label.trim().isEmpty) return null;
  final m = RegExp(r'\b(\d{1,2})(?:st|nd|rd|th)?\b', caseSensitive: false)
      .firstMatch(label);
  if (m != null) {
    final day = int.tryParse(m.group(1)!);
    if (day != null && day >= 1 && day <= 31) return day;
  }
  return ref.day;
}

String _resolveFrequency({
  required DayFlowEnvelopeSchedule schedule,
  required DayFlowEnvelope flow,
}) {
  final explicit = schedule.frequency.toLowerCase();
  if (explicit.isNotEmpty && explicit != 'monthly') return explicit;
  final fromLabel = dayflowFrequencyFromLabel(schedule.dueLabel ?? flow.periodLabel);
  if (fromLabel != 'monthly') return fromLabel;
  return (flow.budgetType ?? 'monthly').toLowerCase();
}

DayBudgetInstanceStatus _resolveStatus({
  required DateTime dueAt,
  required DateTime now,
  DayFlowEnvelopeSchedule? schedule,
}) {
  if (!_startOfDay(dueAt).isBefore(_startOfDay(now))) {
    return DayBudgetInstanceStatus.upcoming;
  }

  if (schedule?.lastRunAt != null) {
    final lastRun = DateTime.tryParse(schedule!.lastRunAt!);
    if (lastRun != null) {
      final diff =
          _startOfDay(lastRun).difference(_startOfDay(dueAt)).inDays.abs();
      if (diff <= 1 && schedule.lastStatus == 'success') {
        return DayBudgetInstanceStatus.paid;
      }
      if (diff <= 1 && schedule.lastStatus == 'failed') {
        return DayBudgetInstanceStatus.failed;
      }
    }
  }

  if (schedule?.lastStatus == 'failed') {
    return DayBudgetInstanceStatus.failed;
  }
  return DayBudgetInstanceStatus.overdue;
}

List<DateTime> _datesInRange(DateTime start, DateTime end, int stepDays) {
  final out = <DateTime>[];
  var cur = _startOfDay(start);
  final last = _startOfDay(end);
  while (!cur.isAfter(last)) {
    out.add(cur);
    cur = cur.add(Duration(days: stepDays));
  }
  return out;
}

List<DateTime> _weekdaysInPeriod(
  DateTime periodStart,
  DateTime periodEnd,
  int weekday,
) {
  final out = <DateTime>[];
  var cur = _startOfDay(periodStart);
  final last = _startOfDay(periodEnd);
  while (cur.weekday != weekday && !cur.isAfter(last)) {
    cur = cur.add(const Duration(days: 1));
  }
  while (!cur.isAfter(last)) {
    out.add(cur);
    cur = cur.add(const Duration(days: 7));
  }
  return out;
}

List<DayBudgetScheduleInstance> _expandSchedule({
  required DayFlowEnvelope flow,
  required DayFlowEnvelopeSchedule schedule,
  required DateTime periodStart,
  required DateTime periodEnd,
  required DateTime now,
}) {
  final freqRaw = _resolveFrequency(schedule: schedule, flow: flow);
  final dueLabel = schedule.dueLabel ?? flow.periodLabel ?? '';
  final scheduleId = schedule.id.isNotEmpty ? schedule.id : schedule.title;
  final paymentType = schedule.paymentType;
  final needsSetup = _scheduleNeedsSetup(
    paymentType: paymentType,
    recipientId: schedule.recipientId,
    recipientHint: schedule.recipientHint,
  );

  DayBudgetScheduleInstance build(DateTime due, {String? idSuffix}) {
    final suffix = idSuffix ?? due.toIso8601String().substring(0, 10);
    return DayBudgetScheduleInstance(
      id: '${flow.id}:$scheduleId:$suffix',
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

  if (freqRaw == 'once') {
    final due = schedule.nextRunAt != null
        ? (DateTime.tryParse(schedule.nextRunAt!) ?? periodStart)
        : periodStart;
    return [build(due, idSuffix: 'once')];
  }

  if (freqRaw == 'daily') {
    return _datesInRange(periodStart, periodEnd, 1).map(build).toList();
  }

  final weekday = _parseWeekday(dueLabel);
  if (freqRaw == 'weekly' || weekday != null) {
    final target = weekday ?? _anchorWeekday(schedule, now);
    var anchor = _startOfDay(periodStart);
    final today = _startOfDay(now);
    if (schedule.nextRunAt != null) {
      final next = DateTime.tryParse(schedule.nextRunAt!);
      if (next != null) anchor = _startOfDay(next);
    }
    if (anchor.isBefore(today)) anchor = today;
    return _weekdaysInPeriod(anchor, periodEnd, target).map(build).toList();
  }

  if (freqRaw == 'biweekly') {
    var anchor = schedule.nextRunAt != null
        ? _startOfDay(DateTime.tryParse(schedule.nextRunAt!) ?? periodStart)
        : _startOfDay(periodStart);
    while (anchor.isBefore(_startOfDay(periodStart))) {
      anchor = anchor.add(const Duration(days: 14));
    }
    final out = <DayBudgetScheduleInstance>[];
    var cur = anchor;
    while (!cur.isAfter(periodEnd)) {
      out.add(build(cur));
      cur = cur.add(const Duration(days: 14));
    }
    return out;
  }

  final dayOfMonth = _parseMonthDay(dueLabel, periodStart) ?? 1;
  final lastDay = periodEnd.day;
  final due = DateTime(
    periodStart.year,
    periodStart.month,
    dayOfMonth > lastDay ? lastDay : dayOfMonth,
  );
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
    final due = _startOfDay(inst.dueAt);
    if (inst.status == DayBudgetInstanceStatus.upcoming ||
        (!due.isBefore(today) && inst.status != DayBudgetInstanceStatus.paid)) {
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
