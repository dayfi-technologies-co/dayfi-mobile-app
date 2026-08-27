import 'package:dayfi/core/navigation/dayfi_page_transitions.dart';
import 'package:dayfi/features/budget/views/create_budget_view.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_setup_launcher.dart';
import 'package:dayfi/features/dayflow/models/dayflow_automation_edit_context.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/services/dayflow_api_service.dart';
import 'package:dayfi/features/dayflow/services/dayflow_cache_sync.dart';
import 'package:dayfi/features/dayflow/services/dayflow_dashboard_cache.dart';
import 'package:flutter/material.dart';

/// Opens the automation form prefilled for editing a scheduled payment.
abstract final class DayFlowScheduleEditLauncher {
  DayFlowScheduleEditLauncher._();

  static ({DayFlowEnvelopeSchedule? schedule, DayFlowEnvelope? flow})
  _resolveSchedule(
    List<DayFlowEnvelope> flows,
    DayBudgetScheduleInstance item,
  ) {
    for (final flow in flows) {
      if (flow.id != item.flowId) continue;
      for (final schedule in flow.schedules) {
        final sid = schedule.id.isNotEmpty ? schedule.id : schedule.title;
        if (sid == item.scheduleId) {
          return (schedule: schedule, flow: flow);
        }
      }
    }
    return (schedule: null, flow: null);
  }

  static bool _isBill(DayBudgetScheduleInstance item) {
    if (item.paymentType == 'bill') return true;
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

  static Future<bool> open(
    BuildContext context,
    DayBudgetScheduleInstance item, {
    VoidCallback? onUpdated,
  }) async {
    if (item.needsSetup) {
      await DayFlowScheduleSetupLauncher.open(
        context,
        item,
        onUpdated: onUpdated,
      );
      return false;
    }

    var flows = <DayFlowEnvelope>[];
    try {
      final dash =
          DayflowDashboardCache.instance.peek() ??
          await dayFlowApiService.fetchDashboard();
      flows = dash?.flows ?? const [];
    } catch (_) {}

    final resolved = _resolveSchedule(flows, item);
    final edit = DayFlowAutomationEditContext.fromScheduleInstance(
      item: item,
      schedule: resolved.schedule,
      flow: resolved.flow,
    );
    if (edit == null || !context.mounted) return false;

    final isBill = _isBill(item);
    final updated = await Navigator.push<bool>(
      context,
      DayfiPageRoute<bool>(
        builder:
            (_) => CreateBudgetView(
              kind: isBill ? BudgetCreateKind.bill : BudgetCreateKind.send,
              forDayFlowAutomation: true,
              dayFlowEdit: edit,
            ),
      ),
    );

    if (updated == true) {
      DayFlowCacheSync.invalidateAll();
      onUpdated?.call();
      return true;
    }
    return false;
  }
}
