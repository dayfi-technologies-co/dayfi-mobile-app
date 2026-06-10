import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/dayfi_screen_description.dart';
import 'package:dayfi/features/budget/views/create_budget_view.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/pay/widgets/pay_bill_icon_badge.dart';
import 'package:flutter/material.dart';

/// Choose send or bill automation — same form pattern as budgets.
class CreateDayFlowAutomationTypeView extends StatelessWidget {
  const CreateDayFlowAutomationTypeView({super.key});

  Future<void> _open(BuildContext context, BudgetCreateKind kind) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateBudgetView(
          kind: kind,
          forDayFlowAutomation: true,
        ),
      ),
    );
    if (created == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return DayfiFeatureScaffold(
      title: DayFlowCopy.automatePayment,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DayfiScreenDescription(text: DayFlowCopy.newAutomationIntro),
            const SizedBox(height: 4),
            Center(
              child: Text(
                DayFlowCopy.automationUsdNote,
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: onSurface.withValues(alpha: 0.5),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            _AutomationTypeTile(
              title: 'Send to someone',
              subtitle: 'Repeat sends to a saved recipient',
              innerIconAsset: 'assets/icons/svgs/brand-telegram.svg',
              onTap: () => _open(context, BudgetCreateKind.send),
            ),
            const SizedBox(height: 10),
            _AutomationTypeTile(
              title: 'Pay a bill',
              subtitle: 'Airtime, data, cable, electricity & more',
              innerIconAsset: 'assets/icons/svgs/bill_.svg',
              onTap: () => _open(context, BudgetCreateKind.bill),
            ),
          ],
        ),
      ),
    );
  }
}

class _AutomationTypeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String innerIconAsset;
  final VoidCallback onTap;

  const _AutomationTypeTile({
    required this.title,
    required this.subtitle,
    required this.innerIconAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              PayBillIconBadge(innerIconAsset: innerIconAsset, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 13,
                        color: onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
