import 'package:dayfi/features/pay/constants/flutterwave_bill_presets.dart';
import 'package:dayfi/models/wallet_transaction.dart';

/// Labels for wallet history rows that are not P2P / bank sends.
class WalletTransactionLabels {
  static String _haystack(WalletTransaction tx) {
    return [
      tx.id,
      tx.externalReference ?? '',
      tx.reason ?? '',
      tx.activityKind ?? '',
      tx.beneficiary.name,
    ].join(' ').toLowerCase();
  }

  static bool isDayEarn(WalletTransaction tx) {
    final reason = (tx.reason ?? '').toLowerCase();
    final name = tx.beneficiary.name.toLowerCase();
    final id = tx.id.toLowerCase();
    final accountType =
        tx.beneficiary.accountType?.toLowerCase() ??
        tx.source.accountType?.toLowerCase() ??
        '';
    return accountType == 'dayearn' ||
        id.contains('dayearn') ||
        reason.contains('dayearn') ||
        name == 'dayearn' ||
        name.startsWith('dayearn ·');
  }

  static bool isDayFlow(WalletTransaction tx) {
    final reason = (tx.reason ?? '').toLowerCase();
    final name = tx.beneficiary.name.toLowerCase();
    final id = tx.id.toLowerCase();
    final accountType =
        tx.beneficiary.accountType?.toLowerCase() ??
        tx.source.accountType?.toLowerCase() ??
        '';
    return accountType == 'dayflow' ||
        id.contains('dayflow') ||
        reason.contains('dayflow') ||
        reason.contains('set aside for') ||
        reason.contains('returned unused funds') ||
        name == 'dayflow' ||
        name.startsWith('dayflow ·');
  }

  static bool isDebit(WalletTransaction tx) {
    final status = tx.status.toLowerCase();
    return status.contains('payment') ||
        (tx.sendAmount != null && (tx.sendAmount ?? 0) > 0);
  }

  static bool isCredit(WalletTransaction tx) {
    // Cross-border sends store both USD send_amount and local receive_amount.
    if (isDebit(tx)) return false;
    if (isDayEarn(tx)) {
      final reason = (tx.reason ?? '').toLowerCase();
      if (reason.contains('withdrawal from')) return true;
      if (reason.contains('added to') || reason.contains('created')) {
        return false;
      }
    }
    if (isDayFlow(tx)) {
      final reason = (tx.reason ?? '').toLowerCase();
      if (reason.contains('returned unused funds')) return true;
      if (reason.contains('set aside for')) return false;
    }
    final status = tx.status.toLowerCase();
    return status.contains('collection') ||
        (tx.receiveAmount != null && (tx.receiveAmount ?? 0) > 0);
  }

  static bool isInvestment(WalletTransaction tx) {
    if (isDayEarn(tx) || isDayFlow(tx)) return false;
    final reason = (tx.reason ?? '').toLowerCase();
    final name = tx.beneficiary.name.toLowerCase();
    final id = tx.id.toLowerCase();
    return reason.contains('investment') ||
        reason.contains('locked') ||
        name.contains('investment') ||
        id.contains('inv-dep') ||
        id.contains('inv');
  }

  static bool referencesBill(WalletTransaction tx) {
    final hay = _haystack(tx);
    return hay.contains('dayfi-bill') ||
        hay.contains('-bill-') ||
        hay.contains('bill_pay') ||
        hay.contains('bill pay') ||
        (tx.activityKind ?? '').toLowerCase().contains('bill');
  }

  static bool isBillReversal(WalletTransaction tx) {
    if (!isCredit(tx)) return false;
    final hay = _haystack(tx);
    if (!hay.contains('reversal')) return false;
    return referencesBill(tx) ||
        hay.contains('bill_payment_failed') ||
        hay.contains('bill payment failed');
  }

  static bool isBillPayment(WalletTransaction tx) {
    if (isDayEarn(tx) || isDayFlow(tx) || isBillReversal(tx)) return false;
    if (!referencesBill(tx)) return false;
    return isDebit(tx) || !isCredit(tx);
  }

  static bool isBudget(WalletTransaction tx) {
    if (isDayEarn(tx) || isDayFlow(tx)) return false;
    final reason = (tx.reason ?? '').toLowerCase();
    return reason.contains('budget');
  }

  static String? billOriginalReference(WalletTransaction tx) {
    final ref = tx.externalReference?.trim();
    if (ref != null && ref.isNotEmpty) {
      return ref.replaceAll(RegExp(r'-reversal$', caseSensitive: false), '');
    }
    final id = tx.id;
    final match = RegExp(r'(dayfi-bill-[a-f0-9-]+)', caseSensitive: false)
        .firstMatch(id);
    return match?.group(1);
  }

  static String? _metaString(WalletTransaction tx, String key) {
    final value = tx.ledgerMetadata?[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static String billCategoryFromCode(String? code) {
    switch ((code ?? '').toUpperCase()) {
      case 'AIRTIME':
        return 'Airtime Topup';
      case 'MOBILEDATA':
        return 'Data Topup';
      case 'CABLEBILLS':
        return 'Cable TV';
      case 'INTSERVICE':
        return 'Internet';
      case 'UTILITYBILLS':
        return 'Utilities';
      default:
        final raw = (code ?? '').trim();
        if (raw.isEmpty) return 'Bill Topup';
        return raw
            .toLowerCase()
            .split('_')
            .map((part) =>
                part.isEmpty ? part : part[0].toUpperCase() + part.substring(1))
            .join(' ');
    }
  }

  static String _inferActionFromReason(String reason) {
    final lower = reason.toLowerCase();
    if (lower.contains('airtime')) return 'Airtime Topup';
    if (lower.contains('mobile data') || lower.contains('mobiledata')) {
      return 'Data Topup';
    }
    if (lower.contains('cable')) return 'Cable TV';
    if (lower.contains('internet')) return 'Internet';
    if (lower.contains('utility') || lower.contains('electric')) {
      return 'Utilities';
    }
    if (lower.contains(' refund · ')) {
      final head = reason.split('·').first.trim();
      if (head.toLowerCase().endsWith(' refund')) {
        return head.substring(0, head.length - ' refund'.length).trim();
      }
    }
    return 'Bill Topup';
  }

  /// Category action label — e.g. Airtime Topup, Data Topup (never "Bill payment").
  static String billActionLabel(WalletTransaction tx) {
    final fromMeta = billCategoryLabel(tx);
    if (fromMeta != 'Bill Topup') return fromMeta;

    final reason = tx.reason?.trim() ?? '';
    if (reason.isNotEmpty) return _inferActionFromReason(reason);

    final name = tx.beneficiary.name.trim();
    if (name.isNotEmpty &&
        !_isGenericBillName(name) &&
        !name.toLowerCase().endsWith(' refund')) {
      return _inferActionFromReason(name);
    }
    return 'Bill Topup';
  }

  static bool _isGenericBillName(String name) {
    final lower = name.toLowerCase();
    return lower == 'recipient' ||
        lower == 'bill payment' ||
        lower == 'bill topup' ||
        lower == 'wallet top up';
  }

  static String billRefundActionLabel(WalletTransaction tx) {
    return '${billActionLabel(tx)} Refund';
  }

  static String? billCategoryCode(WalletTransaction tx) {
    return _metaString(tx, 'categoryCode');
  }

  static String billCategoryLabel(WalletTransaction tx) {
    return billCategoryFromCode(billCategoryCode(tx));
  }

  static String? billProviderName(WalletTransaction tx) {
    final raw = _metaString(tx, 'billerName') ?? _metaString(tx, 'itemName');
    if (raw == null || raw.trim().isEmpty) return null;
    return formatBillBillerLabel(raw);
  }

  static String billPayLabel(WalletTransaction tx) {
    final provider = billProviderName(tx);
    final category = billCategoryLabel(tx);
    if (provider != null &&
        provider.isNotEmpty &&
        !provider.toLowerCase().contains(category.toLowerCase())) {
      return '$provider $category';
    }
    if (provider != null && provider.isNotEmpty) return provider;
    if (category != 'Bill Topup') return category;
    return 'Bill Topup';
  }

  static String billerDisplayName(WalletTransaction tx) {
    final name = tx.beneficiary.name.trim();
    final lower = name.toLowerCase();
    if (name.isNotEmpty &&
        !_isGenericBillName(name) &&
        !lower.endsWith(' refund')) {
      return formatBillBillerLabel(
        name.replaceAll(RegExp(r'\s+refund$', caseSensitive: false), ''),
      );
    }

    final reason = tx.reason?.trim() ?? '';
    if (reason.toLowerCase().contains(' refund · ')) {
      final parts = reason.split('·');
      if (parts.length > 1) {
        return formatBillBillerLabel(parts.sublist(1).join('·').trim());
      }
    }
    if (reason.contains('·')) {
      final head = reason.split('·').first.trim();
      if (head.toLowerCase().endsWith(' refund')) {
        return formatBillBillerLabel(
          head.substring(0, head.length - ' refund'.length).trim(),
        );
      }
      if (!head.toLowerCase().contains('sent via')) {
        return formatBillBillerLabel(head);
      }
    }
    if (reason.isNotEmpty && !reason.toLowerCase().contains('sent via')) {
      return formatBillBillerLabel(
        reason.replaceAll(RegExp(r'\s+refund$', caseSensitive: false), ''),
      );
    }

    final provider = billProviderName(tx);
    final action = billActionLabel(tx);
    if (provider != null &&
        provider.isNotEmpty &&
        !provider.toLowerCase().contains(action.toLowerCase())) {
      return '$provider $action';
    }
    return action;
  }

  static String? billCustomerId(WalletTransaction tx) {
    final fromMeta = _metaString(tx, 'customerId');
    if (fromMeta != null) return fromMeta;

    final reason = tx.reason?.trim() ?? '';
    if (!reason.contains('·')) return null;
    if (reason.toLowerCase().contains(' refund · ')) return null;
    final parts = reason.split('·');
    if (parts.length < 2) return null;
    final customer = parts.sublist(1).join('·').trim();
    return customer.isEmpty ? null : customer;
  }

  static String formatBillReason(WalletTransaction tx) {
    final biller = billerDisplayName(tx);
    final customer = billCustomerId(tx);
    if (customer != null) return '$biller · $customer';
    return biller;
  }

  static String billListTitle(WalletTransaction tx) {
    if (isBillReversal(tx)) {
      return billRefundActionLabel(tx).toUpperCase();
    }
    final provider = billProviderName(tx);
    final action = billActionLabel(tx);
    if (provider != null &&
        provider.isNotEmpty &&
        !provider.toLowerCase().contains(action.toLowerCase())) {
      return '$provider $action'.toUpperCase();
    }
    return action.toUpperCase();
  }

  static String billDetailHeadline(WalletTransaction tx) {
    if (isBillReversal(tx)) return billRefundActionLabel(tx);
    return billerDisplayName(tx);
  }

  static String billSendTypeLabel(WalletTransaction tx) {
    if (isBillReversal(tx)) return billRefundActionLabel(tx);
    return billActionLabel(tx);
  }

  static String? _potOrFlowName(WalletTransaction tx) {
    final reason = tx.reason?.trim() ?? '';
    final account = tx.beneficiary.accountNumber?.trim();
    if (account != null && account.isNotEmpty && account != 'N/A') {
      return account;
    }
    final dayEarnMatch = RegExp(
      r'(?:added to|withdrawal from|created)\s+(.+?)\s+dayearn',
      caseSensitive: false,
    ).firstMatch(reason);
    if (dayEarnMatch != null) return dayEarnMatch.group(1)?.trim();
    final flowMatch = RegExp(
      r'(?:set aside for|returned unused funds from)\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(reason);
    if (flowMatch != null) return flowMatch.group(1)?.trim();
    final parts = reason.split('·');
    if (parts.length > 1) return parts.last.trim();
    return null;
  }

  static String listTitle(WalletTransaction tx) {
    if (isBillReversal(tx) || isBillPayment(tx)) {
      return billListTitle(tx);
    }
    if (isDayEarn(tx)) {
      return isCredit(tx) ? 'DayEarn Withdrawal' : 'DayEarn Deposit';
    }
    if (isDayFlow(tx)) {
      return isCredit(tx) ? 'DayFlow Refund' : 'DayFlow Lock';
    }
    if (isInvestment(tx)) return 'INVESTMENT LOCK';
    if (isBudget(tx)) return 'BUDGET SPEND';
    return '';
  }

  static String listSubtitle(WalletTransaction tx) {
    if (isBillReversal(tx)) {
      final provider = billProviderName(tx);
      if (provider != null && provider.isNotEmpty) return provider;
      return 'Returned to wallet';
    }
    if (isBillPayment(tx)) {
      final customer = billCustomerId(tx);
      if (customer != null) return customer;
      final provider = billProviderName(tx);
      if (provider != null && provider.isNotEmpty) return provider;
      return '';
    }

    final detail = _potOrFlowName(tx);
    if (isDayEarn(tx) || isDayFlow(tx)) return detail ?? '';
    if (isInvestment(tx) || isBudget(tx)) return '';
    return '';
  }

  static String detailHeadline(WalletTransaction tx) {
    if (isBillReversal(tx) || isBillPayment(tx)) {
      return billDetailHeadline(tx);
    }
    if (isDayEarn(tx)) {
      return isCredit(tx) ? 'DayEarn withdrawal' : 'DayEarn deposit';
    }
    if (isDayFlow(tx)) {
      return isCredit(tx) ? 'DayFlow refund' : 'DayFlow lock';
    }
    if (isInvestment(tx)) return 'Investment lock';
    if (isBudget(tx)) return 'Budget spend';
    return '';
  }

  static String detailDescription(WalletTransaction tx) {
    if (isBillReversal(tx)) {
      final action = billActionLabel(tx);
      return 'Your $action was reversed and the amount was returned to your wallet.';
    }
    final detail = _potOrFlowName(tx);
    if (isDayEarn(tx)) {
      if (isCredit(tx)) {
        return detail != null
            ? 'You moved money from your $detail DayEarn pot back to your wallet.'
            : 'You withdrew funds from DayEarn to your wallet.';
      }
      return detail != null
          ? 'You added money to your $detail DayEarn pot to earn daily interest.'
          : 'You moved money from your wallet into a DayEarn pot.';
    }
    if (isDayFlow(tx)) {
      if (isCredit(tx)) {
        return detail != null
            ? 'Unused funds from your $detail flow were returned to your NGN wallet.'
            : 'Stopped a DayFlow plan and returned remaining funds.';
      }
      return detail != null
          ? 'You locked funds in DayFlow for $detail. This money is set aside for that plan.'
          : 'You set aside money in a DayFlow budget envelope.';
    }
    if (isInvestment(tx)) {
      return 'You locked funds in your investment pocket to earn yield.';
    }
    if (isBillPayment(tx)) {
      final headline = billerDisplayName(tx);
      return 'You paid for $headline from your Dayfi wallet balance.';
    }
    if (isBudget(tx)) {
      return 'Funds were allocated or spent against your budget.';
    }
    return '';
  }

  static String sendTypeLabel(WalletTransaction tx) {
    if (isBillReversal(tx) || isBillPayment(tx)) {
      return billSendTypeLabel(tx);
    }
    if (isDayEarn(tx)) return 'DayEarn';
    if (isDayFlow(tx)) return 'DayFlow';
    if (isInvestment(tx)) return 'Investment';
    if (isBudget(tx)) return 'Budget';
    return '';
  }

  static String statusTimelineTitle(WalletTransaction tx, String amountText) {
    if (isBillReversal(tx)) {
      final action = billRefundActionLabel(tx);
      return 'Your $action was processed and $amountText was returned to your wallet';
    }
    if (isBillPayment(tx)) {
      final headline = billerDisplayName(tx);
      return 'You paid $amountText for $headline';
    }

    final detail = _potOrFlowName(tx);
    if (isDayEarn(tx)) {
      if (isCredit(tx)) {
        return detail != null
            ? 'You received $amountText from $detail DayEarn pot'
            : 'You received $amountText from DayEarn';
      }
      return detail != null
          ? 'You added $amountText to $detail DayEarn pot'
          : 'You added $amountText to DayEarn';
    }
    if (isDayFlow(tx)) {
      if (isCredit(tx)) {
        return detail != null
            ? 'You received $amountText back from $detail'
            : 'DayFlow returned $amountText to your wallet';
      }
      return detail != null
          ? 'You locked $amountText for $detail'
          : 'You set aside $amountText in DayFlow';
    }
    return '';
  }
}
