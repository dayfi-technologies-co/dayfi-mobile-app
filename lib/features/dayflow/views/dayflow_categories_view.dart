import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:flutter/material.dart';

class DayFlowCategoriesView extends StatelessWidget {
  final DayFlowPlan plan;

  const DayFlowCategoriesView({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const DayfiScreenAppBar(title: DayFlowCopy.yourCategories),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
        itemCount: plan.categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final c = plan.categories[i];
          final pct = (c.progress * 100).round().clamp(0, 999);
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: onSurface.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.name,
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                    ),
                    if (c.locked || plan.lockedCategories.contains(c.name))
                      Text(
                        DayFlowCopy.lockedPocket,
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary400,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: c.progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: onSurface.withValues(alpha: 0.08),
                    color: pct >= 90 ? AppColors.orange500 : AppColors.primary400,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${formatDayFlowAmount(c.spent, plan.currency)} spent • ${formatDayFlowAmount(c.remaining, plan.currency)} left • $pct%',
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 13,
                    color: onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
