import 'package:dayfi/common/helpers/wallet_transaction_display.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayearn/helpers/dayearn_format.dart';
import 'package:dayfi/services/remote/dayearn_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

/// DayEarn pot activity row styled like [WalletTransactionListTile].
class DayEarnActivityListTile extends StatelessWidget {
  const DayEarnActivityListTile({
    super.key,
    required this.activity,
    this.bottomMargin = 24,
  });

  final DayEarnActivity activity;
  final double bottomMargin;

  bool get _isDebit => activity.type == 'withdraw';

  String get _iconAsset =>
      _isDebit
          ? 'assets/icons/svgs/arrow-narrow-up.svg'
          : 'assets/icons/svgs/arrow-narrow-down.svg';

  String get _amountText {
    final formatted = formatDayEarnAmount(activity.amount, kDayEarnCurrency);
    return '${_isDebit ? '-' : '+'}$formatted';
  }

  String? get _timeText {
    final at = activity.createdAt;
    if (at == null) return null;
    return DateFormat.yMMMd().add_jm().format(at.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final amountColor =
        activity.type == 'interest' ? AppColors.success600 : onSurface;

    return Container(
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
                  color: WalletTransactionDisplay.dayEarnIconColor,
                ),
                SvgPicture.asset(
                  _iconAsset,
                  height: 20,
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
                  activity.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 16,
                    letterSpacing: -.2,
                    fontWeight: FontWeight.w500,
                    color: onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_timeText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _timeText!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -.2,
                      height: 1.45,
                      color: onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _amountText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Completed',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -.6,
                  height: 1.45,
                  color: AppColors.success500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
