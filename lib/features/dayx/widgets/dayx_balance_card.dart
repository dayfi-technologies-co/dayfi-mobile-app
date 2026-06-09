import 'package:dayfi/models/wallet_hub.dart';
import 'package:flutter/material.dart';

class DayxBalanceCard extends StatelessWidget {
  final WalletHubSnapshot hub;
  final String? title;

  const DayxBalanceCard({
    super.key,
    required this.hub,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    var rows = hub.displayRows.take(4).toList();

    return Container(
      width: double.infinity,
      // padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        // border: Border.all(
        //   color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        // ),
      ),
      child: Column(
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
          Text(
            hub.totalAvailableBalance.formatted,
            style: const TextStyle(
              fontFamily: 'FunnelDisplay',
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Total available balance',
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'View as ${row.currency}',
                      style: const TextStyle(
                        fontFamily: 'Chirp',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    row.formattedBalance,
                    style: const TextStyle(
                      fontFamily: 'Chirp',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'One global balance — display currencies only',
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 11,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}
