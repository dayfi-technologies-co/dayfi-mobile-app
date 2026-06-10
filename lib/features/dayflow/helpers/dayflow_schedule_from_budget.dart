import 'package:dayfi/features/budget/models/budget_models.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/services/dayflow_api_service.dart';
import 'package:dayfi/features/dayflow/services/dayflow_dashboard_cache.dart';
import 'package:dayfi/features/dayflow/views/dayflow_schedule_detail_view.dart';
import 'package:flutter/material.dart';

/// Links Budget rows created by DayFlow autopay to schedule instances.
abstract final class DayFlowScheduleFromBudget {
  DayFlowScheduleFromBudget._();

  static Future<bool> open(
    BuildContext context, {
    required Budget budget,
    VoidCallback? onUpdated,
  }) async {
    if (!budget.isManagedByDayFlow) return false;

    DayBudgetScheduleInstance item;

    var dash = DayflowDashboardCache.instance.peek();
    try {
      dash ??= await dayFlowApiService.fetchDashboard();
    } catch (_) {}

    item =
        resolveInstance(budget, dash?.scheduleInstances) ??
        _fromBudget(
          budget,
          scheduleId: budget.dayflowScheduleId ?? budget.id,
        );

    if (!context.mounted) return false;
    await DayFlowScheduleDetailView.open(
      context,
      item: item,
      onUpdated: onUpdated,
    );
    return true;
  }

  /// Best matching schedule row for a linked budget (aligned with [Budget.nextRunAt]).
  static DayBudgetScheduleInstance? resolveInstance(
    Budget budget,
    DayBudgetScheduleInstances? instances,
  ) {
    if (!budget.isManagedByDayFlow) return null;
    final flowId = budget.dayflowFlowId!;
    final scheduleId = budget.dayflowScheduleId ?? budget.id;
    if (instances == null) return null;

    return _findBestMatch(
      instances,
      flowId: flowId,
      scheduleId: scheduleId,
      anchor: budget.nextRunAt,
    );
  }

  static int compareByNextRun(
    Budget a,
    Budget b,
    DayBudgetScheduleInstance? instA,
    DayBudgetScheduleInstance? instB,
  ) {
    final keyA = sortKey(a, instA);
    final keyB = sortKey(b, instB);
    if (keyA == null && keyB == null) return a.name.compareTo(b.name);
    if (keyA == null) return 1;
    if (keyB == null) return -1;
    final cmp = keyA.compareTo(keyB);
    if (cmp != 0) return cmp;
    return a.name.compareTo(b.name);
  }

  static DateTime? sortKey(Budget budget, DayBudgetScheduleInstance? instance) {
    if (instance != null) return instance.dueAt;
    return budget.nextRunAt;
  }

  static DayBudgetScheduleInstance? _findBestMatch(
    DayBudgetScheduleInstances instances, {
    required String flowId,
    required String scheduleId,
    DateTime? anchor,
  }) {
    bool matches(DayBudgetScheduleInstance i) =>
        i.flowId == flowId && i.scheduleId == scheduleId;

    final all = <DayBudgetScheduleInstance>[
      ...instances.upcoming.where(matches),
      ...instances.past.where(matches),
    ];
    if (all.isEmpty) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (anchor != null) {
      final local = anchor.toLocal();
      for (final i in all) {
        final d = i.dueAt.toLocal();
        if (d.year == local.year &&
            d.month == local.month &&
            d.day == local.day) {
          return i;
        }
      }

      final anchorDay = DateTime(local.year, local.month, local.day);
      if (!anchorDay.isBefore(today)) {
        final futureMatches =
            all.where((i) {
              final d = DateTime(i.dueAt.year, i.dueAt.month, i.dueAt.day);
              return !d.isBefore(today);
            }).toList();
        if (futureMatches.isNotEmpty) {
          futureMatches.sort((a, b) {
            final diffA = a.dueAt.difference(local).inSeconds.abs();
            final diffB = b.dueAt.difference(local).inSeconds.abs();
            final cmp = diffA.compareTo(diffB);
            if (cmp != 0) return cmp;
            return a.dueAt.compareTo(b.dueAt);
          });
          return futureMatches.first;
        }
        // Budget next run is ahead of API instances — use budget row fallback.
        return null;
      }

      all.sort((a, b) => b.dueAt.compareTo(a.dueAt));
      return all.first;
    }

    final upcoming =
        all.where((i) {
          final d = DateTime(i.dueAt.year, i.dueAt.month, i.dueAt.day);
          return !d.isBefore(today);
        }).toList()..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    if (upcoming.isNotEmpty) return upcoming.first;

    all.sort((a, b) => b.dueAt.compareTo(a.dueAt));
    return all.first;
  }

  static DayBudgetScheduleInstance _fromBudget(
    Budget budget, {
    required String scheduleId,
  }) {
    final flowId = budget.dayflowFlowId!;
    final paymentType =
        budget.dayflowPaymentType ??
        (budget.type == 'bill_reminder' ? 'bill' : 'send');
    final dueAt = budget.nextRunAt ?? DateTime.now();

    return DayBudgetScheduleInstance(
      id: '$flowId:$scheduleId:budget-link',
      flowId: flowId,
      scheduleId: scheduleId,
      title: budget.name,
      amount: budget.amount,
      dueAt: dueAt,
      status: _statusFromDueDate(dueAt),
      autoPay: true,
      paymentType: paymentType,
      recipientHint: budget.metadata['recipientHint']?.toString(),
      recipientId: budget.recipientId,
      dueLabel: budget.frequencyLabel,
    );
  }

  static DayBudgetInstanceStatus _statusFromDueDate(DateTime due) {
    final local = due.toLocal();
    final dueDay = DateTime(local.year, local.month, local.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (dueDay.isBefore(today)) return DayBudgetInstanceStatus.overdue;
    return DayBudgetInstanceStatus.upcoming;
  }
}
