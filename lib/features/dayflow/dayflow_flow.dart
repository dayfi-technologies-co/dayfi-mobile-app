import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/models/dayflow_overlay_task.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/services/dayflow_conversation_store.dart';
import 'package:dayfi/features/dayflow/services/dayflow_income_service.dart';
import 'package:dayfi/core/navigation/dayfi_page_transitions.dart';
import 'package:dayfi/features/dayflow/views/dayflow_main_view.dart';
import 'package:dayfi/features/dayflow/widgets/dayflow_overlay.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/common/widgets/dayfi_web_dialog.dart';
import 'package:flutter/material.dart';

abstract final class DayFlowFlow {
  /// Opens DayFlow as a full-screen overlay (DayX-style).
  static Future<bool> openOverlay(
    BuildContext context, {
    String? initialPrompt,
    String? prefillPrompt,
    DayFlowOverlayTask task = DayFlowOverlayTask.general,
    DayFlowIncomeEvent? initialIncome,
    bool allowPendingIncomePrompt = true,
    bool freshSession = false,
    VoidCallback? onPlanActivated,
    bool navigateToDashboardOnSuccess = false,
  }) async {
    final result = await DayFlowOverlay.show(
      context,
      initialPrompt: initialPrompt,
      prefillPrompt: prefillPrompt,
      task: task,
      initialIncome: initialIncome,
      allowPendingIncomePrompt: allowPendingIncomePrompt,
      freshSession: freshSession,
      onPlanActivated: onPlanActivated,
      navigateToDashboardOnSuccess: navigateToDashboardOnSuccess,
    );
    return result == true;
  }

  static Future<bool> openForIncome(
    BuildContext context,
    DayFlowIncomeEvent income, {
    VoidCallback? onPlanActivated,
  }) {
    return openOverlay(
      context,
      initialIncome: income,
      allowPendingIncomePrompt: false,
      onPlanActivated: onPlanActivated,
    );
  }

  /// After wallet top-up sync, offer DayFlow allocation if new deposits exist.
  static Future<void> promptPendingIncome(BuildContext context) async {
    final income = await DayFlowIncomeService.instance.latestPending(
      preferCurrency: 'NGN',
    );
    if (income == null || !context.mounted) return;

    final plan = await showDialog<bool>(
      context: context,
      builder: (ctx) => DayfiWebAlertDialog(
        title: Text(DayFlowCopy.incomeDetectedTitle),
        content: Text(
          '${DayFlowCopy.incomeWelcome('New funds')} '
          '(${income.label}).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(DayFlowCopy.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(DayFlowCopy.planThisMoney),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (plan == true) {
      await openForIncome(context, income);
    } else {
      await DayFlowIncomeService.instance.dismiss(income);
    }
  }

  static void popToMain(BuildContext context) {
    if (!context.mounted) return;
    Navigator.of(context).popUntil(
      (route) =>
          route.settings.name == AppRoute.mainView || route.isFirst,
    );
  }

  static Future<void> openMain(BuildContext context) async {
    if (ModalRoute.of(context)?.settings.name == AppRoute.dayFlowView) {
      return;
    }
    await Navigator.push<void>(
      context,
      DayfiPageRoute<void>(
        settings: const RouteSettings(name: AppRoute.dayFlowView),
        builder: (_) => const DayFlowMainView(),
      ),
    );
  }

  /// Always starts a fresh creation chat (no resumed conversation).
  static Future<bool> openNewFlow(
    BuildContext context, {
    VoidCallback? onFlowActivated,
    bool navigateToDashboardOnSuccess = false,
  }) async {
    await DayFlowConversationStore.instance.clear();
    return openOverlay(
      context,
      allowPendingIncomePrompt: false,
      freshSession: true,
      onPlanActivated: onFlowActivated,
      navigateToDashboardOnSuccess: navigateToDashboardOnSuccess,
    );
  }

  @Deprecated('Use openOverlay instead')
  static Future<bool> openChat(
    BuildContext context, {
    String? initialPrompt,
  }) {
    return openOverlay(context, initialPrompt: initialPrompt);
  }
}
