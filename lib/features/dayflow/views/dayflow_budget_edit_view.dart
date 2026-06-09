import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/dayfi_screen_description.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/daybudget_flow.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_actions.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/widgets/dayflow_schedule_sections.dart';
import 'package:flutter/material.dart';

/// Budget overview — scheduled payments plus spending categories.
class DayFlowBudgetEditView extends StatelessWidget {
  final String monthTitle;
  final double totalIncome;
  final String currency;
  final DayBudgetScheduleInstances scheduleInstances;
  final List<DayFlowCategory> spendingCategories;
  final VoidCallback? onChanged;

  const DayFlowBudgetEditView({
    super.key,
    required this.monthTitle,
    required this.totalIncome,
    required this.currency,
    required this.scheduleInstances,
    this.spendingCategories = const [],
    this.onChanged,
  });

  Future<void> _askAi(BuildContext context, {String? seed}) async {
    final updated = await DayBudgetFlow.openEditChat(
      context,
      initialPrompt: seed,
      onActivated: onChanged,
    );
    if (updated && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _onScheduleTap(
    BuildContext context,
    DayBudgetScheduleInstance item,
  ) async {
    await DayFlowScheduleActions.handleTap(
      context,
      item,
      onUpdated: onChanged,
    );
  }

  Future<void> _editCategory(BuildContext context, DayFlowCategory category) async {
    await _askAi(
      context,
      seed:
          'Update ${category.name} to '
          '${formatDayFlowAmount(category.allocated, currency)} in my budget.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final hasSchedules =
        scheduleInstances.upcoming.isNotEmpty ||
        scheduleInstances.past.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: DayfiScreenAppBar(
        title: DayFlowCopy.editBudget,
        actions: [
          TextButton(
            onPressed: () => _askAi(context),
            child: Text(
              DayFlowCopy.askAi,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontWeight: FontWeight.w700,
                color: AppColors.teal500,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        children: [
          DayfiScreenDescription(
            text: DayFlowCopy.editBudgetDescription,
            bottomSpacing: 14,
          ),
          if (hasSchedules) ...[
            const SizedBox(height: 24),
            DayFlowScheduleSections(
              instances: scheduleInstances,
              onTap: (item) => _onScheduleTap(context, item),
            ),
          ],
          if (spendingCategories.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              DayFlowCopy.spendingCategoriesSection,
              style: TextStyle(
                fontFamily: 'FunnelDisplay',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: onSurface.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 8),
            ...spendingCategories.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () => _editCategory(context, c),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: onSurface.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.name,
                                  style: TextStyle(
                                    fontFamily: 'Chirp',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${formatDayFlowAmount(c.allocated, currency)} · ${DayFlowCopy.spendingPocketHint}',
                                  style: TextStyle(
                                    fontFamily: 'Chirp',
                                    fontSize: 13,
                                    color: onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: onSurface.withValues(alpha: 0.35),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (!hasSchedules && spendingCategories.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                DayFlowCopy.noAutomationsYet,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 14,
                  color: onSurface.withValues(alpha: 0.55),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
