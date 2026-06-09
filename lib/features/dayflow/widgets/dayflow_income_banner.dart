import 'package:dayfi/common/widgets/dayfi_balance_header.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:flutter/material.dart';

class DayFlowIncomeBanner extends StatelessWidget {
  final DayFlowIncomeEvent income;
  final VoidCallback onPlan;
  final VoidCallback onDismiss;

  const DayFlowIncomeBanner({
    super.key,
    required this.income,
    required this.onPlan,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final amountParts = dayfiBalanceAmountParts(
      income.amount,
      currencySymbol: currencySymbol(income.currency),
      currency: income.currency,
    );

    TextStyle amountStyle(double size) => TextStyle(
      fontFamily: 'FunnelDisplay',
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: onSurface,
      height: 1,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12, top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        // border: Border.all(color: onSurface.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DayFlowCopy.incomeDetectedTitle,
                    style: TextStyle(
                      fontFamily: 'FunnelDisplay',
                      fontSize: 15,
                      color: onSurface.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: amountParts.symbol,
                          style: amountStyle(18),
                        ),
                        TextSpan(
                          text: amountParts.integerPart,
                          style: amountStyle(20),
                        ),
                        if (amountParts.decimalPart.isNotEmpty)
                          TextSpan(
                            text: '.${amountParts.decimalPart}',
                            style: amountStyle(20),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 34,
                child: FilledButton(
                  onPressed: onPlan,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple500,
                    foregroundColor: AppColors.neutral0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Text(DayFlowCopy.planThisMoney),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
