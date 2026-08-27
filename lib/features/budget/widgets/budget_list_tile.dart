import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/budget/helpers/budget_amount_format.dart';
import 'package:dayfi/features/budget/models/budget_models.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_instance_display.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_instances.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/pay/widgets/pay_bill_icon_badge.dart';
import 'package:flutter/material.dart';

const _kBudgetLeadingSize = 40.0;
const _kBudgetInnerIconSize = 26.0;

/// Budget row styled like DayFlow / transaction rows — one layout whether or
/// not the DayFlow dashboard instance has loaded yet.
class BudgetListTile extends StatelessWidget {
  const BudgetListTile({
    super.key,
    required this.budget,
    this.dayflowInstance,
    this.bottomMargin = 24,
    this.showSpendProgress = true,
    this.onTap,
  });

  final Budget budget;
  final DayBudgetScheduleInstance? dayflowInstance;
  final double bottomMargin;
  final bool showSpendProgress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final amount = formatBudgetAmount(budget.amount, budget.currency);
    final subtitle = _subtitleFor(budget, dayflowInstance);
    final trailing = _trailingFor(budget, dayflowInstance);
    final timeLineStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontFamily: 'Karla',
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      letterSpacing: -.4,
      height: 1.45,
      color: onSurface.withValues(alpha: 0.65),
    );

    return Semantics(
      button: true,
      label: '${budget.name} $amount ${trailing.label}',
      hint: 'Double tap to view budget details',
      child: InkWell(
        onTap: onTap,
        child: Container(
          key: ValueKey(budget.id),
          margin: EdgeInsets.only(
            bottom: bottomMargin,
            top: 8,
            left: 8,
            right: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _BudgetLeadingIcon(
                    budget: budget,
                    dayflowInstance: dayflowInstance,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: -0.25,
                            height: 1.2,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: timeLineStyle,
                          maxLines: 1,
                        
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 88,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          amount,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Karla',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          trailing.label,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Karla',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -.6,
                            height: 1.45,
                            color: trailing.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (showSpendProgress &&
                  budget.type == 'category_spend' &&
                  budget.progressPercent > 0) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: budget.progressPercent / 100,
                    minHeight: 4,
                    backgroundColor: onSurface.withValues(alpha: 0.08),
                    color: AppColors.primary400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class BudgetListGroupSection extends StatelessWidget {
  const BudgetListGroupSection({
    super.key,
    required this.budgets,
    this.dayflowInstanceFor,
    this.horizontalPadding = 0,
    this.showSpendProgress = true,
    this.onBudgetTap,
  });

  final List<Budget> budgets;
  final DayBudgetScheduleInstance? Function(Budget budget)? dayflowInstanceFor;
  final double horizontalPadding;
  final bool showSpendProgress;
  final void Function(Budget budget)? onBudgetTap;

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            for (int i = 0; i < budgets.length; i++)
              BudgetListTile(
                budget: budgets[i],
                dayflowInstance: dayflowInstanceFor?.call(budgets[i]),
                bottomMargin: i == budgets.length - 1 ? 8 : 24,
                showSpendProgress: showSpendProgress,
                onTap:
                    onBudgetTap != null ? () => onBudgetTap!(budgets[i]) : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _BudgetLeadingIcon extends StatelessWidget {
  const _BudgetLeadingIcon({
    required this.budget,
    this.dayflowInstance,
  });

  final Budget budget;
  final DayBudgetScheduleInstance? dayflowInstance;

  bool get _isAutomation =>
      budget.isManagedByDayFlow || dayflowInstance != null;

  @override
  Widget build(BuildContext context) {
    return PayBillIconBadge(
      innerIconAsset: _isAutomation
          ? 'assets/icons/svgs/automation.svg'
          : _iconAsset(budget, dayflowInstance),
      size: _kBudgetLeadingSize,
      innerSize: _kBudgetInnerIconSize,
    );
  }
}

class _TrailingMeta {
  final String label;
  final Color color;

  const _TrailingMeta({required this.label, required this.color});
}

String _subtitleFor(Budget budget, DayBudgetScheduleInstance? instance) {
  if (budget.isPaused) {
    return '${budget.typeLabel} · Paused';
  }

  final parts = <String>[budget.typeLabel, budget.frequencyLabel];
  final date = _dateLabel(budget, instance);
  if (date != null) parts.add(date);
  return parts.join(' · ');
}

String? _dateLabel(Budget budget, DayBudgetScheduleInstance? instance) {
  if (instance != null) {
    return formatInstanceDueDate(instance.dueAt);
  }
  final next = budget.nextRunLabel;
  if (next == null) return null;
  return next.replaceFirst(RegExp(r'^(Next|Reminder):\s*'), '');
}

_TrailingMeta _trailingFor(
  Budget budget,
  DayBudgetScheduleInstance? instance,
) {
  if (budget.isPaused) {
    return _TrailingMeta(label: 'Paused', color: AppColors.warning600);
  }

  if (instance != null) {
    return _TrailingMeta(
      label: instanceStatusLabel(
        instance.status,
        needsSetup: instance.needsSetup,
      ),
      color: instanceStatusColor(
        instance.status,
        needsSetup: instance.needsSetup,
      ),
    );
  }

  if (budget.isManagedByDayFlow && budget.isActive) {
    return _TrailingMeta(label: 'Scheduled', color: AppColors.teal500);
  }

  final next = budget.nextRunLabel;
  if (next != null) {
    return _TrailingMeta(label: next, color: AppColors.teal500);
  }

  if (budget.type == 'category_spend' && budget.progressPercent > 0) {
    return _TrailingMeta(
      label: '${budget.progressPercent}% spent',
      color: AppColors.primary400,
    );
  }

  return _TrailingMeta(
    label: budget.statusLabel,
    color: budget.isActive ? AppColors.success500 : AppColors.neutral500,
  );
}

String _iconAsset(Budget budget, DayBudgetScheduleInstance? instance) {
  if (instance != null) {
    return instanceTypeIcon(instance.paymentType);
  }
  if (budget.isManagedByDayFlow) {
    return instanceTypeIcon(budget.dayflowPaymentType ?? 'send');
  }

  return switch (budget.type) {
    'bill_reminder' => 'assets/icons/svgs/bill_.svg',
    'recurring_send' => 'assets/icons/svgs/Transfer.svg',
    'invest_allocation' => 'assets/icons/svgs/coin.svg',
    _ => 'assets/icons/svgs/bill_.svg',
  };
}
