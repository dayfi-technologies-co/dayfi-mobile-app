import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayx/models/dayx_intent.dart';
import 'package:flutter/material.dart';

class DayxSpendingInsightCard extends StatelessWidget {
  final List<DayxSpendingInsight> insights;
  final String? title;

  const DayxSpendingInsightCard({
    super.key,
    required this.insights,
    this.title,
  });

  Color _toneColor(BuildContext context, String tone) {
    switch (tone.toLowerCase()) {
      case 'positive':
        return AppColors.success500;
      case 'warning':
        return AppColors.orange500;
      case 'info':
        return AppColors.primary400;
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35);
    }
  }

  IconData _toneIcon(String tone) {
    switch (tone.toLowerCase()) {
      case 'positive':
        return Icons.trending_down_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'info':
        return Icons.insights_rounded;
      default:
        return Icons.pie_chart_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title!.isNotEmpty) ...[
          Text(
            title!,
            style: const TextStyle(
              fontFamily: 'Chirp',
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
        ],
        ...insights.map((insight) {
          final accent = _toneColor(context, insight.tone);
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accent.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _toneIcon(insight.tone),
                    size: 18,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              insight.title,
                              style: const TextStyle(
                                fontFamily: 'Chirp',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (insight.metric != null &&
                              insight.metric!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                insight.metric!,
                                style: TextStyle(
                                  fontFamily: 'Chirp',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight.message,
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 13,
                          height: 1.35,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
