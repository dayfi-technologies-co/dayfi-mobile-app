import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_wallet_balance.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/models/wallet_hub.dart';
import 'package:flutter/material.dart';

/// Always-visible global wallet at the top of DayBudget chat.
/// Budget totals appear only after the user adds items — never from a stale plan.
class DayFlowBudgetStrip extends StatelessWidget {
  final WalletHubSnapshot? hub;
  final DayFlowPlanDraft? draft;

  const DayFlowBudgetStrip({
    super.key,
    required this.hub,
    this.draft,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final walletBalance = dayFlowWalletBalance(hub);
    final budgetCurrency = _draftCurrency(draft);
    final budgetTotal = draft?.totalBudget ?? 0;
    final hasDraft = draft != null && budgetTotal > 0;
    final shortfall = hasDraft
        ? dayFlowBudgetShortfall(
            hub: hub,
            budgetTotal: budgetTotal,
            budgetCurrency: budgetCurrency,
          )
        : 0;
    final insufficient = hasDraft && shortfall > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insufficient
              ? AppColors.orange500.withValues(alpha: 0.45)
              : onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DayFlowCopy.globalWalletLabel,
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatDayFlowAmount(walletBalance, kDayFlowWalletCurrency),
                  style: const TextStyle(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (hasDraft) ...[
            Container(
              width: 1,
              height: 36,
              color: onSurface.withValues(alpha: 0.08),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    draft!.periodLabel,
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDayFlowAmount(budgetTotal, budgetCurrency),
                    style: TextStyle(
                      fontFamily: 'FunnelDisplay',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: insufficient ? AppColors.orange500 : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _draftCurrency(DayFlowPlanDraft? draft) {
    if (draft == null) return kDayFlowWalletCurrency;
    return draft.currency;
  }
}
