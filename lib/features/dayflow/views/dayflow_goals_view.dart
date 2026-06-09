import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:flutter/material.dart';

class DayFlowGoalsView extends StatelessWidget {
  final List<DayFlowGoal> goals;

  const DayFlowGoalsView({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const DayfiScreenAppBar(title: DayFlowCopy.yourGoals),
      body: goals.isEmpty
          ? Center(
              child: Text(
                'No goals yet — ask DayFlow to add one when planning.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 15,
                  color: onSurface.withValues(alpha: 0.55),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
              itemCount: goals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final g = goals[i];
                final monthsLeft = g.targetAmount > g.savedAmount
                    ? ((g.targetAmount - g.savedAmount) / 15000).ceil()
                    : 0;
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
                      Text(
                        g.title,
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: g.progress,
                          minHeight: 8,
                          backgroundColor: onSurface.withValues(alpha: 0.08),
                          color: AppColors.purple500ForTheme(context),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${formatDayFlowAmount(g.savedAmount, 'NGN')} of ${formatDayFlowAmount(g.targetAmount, 'NGN')}',
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 13,
                          color: onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      if (monthsLeft > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Saving ₦15,000 monthly could reach this in ~$monthsLeft months.',
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            fontSize: 12.5,
                            color: AppColors.primary400,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
