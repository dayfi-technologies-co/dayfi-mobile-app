import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/invest/invest_deposit_flow.dart';
import 'package:dayfi/features/invest/models/invest_lock_draft.dart';
import 'package:dayfi/features/invest/views/invest_lock_amount_view.dart';
import 'package:dayfi/features/invest/widgets/invest_lock_step_scaffold.dart';
import 'package:dayfi/services/remote/investment_service.dart';
import 'package:flutter/material.dart';

class InvestLockDurationView extends StatefulWidget {
  final List<InvestmentPlan> plans;
  final InvestmentSummary? summary;
  final bool refreshPlansOnLoad;
  final bool refreshSummaryOnLoad;
  final VoidCallback? onSuccess;
  final bool showBackButton;

  const InvestLockDurationView({
    super.key,
    required this.plans,
    this.summary,
    this.refreshPlansOnLoad = false,
    this.refreshSummaryOnLoad = false,
    this.onSuccess,
    this.showBackButton = true,
  });

  @override
  State<InvestLockDurationView> createState() => _InvestLockDurationViewState();
}

class _InvestLockDurationViewState extends State<InvestLockDurationView> {
  late List<InvestmentPlan> _plans;
  late InvestmentPlan _selected;
  InvestmentSummary? _summary;

  @override
  void initState() {
    super.initState();
    _plans = List<InvestmentPlan>.from(widget.plans);
    _selected = _plans.first;
    _summary = widget.summary;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await InvestDepositFlow.bootstrapLockFlow(
      summary: _summary,
      refreshSummary: widget.refreshSummaryOnLoad,
      refreshPlans: widget.refreshPlansOnLoad,
      onSummaryUpdated: (s) {
        if (mounted) setState(() => _summary = s);
      },
      onPlansUpdated: (plans) {
        if (!mounted) return;
        setState(() {
          _plans = plans;
          _selected = _plans.firstWhere(
            (p) => p.lockDays == _selected.lockDays,
            orElse: () => _plans.first,
          );
        });
      },
    );
  }

  void _continue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvestLockAmountView(
          draft: InvestLockDraft(plan: _selected),
          summary: _summary,
          onSuccess: widget.onSuccess,
          showBackButton: widget.showBackButton,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InvestLockStepScaffold(
      showBackButton: widget.showBackButton,
      step: 0,
      totalSteps: 4,
      title: 'How long do you want to lock funds?',
      subtitle:
          'Choose a lock period. Longer locks earn higher APY on your USD wallet balance.',
      bottomBar: InvestLockStepScaffold.primaryButton(
        context,
        text: 'Continue',
        onPressed: _continue,
      ),
      child: Column(
        children: _plans.map((plan) {
          final selected = plan.lockDays == _selected.lockDays;
          final periodPct = plan.periodReturnPercent > 0
              ? plan.periodReturnPercent
              : InvestmentPlan.computePeriodReturn(
                  plan.apyPercent,
                  plan.lockDays,
                );
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => setState(() => _selected = plan),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary400
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.08),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.label,
                              style: const TextStyle(
                                fontFamily: 'Chirp',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '~${periodPct.toStringAsFixed(2)}% total return for this lock',
                              style: TextStyle(
                                fontFamily: 'Chirp',
                                fontSize: 13,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary400.withValues(alpha: 0.15)
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${plan.apyPercent.toStringAsFixed(1)}% APY',
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? AppColors.primary400
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
