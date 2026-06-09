import 'package:dayfi/common/helpers/wallet_transaction_display.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/invest/helpers/invest_interest_accrual.dart';
import 'package:dayfi/services/remote/investment_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Labels and formatting for investment lock rows (matches transaction list style).
class InvestPositionDisplay {
  static String get iconAsset => WalletTransactionDisplay.investmentIconAsset;
  static Color get iconColor => WalletTransactionDisplay.investmentIconColor;

  static String listTitle(InvestmentPosition position) {
    final name = position.name.trim();
    if (name.isEmpty) return 'INVESTMENT LOCK';
    return name.toUpperCase();
  }

  static String listSubtitle(InvestmentPosition position) {
    final accrued = InvestInterestAccrual.accruedInterest(position);
    final accruedLabel = position.status == 'claimed'
        ? ''
        : ' · ${InvestInterestAccrual.formatAmount(accrued)} earned';
    return 'Locked \$${position.principal.toStringAsFixed(2)} · '
        '${position.lockDays}-day lock · '
        '${position.apyPercent.toStringAsFixed(1)}% APY$accruedLabel';
  }

  static String listTime(InvestmentPosition position) {
    final started = position.startedAt;
    if (started != null) return _formatTime(started);
    final matures = position.maturesAt;
    if (matures != null) {
      return 'Matures ${DateFormat('d MMM yyyy').format(matures.toLocal())}';
    }
    return '';
  }

  static String amountText(InvestmentPosition position) {
    return '\$${position.principal.toStringAsFixed(2)}';
  }

  static String statusLabel(InvestmentPosition position) {
    if (position.status == 'claimed') return 'Claimed';
    if (position.canClaim) return 'Ready to claim';
    if (position.daysRemaining <= 0) return 'Matured';
    return '${position.daysRemaining} days left';
  }

  static Color statusColor(InvestmentPosition position) {
    if (position.canClaim) return AppColors.success500;
    if (position.status == 'claimed') return AppColors.neutral500;
    if (position.daysRemaining <= 0) return AppColors.warning500;
    return AppColors.primary400;
  }

  static String _formatTime(DateTime date) {
    final local = date.toLocal();
    final hour =
        local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
