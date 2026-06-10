import 'package:dayfi/features/budget/models/budget_models.dart';
import 'package:dayfi/features/budget/views/budget_detail_view.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_from_budget.dart';
import 'package:flutter/material.dart';

/// Opens budget detail or DayFlow schedule detail for linked autopay rows.
abstract final class BudgetNavigation {
  BudgetNavigation._();

  static Future<void> openDetail(
    BuildContext context, {
    required Budget budget,
    VoidCallback? onUpdated,
  }) async {
    if (budget.isManagedByDayFlow) {
      await DayFlowScheduleFromBudget.open(
        context,
        budget: budget,
        onUpdated: onUpdated,
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BudgetDetailView(
              budgetId: budget.id,
              initialBudget: budget,
            ),
      ),
    );
  }
}
