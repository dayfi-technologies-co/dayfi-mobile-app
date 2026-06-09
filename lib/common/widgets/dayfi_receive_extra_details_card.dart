import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Compact key–value rows below the primary copy field on receive tabs.
class DayfiReceiveExtraDetailsCard extends StatelessWidget {
  const DayfiReceiveExtraDetailsCard({
    super.key,
    required this.rows,
  });

  final List<({String label, String value})> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(rows.length, (index) {
          final row = rows[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index < rows.length - 1 ? 12 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    row.label,
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 14,
                      letterSpacing: -.4,
                      fontWeight: FontWeight.w500,
                      color: onSurface.withOpacity(0.65),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    row.value,
                    textAlign: TextAlign.end,
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 15,
                      letterSpacing: -.4,
                      fontWeight: FontWeight.w500,
                      color: onSurface,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
