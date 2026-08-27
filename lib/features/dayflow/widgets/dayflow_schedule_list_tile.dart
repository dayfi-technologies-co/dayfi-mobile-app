import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_instance_display.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_wallet_balance.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/pay/widgets/pay_bill_icon_badge.dart';
import 'package:flutter/material.dart';

const _kDayFlowLeadingSize = 40.0;
const _kDayFlowInnerIconSize = 26.0;

/// Scheduled payment row styled like [WalletTransactionListTile].
class DayFlowScheduleListTile extends StatelessWidget {
  const DayFlowScheduleListTile({
    super.key,
    required this.item,
    this.bottomMargin = 24,
    this.muted = false,
    this.onTap,
  });

  final DayBudgetScheduleInstance item;
  final double bottomMargin;
  final bool muted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final alpha = muted ? 0.45 : 1.0;
    final amount = formatDayFlowAmount(item.amount, kDayFlowWalletCurrency);
    final statusLabel = instanceStatusLabel(
      item.status,
      needsSetup: item.needsSetup,
    );
    final statusColor = instanceStatusColor(
      item.status,
      needsSetup: item.needsSetup,
    );
    final subtitle = formatInstanceSubtitle(item);
    final timeLineStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontFamily: 'Karla',
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      letterSpacing: -.2,
      color: onSurface.withValues(alpha: 0.6),
    );

    return Semantics(
      button: true,
      label: '${item.title} $amount $statusLabel',
      hint: 'Double tap to view scheduled payment details',
      child: InkWell(
        onTap: onTap,
        child: Container(
          key: ValueKey(item.id),
          margin: EdgeInsets.only(
            bottom: bottomMargin,
            top: 8,
            left: 8,
            right: 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: muted ? 0.5 : 1.0,
                child: const PayBillIconBadge(
                  innerIconAsset: 'assets/icons/svgs/automation.svg',
                  size: _kDayFlowLeadingSize,
                  innerSize: _kDayFlowInnerIconSize,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: -0.25,
                        height: 1.2,
                        color: onSurface.withValues(alpha: alpha),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: timeLineStyle!.copyWith(
                        color: onSurface.withValues(alpha: muted ? 0.4 : 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 88,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      amount,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Karla',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: onSurface.withValues(alpha: alpha),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusLabel,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Karla',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -.6,
                        height: 1.45,
                        color: statusColor.withValues(alpha: muted ? 0.65 : 1.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DayFlowScheduleDateGroupSection extends StatelessWidget {
  const DayFlowScheduleDateGroupSection({
    super.key,
    required this.dateLabel,
    required this.items,
    this.horizontalPadding = 18,
    this.muted = false,
    this.onItemTap,
  });

  final String dateLabel;
  final List<DayBudgetScheduleInstance> items;
  final double horizontalPadding;
  final bool muted;
  final void Function(DayBudgetScheduleInstance item)? onItemTap;

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
              height: 1.45,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge!.color!.withValues(alpha: .75),
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
                for (int i = 0; i < items.length; i++)
                  DayFlowScheduleListTile(
                    item: items[i],
                    bottomMargin: i == items.length - 1 ? 8 : 24,
                    muted: muted,
                    onTap:
                        onItemTap != null ? () => onItemTap!(items[i]) : null,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
