import 'package:dayfi/common/utils/ui_helpers.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/dayfi_screen_description.dart';
import 'package:dayfi/features/budget/constants/budget_copy.dart';
import 'package:dayfi/features/budget/views/create_budget_view.dart';
import 'package:dayfi/features/dayflow/daybudget_flow.dart';
import 'package:dayfi/features/pay/widgets/pay_bill_icon_badge.dart';
import 'package:flutter/material.dart';

/// Choose what kind of budget to create.
class CreateBudgetTypeView extends StatelessWidget {
  const CreateBudgetTypeView({super.key});

  Future<void> _open(BuildContext context, BudgetCreateKind kind) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CreateBudgetView(kind: kind)),
    );
    if (created == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _openDayFlowAutomation(BuildContext context) async {
    final created = await DayBudgetFlow.openCreateAutomation(context);
    if (created && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _openOneTimeReminder(BuildContext context) async {
    final kind = await showAppBottomSheet<BudgetCreateKind>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _OneTimeReminderSheet(),
    );
    if (kind != null && context.mounted) {
      await _open(context, kind);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return DayfiFeatureScaffold(
      title: 'New budget',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DayfiScreenDescription(text: BudgetCopy.newBudgetIntro),
            const SizedBox(height: 4),
            Center(
              child: Text(
                BudgetCopy.usdBalanceNote,
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
            _BudgetTypeTile(
              title: 'Automate a payment',
              subtitle: 'Repeat sends or bill autopay — managed in DayFlow',
              innerIconAsset: 'assets/icons/svgs/automation.svg',
              onTap: () => _openDayFlowAutomation(context),
            ),
            const SizedBox(height: 10),
            _BudgetTypeTile(
              title: 'Spending cap',
              subtitle: 'Monthly limit — track spending by category',
              innerIconAsset: 'assets/icons/svgs/coin.svg',
              onTap: () => _open(context, BudgetCreateKind.spendingCap),
            ),
            const SizedBox(height: 10),
            _BudgetTypeTile(
              title: 'DayEarn',
              subtitle: 'Auto-save to a pot on a schedule',
              innerIconAsset: 'assets/icons/svgs/clock-dollar.svg',
              onTap: () => _open(context, BudgetCreateKind.dailyEarn),
            ),
            const SizedBox(height: 10),
            _BudgetTypeTile(
              title: 'One-time reminder',
              subtitle: 'Remind yourself to send or pay a bill once',
              innerIconAsset: 'assets/icons/svgs/bolt.svg',
              onTap: () => _openOneTimeReminder(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _OneTimeReminderSheet extends StatelessWidget {
  const _OneTimeReminderSheet();

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'One-time reminder',
                style: TextStyle(
                  fontFamily: 'FunnelDisplay',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose what you want to be reminded about.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 14,
                  color: onSurface.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 16),
              _BudgetTypeTile(
                title: 'Remind me to send',
                subtitle: 'A single send to someone on a date',
                innerIconAsset: 'assets/icons/svgs/brand-telegram.svg',
                onTap: () =>
                    Navigator.pop(context, BudgetCreateKind.oneTimeSend),
              ),
              const SizedBox(height: 10),
              _BudgetTypeTile(
                title: 'Remind me to pay a bill',
                subtitle: 'A single bill payment on a date',
                innerIconAsset: 'assets/icons/svgs/bill_.svg',
                onTap: () =>
                    Navigator.pop(context, BudgetCreateKind.oneTimeBill),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetTypeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String innerIconAsset;
  final VoidCallback onTap;

  const _BudgetTypeTile({
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
