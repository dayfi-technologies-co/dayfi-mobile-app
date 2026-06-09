import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_instances.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';

String instanceStatusLabel(
  DayBudgetInstanceStatus status, {
  bool needsSetup = false,
}) {
  if (needsSetup) return DayFlowCopy.tapToAddDetails;
  switch (status) {
    case DayBudgetInstanceStatus.paid:
      return DayFlowCopy.statusPaid;
    case DayBudgetInstanceStatus.failed:
      return DayFlowCopy.statusFailed;
    case DayBudgetInstanceStatus.overdue:
      return DayFlowCopy.statusOverdue;
    case DayBudgetInstanceStatus.upcoming:
      return DayFlowCopy.statusScheduled;
  }
}

Color instanceStatusColor(
  DayBudgetInstanceStatus status, {
  bool needsSetup = false,
}) {
  if (needsSetup) return AppColors.orange500;
  switch (status) {
    case DayBudgetInstanceStatus.paid:
      return AppColors.success500;
    case DayBudgetInstanceStatus.failed:
    case DayBudgetInstanceStatus.overdue:
      return AppColors.error500;
    case DayBudgetInstanceStatus.upcoming:
      return AppColors.teal500;
  }
}

Color instanceTypeColor(String paymentType) {
  switch (paymentType.toLowerCase()) {
    case 'bill':
      return AppColors.purple500;
    case 'savings':
      return AppColors.primary400;
    default:
      return AppColors.teal500;
  }
}

String instanceTypeIcon(String paymentType) {
  switch (paymentType.toLowerCase()) {
    case 'bill':
      return 'assets/icons/svgs/bill_.svg';
    case 'savings':
      return 'assets/icons/svgs/coin.svg';
    default:
      return 'assets/icons/svgs/Transfer.svg';
  }
}

String formatInstanceSubtitle(DayBudgetScheduleInstance item) {
  final date = formatInstanceDueDate(item.dueAt);
  final hint = item.recipientHint?.trim();

  if (hint != null && hint.isNotEmpty) {
    return '$hint · $date';
  }

  if (item.needsSetup) {
    return '$date · ${DayFlowCopy.tapToAddDetails}';
  }

  switch (item.status) {
    case DayBudgetInstanceStatus.paid:
      return '$date · ${DayFlowCopy.statusPaid}';
    case DayBudgetInstanceStatus.failed:
      return '$date · ${DayFlowCopy.statusFailed}';
    case DayBudgetInstanceStatus.overdue:
      return '$date · ${DayFlowCopy.statusOverdue}';
    case DayBudgetInstanceStatus.upcoming:
      return '$date · ${DayFlowCopy.statusScheduled}';
  }
}
