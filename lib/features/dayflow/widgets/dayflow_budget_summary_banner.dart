import 'package:dayfi/common/widgets/dayfi_balance_header.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/daybudget_flow.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:flutter/material.dart';

class DayFlowBudgetSummaryBanner extends StatelessWidget {
  final DayFlowDashboardSnapshot snapshot;
  final VoidCallback? onTap;

  const DayFlowBudgetSummaryBanner({
    super.key,
    required this.snapshot,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final wallet = snapshot.walletBalance;
    final walletCurrency = snapshot.walletCurrency;
    final committed = snapshot.committedThisPeriod;
    final free = snapshot.freeToSpend > 0
        ? snapshot.freeToSpend
        : snapshot.safeToSpend;
    final period = snapshot.budgetPeriodLabel.isNotEmpty
        ? snapshot.budgetPeriodLabel
        : 'this month';
    final planCurrency = snapshot.plan?.currency ?? 'NGN';

    Widget amountRow(
      String label,
      double value,
      String currency, {
      bool emphasize = false,
    }) {
      final parts = dayfiBalanceAmountParts(
        value,
        currencySymbol: currencySymbol(currency),
        currency: currency,
      );
      TextStyle labelStyle = TextStyle(
        fontFamily: 'Chirp',
        fontSize: 13,
        color: onSurface.withValues(alpha: 0.55),
        fontWeight: FontWeight.w500,
      );
      TextStyle valueStyle = TextStyle(
        fontFamily: 'FunnelDisplay',
        fontSize: emphasize ? 20 : 16,
        fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
        color: onSurface,
        height: 1,
      );
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: parts.symbol,
                  style: valueStyle.copyWith(fontSize: emphasize ? 16 : 14),
                ),
                TextSpan(text: parts.integerPart, style: valueStyle),
                if (parts.decimalPart.isNotEmpty)
                  TextSpan(text: '.${parts.decimalPart}', style: valueStyle),
              ],
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap ?? () => DayBudgetFlow.openDashboard(context),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DayFlowCopy.budgetSummaryTitle,
              style: TextStyle(
                fontFamily: 'FunnelDisplay',
                fontSize: 15,
                color: onSurface.withValues(alpha: 0.65),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            amountRow(DayFlowCopy.globalWalletLabel, wallet, walletCurrency),
            const SizedBox(height: 8),
            amountRow(
              '${DayFlowCopy.committedLabel} ($period)',
              committed,
              planCurrency,
            ),
            const SizedBox(height: 8),
            amountRow(
              DayFlowCopy.freeAfterBudgetLabel,
              free,
              planCurrency,
              emphasize: true,
            ),
            if (snapshot.scheduleInstances.upcoming.any((i) => i.needsSetup)) ...[
              const SizedBox(height: 10),
              Text(
                DayFlowCopy.budgetNeedsSetupHint,
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 12,
                  color: AppColors.orange500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
