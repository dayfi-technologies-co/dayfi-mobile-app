import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/helpers/wallet_transaction_display.dart';
import 'package:dayfi/common/utils/string_utils.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Transaction row styled like the main Transactions screen.
class WalletTransactionListTile extends StatelessWidget {
  const WalletTransactionListTile({
    super.key,
    required this.transaction,
    this.bottomMargin = 24,
    this.onTap,
  });

  final WalletTransaction transaction;
  final double bottomMargin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = WalletTransactionDisplay.effectiveStatus(transaction);
    final title = WalletTransactionDisplay.listTitle(transaction);
    final amount = WalletTransactionDisplay.amountText(transaction);
    final secondaryAmount = WalletTransactionDisplay.listSecondaryAmountDisplay(
      transaction,
    );
    final statusLabel = WalletTransactionDisplay.statusText(status);
    final timeLineStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontFamily: 'Karla',
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      letterSpacing: -.2,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
    );
    final timePrefix = WalletTransactionDisplay.listTimePrefix(transaction);
    final timeLabel = WalletTransactionDisplay.formatTime(
      transaction.timestamp,
    );

    return Semantics(
      button: true,
      label: 'Transaction $title for $amount, $statusLabel',
      hint: 'Double tap to view transaction details',
      child: InkWell(
        onTap:
            onTap ??
            () => appRouter.pushNamed(
              AppRoute.transactionDetailsView,
              arguments: transaction,
            ),
        child: Container(
          key: ValueKey(transaction.id),
          margin: EdgeInsets.only(
            bottom: bottomMargin,
            top: 8,
            left: 8,
            right: 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/svgs/account.svg',
                      height: 40,
                      color: WalletTransactionDisplay.typeIconColor(
                        transaction,
                      ),
                    ),
                    SvgPicture.asset(
                      WalletTransactionDisplay.typeIconAsset(transaction),
                      height: WalletTransactionDisplay.typeIconHeight(
                        transaction,
                      ),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StringUtils.toTitleCase(title),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: -0.25,
                        height: 1.2,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    // const SizedBox(height: 4),
                    if (timePrefix != null && timePrefix.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            StringUtils.toTitleCase(timePrefix),
                            style: timeLineStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),
                          Text(timeLabel, style: timeLineStyle),
                        ],
                      )
                    else
                      Text(timeLabel, style: timeLineStyle),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (secondaryAmount != null &&
                      secondaryAmount.isNotEmpty) ...[
                    Text(
                      secondaryAmount,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Karla',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -.1,
                        height: 1.4,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(.55),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    statusLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -.6,
                      height: 1.450,
                      color: WalletTransactionDisplay.statusColor(status),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Date header + surface card matching [TransactionsView].
class WalletTransactionGroupSection extends StatelessWidget {
  const WalletTransactionGroupSection({
    super.key,
    required this.dateLabel,
    required this.transactions,
    this.horizontalPadding = 18,
  });

  final String dateLabel;
  final List<WalletTransaction> transactions;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: 8,
            top: 16,
          ),
          child: Text(
            dateLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'Karla',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: -.6,
              height: 1.450,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge!.color!.withOpacity(.75),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (int i = 0; i < transactions.length; i++)
                  WalletTransactionListTile(
                    transaction: transactions[i],
                    bottomMargin: i == transactions.length - 1 ? 8 : 24,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
