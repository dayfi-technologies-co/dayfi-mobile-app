import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_setup_launcher.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/views/dayflow_schedule_detail_view.dart';
import 'package:flutter/material.dart';

/// Shared tap behaviour for schedule rows on DayFlow.
abstract final class DayFlowScheduleActions {
  DayFlowScheduleActions._();

  static Future<void> handleTap(
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
      return;
    }

    await DayFlowScheduleDetailView.open(
      context,
      item: item,
      onUpdated: onUpdated,
    );
  }
}
