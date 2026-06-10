import 'package:dayfi/features/dayflow/dayflow_flow.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/models/dayflow_overlay_task.dart';
import 'package:dayfi/features/dayflow/services/dayflow_conversation_store.dart';
import 'package:dayfi/features/dayflow/services/dayflow_api_service.dart';
import 'package:dayfi/features/dayflow/services/dayflow_cache_sync.dart';
import 'package:dayfi/features/dayflow/services/dayflow_dashboard_cache.dart';
import 'package:dayfi/features/dayflow/views/create_dayflow_automation_type_view.dart';
import 'package:flutter/material.dart';

/// DayFlow entry — automate payment form when empty, dashboard when live.
abstract final class DayBudgetFlow {
  DayBudgetFlow._();

  /// Whether the user has at least one scheduled autopay (send or bill).
  static bool hasAutomations(DayFlowDashboardSnapshot? snap) {
    if (snap == null) return false;
    final instances = snap.scheduleInstances;
    if (instances.upcoming.isNotEmpty || instances.past.isNotEmpty) {
      return true;
    }
    for (final flow in snap.flows) {
      if (!flow.isActive) continue;
      if (flow.schedules.any((s) => s.amount > 0 && s.autoPay)) {
        return true;
      }
    }
    return false;
  }

  /// Home card: dashboard when automations exist; otherwise automate-payment picker.
  static Future<void> open(BuildContext context) async {
    var cached = DayflowDashboardCache.instance.peek();
    if (cached == null) {
      try {
        cached = await dayFlowApiService.fetchDashboard();
      } catch (_) {}
    }

    if (cached != null) {
      if (hasAutomations(cached)) {
        await openDashboard(context);
      } else if (context.mounted) {
        await openCreateAutomation(context, navigateToDashboardOnSuccess: true);
      }
      return;
    }

    if (DayflowDashboardCache.instance.hasActivePlan == true) {
      await openDashboard(context);
      return;
    }

    if (!context.mounted) return;
    await openCreateAutomation(context, navigateToDashboardOnSuccess: true);
  }

  /// First-time automation — send or bill form (no chat).
  static Future<bool> openCreateAutomation(
    BuildContext context, {
    VoidCallback? onActivated,
    bool navigateToDashboardOnSuccess = false,
  }) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateDayFlowAutomationTypeView(),
      ),
    );
    if (created == true) {
      DayFlowCacheSync.invalidateAll();
      onActivated?.call();
      if (navigateToDashboardOnSuccess && context.mounted) {
        await openDashboard(context);
      }
      return true;
    }
    return false;
  }

  /// First-time / monthly budget creation (DayX budget mode).
  static Future<bool> openCreateChat(
    BuildContext context, {
    VoidCallback? onActivated,
    bool navigateToDashboardOnSuccess = false,
  }) async {
    await DayFlowConversationStore.instance.clear();
    return DayFlowFlow.openOverlay(
      context,
      allowPendingIncomePrompt: false,
      freshSession: true,
      onPlanActivated: onActivated,
      navigateToDashboardOnSuccess: navigateToDashboardOnSuccess,
    );
  }

  /// Adjust an existing budget via natural language.
  static Future<bool> openEditChat(
    BuildContext context, {
    String? initialPrompt,
    VoidCallback? onActivated,
  }) {
    return DayFlowFlow.openOverlay(
      context,
      task: DayFlowOverlayTask.editBudget,
      prefillPrompt: initialPrompt ?? 'Adjust my budget: ',
      allowPendingIncomePrompt: false,
      onPlanActivated: onActivated,
    );
  }

  /// Add a recurring send or bill via the budget-style form (autopay on).
  static Future<bool> openAddAutomation(
    BuildContext context, {
    VoidCallback? onActivated,
  }) {
    return openCreateAutomation(context, onActivated: onActivated);
  }

  /// Add a recurring item via chat.
  static Future<bool> openAddItemChat(
    BuildContext context, {
    VoidCallback? onActivated,
  }) {
    return DayFlowFlow.openOverlay(
      context,
      task: DayFlowOverlayTask.addItem,
      allowPendingIncomePrompt: false,
      onPlanActivated: onActivated,
    );
  }

  static Future<void> openDashboard(BuildContext context) {
    return DayFlowFlow.openMain(context);
  }
}
