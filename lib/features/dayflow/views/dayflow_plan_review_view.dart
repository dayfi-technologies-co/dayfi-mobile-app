import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/services/dayflow_local_store.dart';
import 'package:flutter/material.dart';

class DayFlowPlanReviewView extends StatefulWidget {
  final DayFlowPlan plan;
  final String sourcePrompt;

  const DayFlowPlanReviewView({
    super.key,
    required this.plan,
    required this.sourcePrompt,
  });

  @override
  State<DayFlowPlanReviewView> createState() => _DayFlowPlanReviewViewState();
}

class _DayFlowPlanReviewViewState extends State<DayFlowPlanReviewView> {
  late bool _sweepToDayEarn;

  @override
  void initState() {
    super.initState();
    _sweepToDayEarn = widget.plan.sweepToDayEarn;
  }

  Future<void> _approve() async {
    final plan = DayFlowPlan(
      id: widget.plan.id,
      title: widget.plan.title,
      periodLabel: widget.plan.periodLabel,
      totalBudget: widget.plan.totalBudget,
      spent: widget.plan.spent,
      currency: widget.plan.currency,
      summaryLine: widget.plan.summaryLine,
      categories: widget.plan.categories,
      upcoming: widget.plan.upcoming,
      leftover: widget.plan.leftover,
      sweepToDayEarn: _sweepToDayEarn,
    );
    await DayFlowLocalStore.instance.savePlan(plan);
    if (!mounted) return;
    TopSnackbar.show(context, message: 'Plan activated!');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final plan = widget.plan;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Here's your proposed plan",
          style: TextStyle(
            fontFamily: 'FunnelDisplay',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              children: [
                _SectionTitle('Fixed expenses'),
                ...plan.upcoming.map(
                  (p) => _LineItem(
                    label: p.title,
                    value:
                        '${formatDayFlowAmount(p.amount, p.currency)} • ${p.dueLabel}',
                  ),
                ),
                const SizedBox(height: 16),
                _SectionTitle('Variable categories'),
                ...plan.categories.map(
                  (c) => _LineItem(
                    label: c.name,
                    value: formatDayFlowAmount(c.allocated, plan.currency),
                  ),
                ),
                const SizedBox(height: 16),
                _LineItem(
                  label: 'Leftover',
                  value: formatDayFlowAmount(plan.leftover, plan.currency),
                  emphasized: true,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Move excess to DayEarn automatically',
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: onSurface,
                    ),
                  ),
                  value: _sweepToDayEarn,
                  activeThumbColor: AppColors.purple500,
                  onChanged: (v) => setState(() => _sweepToDayEarn = v),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            child: Column(
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: Text(
                    DayFlowCopy.editPlan,
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  text: DayFlowCopy.approveAndActivate,
                  onPressed: _approve,
                  fullWidth: true,
                  height: 48,
                  borderRadius: 40,
                  backgroundColor: AppColors.purple500,
                  textColor: AppColors.neutral0,
                  fontFamily: 'Chirp',
                  fontSize: 17,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Chirp',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _LineItem({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: emphasized ? 16 : 15,
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
                color: onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: emphasized ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: onSurface.withValues(alpha: emphasized ? 1 : 0.72),
            ),
          ),
        ],
      ),
    );
  }
}
