import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';
import 'package:dayfi/models/wallet_hub.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Pick which of the 4 PRD wallets to debit before Send (Yellow Card / username).
Future<String?> showDebitWalletPicker(BuildContext context) async {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => const _DebitWalletPickerSheet(),
  );
}

class _DebitWalletPickerSheet extends ConsumerWidget {
  const _DebitWalletPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hubState = ref.watch(walletHubProvider);
    final rows = hubState.hub?.displayRows ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                'Pay from which wallet?',
                style: TextStyle(
                  fontFamily: 'FunnelDisplay',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (hubState.isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(rows.length, (i) {
                    final row = rows[i];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DebitRow(
                          row: row,
                          onTap: () {
                            ref.read(selectedDebitCurrencyProvider.notifier).state =
                                row.currency;
                            Navigator.pop(context, row.currency);
                          },
                        ),
                        if (i < rows.length - 1)
                          Divider(
                            height: 1,
                            indent: 62,
                            color: Theme.of(context).dividerColor.withOpacity(0.06),
                          ),
                      ],
                    );
                  }),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DebitRow extends StatelessWidget {
  final WalletDisplayRow row;
  final VoidCallback onTap;

  const _DebitRow({required this.row, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            ClipOval(
              child: SvgPicture.asset(
                row.flagPath,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.name,
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    row.currency,
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              row.formattedBalance,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
