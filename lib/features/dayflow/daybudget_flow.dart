import 'package:dayfi/features/dayflow/dayflow_flow.dart';
import 'package:dayfi/features/dayflow/models/dayflow_overlay_task.dart';
import 'package:dayfi/features/dayflow/services/dayflow_conversation_store.dart';
import 'package:dayfi/features/dayflow/services/dayflow_dashboard_cache.dart';
import 'package:dayfi/features/dayflow/services/dayflow_local_store.dart';
import 'package:dayfi/features/dayflow/views/create_dayflow_automation_type_view.dart';
import 'package:flutter/material.dart';

/// DayFlow entry — chat to create budgets and automations, dashboard when live.
abstract final class DayBudgetFlow {
  DayBudgetFlow._();

  /// Home card: new users → budget chat; active setup → dashboard.
  static Future<void> open(BuildContext context) async {
    final cachedPlan = DayflowDashboardCache.instance.hasActivePlan;
    if (cachedPlan == true) {
      await openDashboard(context);
      return;
    }

    if (cachedPlan == false) {
      await openCreateChat(context, navigateToDashboardOnSuccess: true);
      return;
    }

    // Cache unknown — resolve route before showing chat (avoids chat flash).
    if (await DayFlowActivity.hasLocalSetup()) {
      if (!context.mounted) return;
      await openDashboard(context);
      return;
    }

    final hasSetup = await DayFlowActivity.hasPlan();
    if (!context.mounted) return;
    if (hasSetup) {
      await openDashboard(context);
    } else {
      await openCreateChat(context, navigateToDashboardOnSuccess: true);
    }
  }

  /// First-time / monthly budget creation (DayX budget mode).
  /// Always starts a fresh chat when no active flows exist yet.
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
  }) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateDayFlowAutomationTypeView(),
      ),
    );
    if (created == true) {
      DayflowDashboardCache.instance.invalidate();
      onActivated?.call();
      return true;
    }
    return false;
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
