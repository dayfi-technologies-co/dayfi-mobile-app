import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:flutter/material.dart';

class DayFlowInsightsView extends StatelessWidget {
  final List<String> insights;
  final String forecast;
  final int healthScore;

  const DayFlowInsightsView({
    super.key,
    required this.insights,
    required this.forecast,
    required this.healthScore,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const DayfiScreenAppBar(title: DayFlowCopy.aiInsights),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: onSurface.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: healthScore / 100,
                        strokeWidth: 5,
                        color: AppColors.primary400,
                        backgroundColor: onSurface.withValues(alpha: 0.08),
                      ),
                      Text(
                        '$healthScore',
                        style: TextStyle(
                          fontFamily: 'FunnelDisplay',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DayFlowCopy.healthScore,
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 13,
                          color: onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                      Text(
                        '$healthScore / 100',
                        style: TextStyle(
                          fontFamily: 'FunnelDisplay',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (forecast.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary400.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DayFlowCopy.forecast,
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    forecast,
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 15,
                      height: 1.4,
                      color: onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          ...insights.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: onSurface.withValues(alpha: 0.06)),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 15,
                    height: 1.45,
                    color: onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
