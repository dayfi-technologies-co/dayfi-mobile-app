import 'package:dayfi/features/invest/helpers/invest_position_display.dart';
import 'package:dayfi/services/remote/investment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Lock row styled like [WalletTransactionListTile] on the Transactions screen.
class InvestPositionListTile extends StatelessWidget {
  const InvestPositionListTile({
    super.key,
    required this.position,
    this.bottomMargin = 24,
    this.onTap,
  });

  final InvestmentPosition position;
  final double bottomMargin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final title = InvestPositionDisplay.listTitle(position);
    final subtitle = InvestPositionDisplay.listSubtitle(position);
    final time = InvestPositionDisplay.listTime(position);
    final amount = InvestPositionDisplay.amountText(position);
    final statusLabel = InvestPositionDisplay.statusLabel(position);
    final statusColor = InvestPositionDisplay.statusColor(position);

    return Semantics(
      button: true,
      label: 'Lock $title for $amount, $statusLabel',
      hint: 'Double tap to view lock details',
      child: InkWell(
        onTap: onTap,
        child: Container(
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
                      color: InvestPositionDisplay.iconColor,
                    ),
                    SvgPicture.asset(
                      InvestPositionDisplay.iconAsset,
                      height: 22,
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
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Karla',
                        fontSize: 16,
                        letterSpacing: -.2,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'karla',
                        fontWeight: FontWeight.w500,
                        letterSpacing: -.1,
                        height: 1.5,
                        fontSize: 12.5,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(.65),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // if (time.isNotEmpty)
                    //   Text(
                    //     time,
                    //     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    //           fontFamily: 'Karla',
                    //           fontSize: 12.5,
                    //           fontWeight: FontWeight.w500,
                    //           letterSpacing: -.2,
                    //           color: Theme.of(context)
                    //               .colorScheme
                    //               .onSurface
                    //               .withOpacity(0.6),
                    //         ),
                    //   ),
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
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -.6,
                      height: 1.450,
                      color: statusColor,
                    ),
                    textAlign: TextAlign.end,
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

/// Surface card grouping lock rows (matches transaction list groups).
class InvestPositionGroupSection extends StatelessWidget {
  const InvestPositionGroupSection({
    super.key,
    required this.positions,
    this.horizontalPadding = 0,
    this.onPositionTap,
  });

  final List<InvestmentPosition> positions;
  final double horizontalPadding;
  final void Function(InvestmentPosition position)? onPositionTap;

  @override
  Widget build(BuildContext context) {
    if (positions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            for (int i = 0; i < positions.length; i++)
              InvestPositionListTile(
                position: positions[i],
                bottomMargin: i == positions.length - 1 ? 8 : 24,
                onTap:
                    onPositionTap != null
                        ? () => onPositionTap!(positions[i])
                        : null,
              ),
          ],
        ),
      ),
    );
  }
}
