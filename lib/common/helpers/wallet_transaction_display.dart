import 'package:dayfi/common/helpers/wallet_transaction_labels.dart';
import 'package:dayfi/common/utils/available_balance_calculator.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:flutter/material.dart';

class NgnBankDepositFx {
  final double ngnAmount;
  final double usdCredited;
  /// NGN per 1 USD at deposit time (from ledger), when available.
  final double? rateNgnPerUsd;

  const NgnBankDepositFx({
    required this.ngnAmount,
    required this.usdCredited,
    this.rateNgnPerUsd,
  });

  /// Prefer the rate locked at deposit; fall back to implied rate from rounded USD.
  double get ngnPerUsd =>
      rateNgnPerUsd ??
      (usdCredited > 0 ? ngnAmount / usdCredited : 0);
}

/// USD wallet → local bank/mobile payout (Yellow Card, Opay, etc.).
class LocalPayoutProfile {
  final bool isPayout;
  final double? usdSend;
  final double? localReceive;
  final String localCurrency;
  final String? network;

  const LocalPayoutProfile({
    required this.isPayout,
    this.usdSend,
    this.localReceive,
    this.localCurrency = 'NGN',
    this.network,
  });

  static const LocalPayoutProfile none = LocalPayoutProfile(isPayout: false);

  bool get hasUsdSend => usdSend != null && usdSend! > 0;

  bool get hasLocalReceive => localReceive != null && localReceive! > 0;

  double? get ngnPerUsd =>
      hasUsdSend && hasLocalReceive ? localReceive! / usdSend! : null;
}

/// Shared labels, colors, and formatting for wallet transaction rows.
class WalletTransactionDisplay {
  static const String conversionIconAsset = 'assets/icons/svgs/swap_c.svg';
  static const String investmentIconAsset = 'assets/icons/svgs/clock-dollar.svg';
  static const String dayEarnIconAsset = 'assets/icons/svgs/coin.svg';
  static const String dayFlowIconAsset = 'assets/icons/svgs/router.svg';
  static const Color conversionIconColor = AppColors.orange500;
  static const Color investmentIconColor = AppColors.primary400;
  static const Color dayEarnIconColor = AppColors.warning600;
  static const Color dayFlowIconColor = AppColors.pink500;

  static String effectiveStatus(WalletTransaction transaction) {
    return AvailableBalanceCalculator.getEffectiveStatus(transaction);
  }

  static bool isCurrencyConversion(WalletTransaction transaction) {
    final reason = (transaction.reason ?? '').toLowerCase();
    final name = transaction.beneficiary.name.toLowerCase();
    return reason.contains('convert') || name.contains('currency conversion');
  }

  static bool isBillPayment(WalletTransaction transaction) =>
      WalletTransactionLabels.isBillPayment(transaction);

  static bool isBillReversal(WalletTransaction transaction) =>
      WalletTransactionLabels.isBillReversal(transaction);

  static bool isNgnBankDeposit(WalletTransaction transaction) {
    if (WalletTransactionLabels.isBillReversal(transaction)) return false;
    if (!WalletTransactionLabels.isCredit(transaction)) return false;
    if (isUsdBankDeposit(transaction)) return false;
    if (transaction.receiveChannel?.toLowerCase() == 'bank') {
      final reason = (transaction.reason ?? '').toLowerCase();
      if (reason.contains('ngn bank') ||
          reason.contains('flutterwave') ||
          (reason.contains('deposit') &&
              reason.contains('ngn') &&
              !reason.contains('usd'))) {
        return true;
      }
    }
    return false;
  }

  static bool isUsdBankDeposit(WalletTransaction transaction) {
    if (WalletTransactionLabels.isBillReversal(transaction)) return false;
    if (!WalletTransactionLabels.isCredit(transaction)) return false;
    final reason = (transaction.reason ?? '').toLowerCase();
    if (reason.contains('usd bank') || reason.contains('wire transfer')) {
      return true;
    }
    if (transaction.receiveChannel?.toLowerCase() != 'bank') return false;
    final currency = (transaction.ledgerCurrency ?? 'USD').toUpperCase();
    return currency == 'USD' &&
        !reason.contains('ngn') &&
        !reason.contains('flutterwave');
  }

  static String humanReason(WalletTransaction transaction) {
    if (WalletTransactionLabels.isBillPayment(transaction) ||
        WalletTransactionLabels.isBillReversal(transaction)) {
      return '';
    }
    if (WalletTransactionLabels.isDebit(transaction)) {
      final status = effectiveStatus(transaction).toLowerCase();
      if (status.contains('payment') ||
          isCrossBorderBankSend(transaction) ||
          RecipientHistoryHelper.parseSendToReason(transaction.reason) != null) {
        return '';
      }
    }
    final raw = transaction.reason?.trim() ?? '';
    if (raw.isEmpty) return raw;
    final lower = raw.toLowerCase();
    if (isNgnBankDeposit(transaction) ||
        lower.contains('flutterwave') ||
        (lower.contains('deposit') &&
            lower.contains('via') &&
            !lower.contains('usd'))) {
      return 'NGN bank deposit';
    }
    if (isUsdBankDeposit(transaction)) {
      return 'USD bank deposit';
    }
    if (lower.contains('sent via') || lower.contains('bill_pay')) return '';
    return capitalizeWords(raw);
  }

  static bool isDepositIncome(WalletTransaction transaction) {
    if (WalletTransactionLabels.isBillReversal(transaction)) return false;
    if (WalletTransactionLabels.isBillPayment(transaction)) return false;
    final status = effectiveStatus(transaction).toLowerCase();
    if (!status.contains('collection')) return false;
    if (isNgnBankDeposit(transaction)) return true;
    final channel = transaction.receiveChannel?.toLowerCase();
    if (channel == 'bank' || channel == 'crypto') return true;
    return transaction.beneficiary.name == 'Wallet Top Up';
  }

  static bool isPlaceholderDetail(String? value) {
    if (value == null || value.trim().isEmpty) return true;
    final normalized = value.trim().toLowerCase();
    return normalized == 'unknown' ||
        normalized == 'n/a' ||
        normalized == 'unknown network';
  }

  /// USD send stored in ledger metadata (authoritative when present).
  static double? metadataUsdSend(WalletTransaction transaction) {
    final meta = transaction.ledgerMetadata;
    if (meta != null) {
      for (final key in [
        'sendAmount',
        'send_amount',
        'usdSend',
        'usd_send',
        'sendAmountUsd',
        'send_amount_usd',
      ]) {
        final raw = meta[key];
        if (raw is num && raw > 0) return raw.toDouble();
        final parsed = double.tryParse('${raw ?? ''}');
        if (parsed != null && parsed > 0) return parsed;
      }
    }
    final usdCredited = transaction.usdCredited;
    if (usdCredited != null &&
        usdCredited > 0 &&
        isUsdDebitAmount(usdCredited, transaction)) {
      final fee = feeUsd(transaction);
      if (fee > 0 && usdCredited > fee) {
        final net = double.parse((usdCredited - fee).toStringAsFixed(8));
        if (net > 0 && isUsdDebitAmount(net, transaction)) return net;
      }
      return usdCredited;
    }
    return null;
  }

  /// Whether [amount] is a USD debit (not NGN stored in `send_amount`).
  static bool isUsdDebitAmount(double amount, WalletTransaction transaction) {
    if (amount <= 0) return false;
    final local = transaction.receiveAmount ?? transaction.ngnAmount;
    if (local != null && local >= 100) {
      return amount < local * 0.05;
    }
    return amount < 100_000;
  }

  /// Whether [amount] plausibly represents a local-currency payout (e.g. NGN).
  static bool isLocalPayoutAmount(double amount) => amount >= 50;

  /// Platform / transfer fee in USD (ledger metadata or API `fees` column).
  static double feeUsd(WalletTransaction transaction) {
    final fromRow = transaction.fee;
    if (fromRow != null && fromRow > 0) return fromRow;
    final meta = transaction.ledgerMetadata?['feeUsd'];
    if (meta is num) return meta.toDouble();
    return double.tryParse('${meta ?? ''}') ?? 0;
  }

  /// Amount delivered to the recipient (excludes platform fee).
  static double? outboundTransferAmount(WalletTransaction transaction) {
    if (WalletTransactionLabels.isCredit(transaction)) return null;

    final ledger = (transaction.ledgerCurrency ?? 'USD').toUpperCase();

    final metaUsd = metadataUsdSend(transaction);
    if (metaUsd != null) return metaUsd;

    final raw = transaction.sendAmount;
    if (raw == null || raw <= 0) return null;

    // USD wallet rows sometimes store NGN payout in send_amount — never show as $.
    if (ledger == 'USD' &&
        isLocalPayoutAmount(raw) &&
        isCrossBorderBankSend(transaction) &&
        !isUsdDebitAmount(raw, transaction)) {
      final derived = _deriveUsdFromCrossBorder(transaction);
      if (derived != null && derived > 0) return derived;
      return null;
    }

    final fee = feeUsd(transaction);
    if (fee > 0 &&
        raw > fee &&
        isUsdDebitAmount(raw, transaction)) {
      final net = double.parse((raw - fee).toStringAsFixed(8));
      if (net > 0) return net;
    }
    if (ledger != 'USD' || isUsdDebitAmount(raw, transaction)) return raw;
    return _deriveUsdFromCrossBorder(transaction);
  }

  static double? _deriveUsdFromCrossBorder(WalletTransaction transaction) {
    final metaUsd = metadataUsdSend(transaction);
    if (metaUsd != null && metaUsd > 0) return metaUsd;

    final raw = transaction.sendAmount;
    if (raw != null && isUsdDebitAmount(raw, transaction)) return raw;

    final ngn = _resolveLocalReceiveForPayout(transaction, null);
    if (ngn == null || ngn <= 0) return null;

    final metaRate = transaction.ledgerMetadata?['rate'];
    if (metaRate is num && metaRate > 0) {
      final rate = metaRate.toDouble();
      if (rate < 1) return ngn * rate;
      if (rate > 50) return ngn / rate;
    }

    final ngnPerUsd = ngnPerUsdFromTransaction(transaction);
    if (ngnPerUsd != null && ngnPerUsd > 50) {
      return ngn / ngnPerUsd;
    }
    return null;
  }

  /// Total debited from the user's wallet (transfer + fee).
  static double? outboundTotalDebited(WalletTransaction transaction) {
    if (WalletTransactionLabels.isCredit(transaction)) return null;
    final transfer = outboundTransferAmount(transaction);
    if (transfer == null) return transaction.sendAmount;
    final fee = feeUsd(transaction);
    if (fee > 0) return transfer + fee;
    return transfer;
  }

  static bool hasSeparateTransferFee(WalletTransaction transaction) {
    if (WalletTransactionLabels.isCredit(transaction)) return false;
    return feeUsd(transaction) > 0 &&
        (outboundTransferAmount(transaction) ?? 0) > 0;
  }

  /// Ledger stores NGN→USD multiply factor (e.g. 0.000735); invert for display.
  static double? ngnPerUsdFromTransaction(WalletTransaction transaction) {
    final fx = transaction.fxNgnToUsd;
    if (fx == null || fx <= 0) return null;
    if (fx < 1) return 1 / fx;
    return fx;
  }

  static NgnBankDepositFx? ngnBankDepositFx(WalletTransaction transaction) {
    if (!isNgnBankDeposit(transaction)) return null;
    final ngn = transaction.ngnAmount ?? transaction.receiveAmount;
    final usd = transaction.usdCredited ?? transaction.sendAmount;
    if (ngn == null || usd == null || ngn <= 0 || usd <= 0) return null;
    return NgnBankDepositFx(
      ngnAmount: ngn,
      usdCredited: usd,
      rateNgnPerUsd: ngnPerUsdFromTransaction(transaction),
    );
  }

  static String formatNgnPerUsd(double ngnPerUsd) {
    return '\$1 = ₦${formatNumber(ngnPerUsd)}';
  }

  static const String ngnBankDepositRateFootnote =
      'USD wallet credit is rounded to the nearest cent.';

  static String formatNgnUsdPair(double ngnAmount, double usdCredited) {
    return '${formatNgnWhole(ngnAmount)} = \$${formatNumber(usdCredited)}';
  }

  /// Whole-naira display for bill/deposit FX lines (₦100, ₦2,500).
  static String formatNgnWhole(double ngnAmount) {
    final rounded = ngnAmount.round();
    final intPart = rounded.toString();
    final buffer = StringBuffer('₦');
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    return buffer.toString();
  }

  static String formatNgnBankDepositSubtitle(WalletTransaction transaction) {
    final fx = ngnBankDepositFx(transaction);
    if (fx == null) return humanReason(transaction);
    return formatNgnUsdPair(fx.ngnAmount, fx.usdCredited);
  }

  static double? billNgnAmount(WalletTransaction transaction) {
    final usd = billUsdAmount(transaction);

    final direct = transaction.ngnAmount;
    if (direct != null && direct > 0 && _isPlausibleBillNgn(direct, usd)) {
      return direct;
    }

    final meta = transaction.ledgerMetadata;
    if (meta != null) {
      for (final key in [
        'ngnAmount',
        'ngn_amount',
        'originalAmount',
        'billAmount',
      ]) {
        final raw = meta[key];
        double? parsed;
        if (raw is num) parsed = raw.toDouble();
        parsed ??= double.tryParse('${raw ?? ''}');
        if (parsed != null &&
            parsed > 0 &&
            _isPlausibleBillNgn(parsed, usd)) {
          return parsed;
        }
      }
    }
    return null;
  }

  /// Reject USD wallet amounts mistaken for NGN (e.g. 0.07 shown as ₦0.07).
  static bool _isPlausibleBillNgn(double ngn, double? usd) {
    if (ngn >= 50) return true;
    if (usd == null || usd <= 0) return ngn >= 1;
    if (ngn <= usd * 1.5) return false;
    return true;
  }

  static double? billUsdAmount(WalletTransaction transaction) {
    if (isBillReversal(transaction)) {
      return transaction.usdCredited ??
          transaction.receiveAmount ??
          transaction.sendAmount;
    }
    return transaction.sendAmount ??
        transaction.usdCredited ??
        transaction.receiveAmount;
  }

  /// NGN bill face value ↔ USD wallet movement (same shape as bank deposits).
  static NgnBankDepositFx? billPaymentFx(WalletTransaction transaction) {
    if (!isBillPayment(transaction) && !isBillReversal(transaction)) {
      return null;
    }

    final usd = billUsdAmount(transaction);
    if (usd == null || usd <= 0) return null;

    final ngn = billNgnAmount(transaction);
    if (ngn != null && ngn > 0) {
      return NgnBankDepositFx(
        ngnAmount: ngn,
        usdCredited: usd,
        rateNgnPerUsd: ngnPerUsdFromTransaction(transaction),
      );
    }

    final rate = ngnPerUsdFromTransaction(transaction);
    if (rate != null && rate > 10) {
      return NgnBankDepositFx(
        ngnAmount: usd * rate,
        usdCredited: usd,
        rateNgnPerUsd: rate,
      );
    }

    return null;
  }

  static String formatBillPaymentSubtitle(WalletTransaction transaction) {
    final fx = billPaymentFx(transaction);
    if (fx == null) return '';
    return formatNgnWhole(fx.ngnAmount);
  }

  /// Local NGN face value for bill/deposit rows (middle column).
  static String? listLocalAmountText(WalletTransaction transaction) {
    if (isBillPayment(transaction) || isBillReversal(transaction)) {
      final fx = billPaymentFx(transaction);
      if (fx != null) return formatNgnWhole(fx.ngnAmount);
      final customer = WalletTransactionLabels.billCustomerId(transaction);
      if (customer != null && customer.isNotEmpty) return customer;
      return null;
    }
    if (isNgnBankDeposit(transaction)) {
      final fx = ngnBankDepositFx(transaction);
      if (fx != null) return formatNgnWhole(fx.ngnAmount);
    }
    return null;
  }

  /// FX pair shown under the USD amount on the right (before status).
  static String? listAmountFxLine(WalletTransaction transaction) {
    if (isBillPayment(transaction) || isBillReversal(transaction)) {
      final fx = billPaymentFx(transaction);
      if (fx != null) {
        return formatNgnUsdPair(fx.ngnAmount, fx.usdCredited);
      }
      return null;
    }
    if (isNgnBankDeposit(transaction)) {
      final fx = ngnBankDepositFx(transaction);
      if (fx != null) {
        return formatNgnUsdPair(fx.ngnAmount, fx.usdCredited);
      }
    }
    final profile = resolveLocalPayout(transaction);
    if (profile.isPayout && profile.hasLocalReceive && profile.localCurrency == 'NGN') {
      return formatNgnWhole(profile.localReceive!);
    }
    return null;
  }

  /// Secondary amount on list rows (local/other currency below USD primary).
  static String? listSecondaryAmountText(WalletTransaction transaction) {
    final fxLine = listAmountFxLine(transaction);
    if (fxLine == null || fxLine.isEmpty) return null;
    if (fxLine.contains('=')) return fxLine.split('=').first.trim();
    return fxLine;
  }

  /// Prefixed secondary line for list tiles (`~₦1,361`).
  static String? listSecondaryAmountDisplay(WalletTransaction transaction) {
    final text = listSecondaryAmountText(transaction);
    if (text == null || text.isEmpty) return null;
    if (text.startsWith('~')) return text;
    return '~$text';
  }

  /// Canonical USD wallet → local payout resolver (list + details).
  static LocalPayoutProfile resolveLocalPayout(WalletTransaction transaction) {
    if (_isExcludedFromLocalPayout(transaction)) return LocalPayoutProfile.none;
    if (RecipientHistoryHelper.isCryptoTransaction(transaction)) {
      return LocalPayoutProfile.none;
    }
    if (!_hasLocalPayoutSignal(transaction)) return LocalPayoutProfile.none;

    final usdSend = _resolveUsdSendForPayout(transaction);
    final localReceive = _resolveLocalReceiveForPayout(transaction, usdSend);
    final network = _resolvePayoutNetwork(transaction);
    final localCurrency = _resolveLocalCurrency(transaction);

    if (usdSend == null && localReceive == null && network == null) {
      return LocalPayoutProfile.none;
    }

    return LocalPayoutProfile(
      isPayout: true,
      usdSend: usdSend,
      localReceive: localReceive,
      localCurrency: localCurrency,
      network: network,
    );
  }

  static String payoutSendAmountText(WalletTransaction transaction) {
    final profile = resolveLocalPayout(transaction);
    if (profile.hasUsdSend) {
      return '\$${formatNumber(profile.usdSend!)}';
    }
    return amountText(transaction);
  }

  static String? payoutReceiveAmountText(WalletTransaction transaction) {
    final profile = resolveLocalPayout(transaction);
    if (!profile.hasLocalReceive) return null;
    if (profile.localCurrency == 'NGN') {
      return formatNgnWhole(profile.localReceive!);
    }
    return '${currencySymbol(profile.localCurrency)}${formatNumber(profile.localReceive!)}';
  }

  static String? payoutExchangeRateText(WalletTransaction transaction) {
    final profile = resolveLocalPayout(transaction);
    if (!profile.isPayout) return null;
    final rate = _crossBorderRateNgnPerUsd(transaction, profile);
    if (rate == null || rate <= 0) return null;
    return formatNgnPerUsd(rate);
  }

  /// NGN per 1 USD for cross-border wallet sends (list, details, receipts).
  static double? _crossBorderRateNgnPerUsd(
    WalletTransaction transaction, [
    LocalPayoutProfile? profile,
  ]) {
    final resolved = profile ?? resolveLocalPayout(transaction);
    if (resolved.ngnPerUsd != null && resolved.ngnPerUsd! > 0) {
      return resolved.ngnPerUsd;
    }

    final metaRate = transaction.ledgerMetadata?['rate'];
    if (metaRate is num && metaRate > 50) return metaRate.toDouble();

    final ngn =
        resolved.localReceive ??
        crossBorderReceiveNgn(transaction) ??
        ((transaction.receiveAmount ?? 0) >= 50
            ? transaction.receiveAmount
            : null);

    final usd =
        resolved.usdSend ??
        _resolveUsdSendForPayout(transaction) ??
        _deriveUsdFromCrossBorder(transaction);

    if (ngn != null &&
        isLocalPayoutAmount(ngn) &&
        usd != null &&
        usd > 0 &&
        isUsdDebitAmount(usd, transaction)) {
      return ngn / usd;
    }

    return ngnPerUsdFromTransaction(transaction);
  }

  static String? payoutCurrencyLabel(WalletTransaction transaction) {
    final profile = resolveLocalPayout(transaction);
    if (!profile.isPayout) return null;
    if (profile.localCurrency.isNotEmpty && profile.localCurrency != 'USD') {
      return 'USD → ${profile.localCurrency}';
    }
    return 'USD';
  }

  static bool _isExcludedFromLocalPayout(WalletTransaction transaction) {
    if (WalletTransactionLabels.isCredit(transaction)) return true;
    if (isBillPayment(transaction) || isBillReversal(transaction)) return true;
    if (isUsdBankDeposit(transaction) || isNgnBankDeposit(transaction)) {
      return true;
    }
    if (RecipientHistoryHelper.isP2pTransaction(transaction)) return true;
    if (isCurrencyConversion(transaction)) return true;
    if (isDayEarn(transaction) ||
        isDayFlow(transaction) ||
        WalletTransactionLabels.isInvestment(transaction) ||
        WalletTransactionLabels.isBudget(transaction)) {
      return true;
    }
    return false;
  }

  static bool _hasLocalPayoutSignal(WalletTransaction transaction) {
    final parsed = RecipientHistoryHelper.parseSendToReason(transaction.reason);
    if (parsed != null) return true;

    if (RecipientHistoryHelper.transactionRecipientBank(transaction) != null) {
      return true;
    }

    final meta = transaction.ledgerMetadata;
    if (meta != null) {
      final source = '${meta['source'] ?? ''}'.toLowerCase();
      if (source.contains('yellowcard') || source.contains('yellow_card')) {
        return true;
      }
      if ('${meta['receiveCurrency'] ?? ''}'.toUpperCase() == 'NGN') return true;
      if ('${meta['bankName'] ?? ''}'.trim().isNotEmpty) return true;
      if ('${meta['networkId'] ?? ''}'.trim().isNotEmpty) return true;
    }

    final channel = (transaction.sendChannel ?? '').toLowerCase();
    if (channel == 'bank' || channel == 'mobile_money') return true;

    final accountType =
        transaction.source.accountType?.toLowerCase() ??
        transaction.beneficiary.accountType?.toLowerCase() ??
        '';
    if (accountType == 'bank' ||
        accountType == 'mobile_money' ||
        RecipientHistoryHelper.isMobileAccountType(accountType)) {
      return true;
    }

    final status = effectiveStatus(transaction).toLowerCase();
    if (WalletTransactionLabels.isDebit(transaction) &&
        (status.contains('payment') || status.contains('failed'))) {
      final country = transaction.beneficiary.country.trim().toUpperCase();
      if (country == 'NG' || country == 'NIGERIA') {
        final account =
            transaction.source.accountNumber ?? transaction.beneficiary.accountNumber;
        if (account != null && account.trim().isNotEmpty) return true;
      }
      if (!RecipientHistoryHelper.isGenericRecipientName(
        RecipientHistoryHelper.transactionRecipientName(transaction),
      )) {
        return true;
      }
    }

    return _resolveLocalReceiveForPayout(transaction, null) != null;
  }

  static double? _resolveUsdSendForPayout(WalletTransaction transaction) {
    final ledger = (transaction.ledgerCurrency ?? 'USD').toUpperCase();
    if (ledger != 'USD') return null;

    final metaUsd = metadataUsdSend(transaction);
    if (metaUsd != null) return metaUsd;

    final raw = transaction.sendAmount;
    if (raw != null && raw > 0 && isUsdDebitAmount(raw, transaction)) {
      final fee = feeUsd(transaction);
      if (fee > 0 && raw > fee) {
        final net = double.parse((raw - fee).toStringAsFixed(8));
        if (net > 0) return net;
      }
      return raw;
    }

    final local = _resolveLocalReceiveForPayout(transaction, null);
    if (local != null && isLocalPayoutAmount(local)) {
      return _deriveUsdFromCrossBorder(transaction);
    }
    return null;
  }

  static double? _resolveLocalReceiveForPayout(
    WalletTransaction transaction,
    double? usdSend,
  ) {
    final meta = transaction.ledgerMetadata;
    if (meta != null) {
      for (final key in ['receiveAmount', 'ngnAmount', 'ngn_amount']) {
        final raw = meta[key];
        final parsed =
            raw is num
                ? raw.toDouble()
                : double.tryParse('${raw ?? ''}');
        if (parsed != null && isLocalPayoutAmount(parsed)) return parsed;
      }
    }

    final direct = transaction.ngnAmount ?? transaction.receiveAmount;
    if (direct != null && isLocalPayoutAmount(direct)) return direct;

    final ledger = (transaction.ledgerCurrency ?? 'USD').toUpperCase();
    if (ledger == 'USD' && WalletTransactionLabels.isDebit(transaction)) {
      final send = transaction.sendAmount;
      if (send != null &&
          isLocalPayoutAmount(send) &&
          !isUsdDebitAmount(send, transaction)) {
        return send;
      }
    }

    if (meta != null && ledger == 'USD') {
      final sendMeta = meta['sendAmount'];
      final rate = meta['rate'];
      if (sendMeta is num &&
          sendMeta > 0 &&
          isUsdDebitAmount(sendMeta.toDouble(), transaction) &&
          rate is num &&
          rate > 50) {
        final derived = sendMeta.toDouble() * rate.toDouble();
        if (isLocalPayoutAmount(derived)) return derived;
      }
    }

    final usd = usdSend ?? _resolveUsdSendForPayout(transaction);
    final ngnPerUsd = ngnPerUsdFromTransaction(transaction);
    if (usd != null &&
        isUsdDebitAmount(usd, transaction) &&
        ngnPerUsd != null &&
        ngnPerUsd > 50) {
      final derived = usd * ngnPerUsd;
      if (isLocalPayoutAmount(derived)) return derived;
    }

    final metaRate = meta?['rate'];
    if (usd != null &&
        isUsdDebitAmount(usd, transaction) &&
        metaRate is num &&
        metaRate > 50) {
      final derived = usd * metaRate.toDouble();
      if (isLocalPayoutAmount(derived)) return derived;
    }

    return null;
  }

  static String? _resolvePayoutNetwork(WalletTransaction transaction) {
    final bank = RecipientHistoryHelper.transactionRecipientBank(transaction);
    if (bank != null && bank.isNotEmpty) return bank;

    final networkId = transaction.source.networkId ?? transaction.sendNetwork;
    final fromNetwork = RecipientHistoryHelper.normalizeBankDisplayName(
      null,
      networkId: networkId,
    );
    if (fromNetwork.isNotEmpty) return fromNetwork;

    return null;
  }

  static String _resolveLocalCurrency(WalletTransaction transaction) {
    final fromMeta =
        transaction.ledgerMetadata?['receiveCurrency']?.toString().trim().toUpperCase();
    if (fromMeta != null && fromMeta.isNotEmpty) return fromMeta;
    if (transaction.receiveNetwork?.trim().toUpperCase() == 'NGN') return 'NGN';
    return 'NGN';
  }

  /// Network or provider shown immediately before the time on list rows.
  static String? listTimePrefix(WalletTransaction transaction) {
    if (!showsNetworkSubtitle(transaction)) return null;
    final network = listNetworkSubtitle(transaction);
    if (network == null || network.trim().isEmpty) return null;
    return network.trim();
  }

  /// Whether the list row should show a bank / mobile-money / crypto network line.
  static bool showsNetworkSubtitle(WalletTransaction transaction) {
    if (WalletTransactionLabels.isCredit(transaction)) return false;
    if (isBillPayment(transaction) || isBillReversal(transaction)) return false;
    if (isDayEarn(transaction) ||
        isDayFlow(transaction) ||
        WalletTransactionLabels.isInvestment(transaction) ||
        WalletTransactionLabels.isBudget(transaction)) {
      return false;
    }
    if (isNgnBankDeposit(transaction) || isUsdBankDeposit(transaction)) {
      return false;
    }
    if (isCurrencyConversion(transaction)) return false;
    if (RecipientHistoryHelper.isP2pTransaction(transaction)) return false;

    if (RecipientHistoryHelper.isCryptoTransaction(transaction)) return true;
    if (resolveLocalPayout(transaction).isPayout) return true;

    final accountType =
        transaction.source.accountType?.toLowerCase() ??
        transaction.beneficiary.accountType?.toLowerCase() ??
        '';
    if (accountType == 'bank' ||
        accountType == 'mobile_money' ||
        accountType == 'crypto' ||
        RecipientHistoryHelper.isMobileAccountType(accountType)) {
      return true;
    }

    final channel = (transaction.sendChannel ?? '').toLowerCase();
    return channel == 'bank' ||
        channel == 'mobile_money' ||
        channel == 'crypto';
  }

  /// Bank, mobile-money provider, or crypto network under the title.
  static String? listNetworkSubtitle(WalletTransaction transaction) {
    if (!showsNetworkSubtitle(transaction)) return null;
    return outboundNetworkSubtitle(transaction);
  }

  /// Bank, mobile-money provider, or crypto network under the title (not deposits).
  static String? outboundNetworkSubtitle(WalletTransaction transaction) {
    if (RecipientHistoryHelper.isCryptoTransaction(transaction)) {
      final network = RecipientHistoryHelper.cryptoNetworkLabel(transaction);
      if (network.isNotEmpty &&
          !isPlaceholderDetail(network) &&
          network.toLowerCase() != 'unknown') {
        return network;
      }
    }

    final profile = resolveLocalPayout(transaction);
    if (profile.network != null && profile.network!.isNotEmpty) {
      return profile.network;
    }

    return RecipientHistoryHelper.transactionRecipientBank(transaction);
  }

  static String listTimeLine(WalletTransaction transaction) {
    final time = formatTime(transaction.timestamp);
    final prefix = listTimePrefix(transaction);
    if (prefix != null && prefix.isNotEmpty) {
      return '$prefix · $time';
    }
    return time;
  }

  static bool isDayEarn(WalletTransaction transaction) =>
      WalletTransactionLabels.isDayEarn(transaction);

  static bool isDayFlow(WalletTransaction transaction) =>
      WalletTransactionLabels.isDayFlow(transaction);

  /// USD wallet → local bank payout (Yellow Card cross-border send).
  static bool isCrossBorderBankSend(WalletTransaction transaction) {
    return resolveLocalPayout(transaction).isPayout;
  }

  static double? crossBorderReceiveNgn(WalletTransaction transaction) {
    return _resolveLocalReceiveForPayout(transaction, null);
  }

  /// USD wallet debit paying out local currency (e.g. $1 → ₦1,360).
  static bool isUsdWalletLocalPayout(WalletTransaction transaction) {
    final profile = resolveLocalPayout(transaction);
    return profile.isPayout && profile.hasUsdSend && profile.hasLocalReceive;
  }

  static String? crossBorderBankName(WalletTransaction transaction) {
    return RecipientHistoryHelper.transactionRecipientBank(transaction);
  }

  static String crossBorderSendTitle(WalletTransaction transaction) {
    final name = RecipientHistoryHelper.transactionRecipientName(transaction);
    return 'TO ${name.toUpperCase()}';
  }

  static NgnBankDepositFx? crossBorderSendFx(WalletTransaction transaction) {
    final profile = resolveLocalPayout(transaction);
    if (!profile.isPayout ||
        !profile.hasUsdSend ||
        !profile.hasLocalReceive) {
      return null;
    }
    return NgnBankDepositFx(
      ngnAmount: profile.localReceive!,
      usdCredited: profile.usdSend!,
      rateNgnPerUsd: profile.ngnPerUsd ?? ngnPerUsdFromTransaction(transaction),
    );
  }

  static String formatCrossBorderSendSubtitle(WalletTransaction transaction) {
    final fx = crossBorderSendFx(transaction);
    if (fx == null) return '';
    return formatNgnWhole(fx.ngnAmount);
  }

  static String listTitle(WalletTransaction transaction) {
    if (WalletTransactionLabels.isBillReversal(transaction)) {
      return WalletTransactionLabels.listTitle(transaction);
    }
    if (WalletTransactionLabels.isBillPayment(transaction)) {
      return WalletTransactionLabels.listTitle(transaction);
    }

    final sendToTitle = RecipientHistoryHelper.transactionListTitle(transaction);
    if (sendToTitle.isNotEmpty &&
        sendToTitle.toUpperCase().startsWith('TO ') &&
        !sendToTitle.toUpperCase().contains('RECIPIENT')) {
      return sendToTitle;
    }

    if (isCrossBorderBankSend(transaction)) {
      return crossBorderSendTitle(transaction);
    }

    final featureTitle = WalletTransactionLabels.listTitle(transaction);
    if (featureTitle.isNotEmpty) return featureTitle;

    final recipientTitle = RecipientHistoryHelper.transactionListTitle(
      transaction,
    );
    if (recipientTitle.isNotEmpty) return recipientTitle;

    if (isCurrencyConversion(transaction)) {
      final isCollection =
          effectiveStatus(transaction).toLowerCase().contains('collection');
      return isCollection ? 'CURRENCY CONVERSION' : 'TO CURRENCY CONVERSION';
    }

    final effective = effectiveStatus(transaction);
    final isCollection = effective.toLowerCase().contains('collection');
    final isPayment = effective.toLowerCase().contains('payment');

    final isDayfiTransfer =
        RecipientHistoryHelper.isP2pTransaction(transaction) ||
        transaction.source.accountType?.toLowerCase() == 'dayfi' ||
        transaction.beneficiary.accountType?.toLowerCase() == 'dayfi';

    if (isCollection) {
      if (transaction.beneficiary.name == 'Wallet Top Up') {
        if (transaction.receiveChannel?.toLowerCase() == 'crypto') {
          return 'CRYPTO DEPOSIT';
        }
        if (isNgnBankDeposit(transaction)) {
          return 'NGN BANK DEPOSIT';
        }
        if (isUsdBankDeposit(transaction)) {
          return 'USD BANK DEPOSIT';
        }
        return 'WALLET CREDIT';
      }
      if (isDayfiTransfer &&
          transaction.beneficiary.accountNumber != null &&
          transaction.beneficiary.accountNumber!.isNotEmpty) {
        final tag = transaction.beneficiary.accountNumber!;
        final displayTag = tag.startsWith('@') ? tag.substring(1) : tag;
        return 'FROM ${displayTag.toUpperCase()}';
      }
      return 'WALLET CREDIT';
    }

    if (isPayment) {
      final title = RecipientHistoryHelper.transactionListTitle(transaction);
      if (title.isNotEmpty) return title;

      if (isDayfiTransfer) {
        final tag = RecipientHistoryHelper.p2pUsername(transaction) ??
            (transaction.beneficiary.accountNumber != null &&
                    transaction.beneficiary.accountNumber!.isNotEmpty
                ? '@${transaction.beneficiary.accountNumber!.replaceFirst('@', '')}'
                : null);
        if (tag != null) return 'TO ${tag.toUpperCase()}';
      }

      final name = RecipientHistoryHelper.transactionRecipientName(transaction);
      if (!RecipientHistoryHelper.isGenericRecipientName(name)) {
        return 'TO ${name.toUpperCase()}';
      }
      return 'TO ${transaction.beneficiary.name.toUpperCase()}';
    }

    return transaction.beneficiary.name.toUpperCase();
  }

  /// List subtitle: network line only for bank, mobile-money, and crypto payouts.
  static String? listSubtitle(WalletTransaction transaction) {
    return listNetworkSubtitle(transaction);
  }

  /// Collapse duplicate history rows (same send retried / synced twice).
  static String transactionListDedupKey(WalletTransaction transaction) {
    final name =
        RecipientHistoryHelper.transactionRecipientName(transaction)
            .trim()
            .toLowerCase();
    final ts =
        transaction.timestamp.length >= 16
            ? transaction.timestamp.substring(0, 16)
            : transaction.timestamp;
    final amt = transaction.sendAmount ?? transaction.receiveAmount ?? 0;
    final status = effectiveStatus(transaction).toLowerCase();
    final channel = (transaction.sendChannel ?? '').toLowerCase();
    return '$ts|$name|$amt|$status|$channel';
  }

  static int _transactionListQualityScore(WalletTransaction transaction) {
    var score = 0;
    if (RecipientHistoryHelper.parseSendToReason(transaction.reason) != null) {
      score += 10;
    }
    if (RecipientHistoryHelper.transactionRecipientBank(transaction) != null) {
      score += 5;
    }
    if (transaction.ledgerMetadata != null &&
        transaction.ledgerMetadata!.isNotEmpty) {
      score += 3;
    }
    if (!RecipientHistoryHelper.isGenericRecipientName(
      transaction.beneficiary.name,
    )) {
      score += 2;
    }
    return score;
  }

  static List<WalletTransaction> dedupeTransactions(
    List<WalletTransaction> transactions,
  ) {
    final byKey = <String, WalletTransaction>{};
    for (final tx in transactions) {
      final key = transactionListDedupKey(tx);
      final existing = byKey[key];
      if (existing == null ||
          _transactionListQualityScore(tx) >
              _transactionListQualityScore(existing)) {
        byKey[key] = tx;
      }
    }
    return byKey.values.toList();
  }

  static String amountText(WalletTransaction transaction) {
    final payout = resolveLocalPayout(transaction);
    if (payout.isPayout && payout.hasUsdSend) {
      return '\$${formatNumber(payout.usdSend!)}';
    }
    if (isCrossBorderBankSend(transaction)) {
      final usd =
          outboundTransferAmount(transaction) ??
          _deriveUsdFromCrossBorder(transaction) ??
          (transaction.usdCredited != null &&
                  transaction.usdCredited! > 0 &&
                  isUsdDebitAmount(transaction.usdCredited!, transaction)
              ? transaction.usdCredited
              : null);
      if (usd != null && usd > 0) {
        return '\$${formatNumber(usd)}';
      }
      return 'N/A';
    }

    if (isNgnBankDeposit(transaction)) {
      final usd = transaction.usdCredited ?? transaction.sendAmount;
      if (usd != null && usd > 0) {
        return '\$${formatNumber(usd)}';
      }
    }

    final currency = (transaction.ledgerCurrency ?? '').toUpperCase();
    final symbol = currencySymbol(currency);

    if (transaction.receiveAmount != null && transaction.receiveAmount! > 0) {
      // USD wallet debits sometimes store NGN payout in receive_amount.
      if (WalletTransactionLabels.isDebit(transaction) &&
          currency == 'USD' &&
          isLocalPayoutAmount(transaction.receiveAmount!)) {
        final usd =
            outboundTransferAmount(transaction) ??
            _deriveUsdFromCrossBorder(transaction);
        if (usd != null && usd > 0) {
          return '\$${formatNumber(usd)}';
        }
      }
      if (currency.isNotEmpty) {
        return '$symbol${formatNumber(transaction.receiveAmount!)}';
      }
      final fallbackSymbol = currencySymbolFromCode(
        currencyCodeFromCountry(transaction.beneficiary.country),
      );
      return '$fallbackSymbol${formatNumber(transaction.receiveAmount!)}';
    }
    if (transaction.sendAmount != null && transaction.sendAmount! > 0) {
      final outbound = outboundTransferAmount(transaction);
      final amount = outbound ?? transaction.sendAmount!;
      if (currency.isNotEmpty) {
        return '$symbol${formatNumber(amount)}';
      }
      return '₦${formatNumber(amount)}';
    }
    return 'N/A';
  }

  static String statusText(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection':
      case 'success-payment':
        return 'Success';
      case 'pending-collection':
      case 'pending-payment':
        return 'Pending';
      case 'expired-payment':
        return 'Expired';
      case 'failed-collection':
      case 'failed-payment':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection':
      case 'success-payment':
        return AppColors.success500;
      case 'pending-collection':
      case 'pending-payment':
        return AppColors.warning500;
      case 'expired-payment':
      case 'failed-collection':
      case 'failed-payment':
        return AppColors.error500;
      default:
        return AppColors.neutral500;
    }
  }

  static String typeIconAsset(WalletTransaction transaction) {
    if (isCurrencyConversion(transaction)) {
      return conversionIconAsset;
    }
    if (WalletTransactionLabels.isDayEarn(transaction)) {
      return WalletTransactionLabels.isCredit(transaction)
          ? 'assets/icons/svgs/arrow-narrow-down.svg'
          : 'assets/icons/svgs/arrow-narrow-up.svg';
    }
    if (WalletTransactionLabels.isDayFlow(transaction)) {
      return WalletTransactionLabels.isCredit(transaction)
          ? 'assets/icons/svgs/arrow-narrow-down.svg'
          : 'assets/icons/svgs/arrow-narrow-up.svg';
    }
    if (WalletTransactionLabels.isInvestment(transaction)) {
      return investmentIconAsset;
    }
    if (WalletTransactionLabels.isBillReversal(transaction)) {
      return 'assets/icons/svgs/arrow-narrow-down.svg';
    }
    if (WalletTransactionLabels.isBillPayment(transaction)) {
      return 'assets/icons/svgs/arrow-narrow-up.svg';
    }
    if (WalletTransactionLabels.isBudget(transaction)) {
      return 'assets/icons/svgs/arrow-narrow-up.svg';
    }
    if (listTitle(transaction) == 'Wallet Top Up' ||
        transaction.beneficiary.name == 'Wallet Top Up') {
      return 'assets/icons/svgs/arrow-narrow-down.svg';
    }
    if (transaction.status.toLowerCase().contains('collection')) {
      return 'assets/icons/svgs/arrow-narrow-down.svg';
    }
    if (transaction.status.toLowerCase().contains('payment')) {
      return 'assets/icons/svgs/arrow-narrow-up.svg';
    }
    return 'assets/icons/svgs/info-circle.svg';
  }

  static double typeIconHeight(WalletTransaction transaction) {
    if (WalletTransactionLabels.isDayEarn(transaction) ||
        WalletTransactionLabels.isDayFlow(transaction)) {
      return 24;
    }
    if (WalletTransactionLabels.isInvestment(transaction)) return 22;
    if (isCurrencyConversion(transaction)) return 24;
    return 28;
  }

  static Color typeIconColor(WalletTransaction transaction) {
    if (isCurrencyConversion(transaction)) {
      return conversionIconColor;
    }
    if (WalletTransactionLabels.isDayEarn(transaction)) {
      return dayEarnIconColor;
    }
    if (WalletTransactionLabels.isDayFlow(transaction)) {
      return dayFlowIconColor;
    }
    if (WalletTransactionLabels.isInvestment(transaction)) {
      return investmentIconColor;
    }
    if (WalletTransactionLabels.isBillReversal(transaction)) {
      return AppColors.success500;
    }
    if (WalletTransactionLabels.isBillPayment(transaction)) {
      return AppColors.warning500;
    }
    if (listTitle(transaction) == 'Wallet Top Up' ||
        transaction.beneficiary.name == 'Wallet Top Up') {
      return AppColors.success500;
    }
    if (WalletTransactionLabels.isDayEarn(transaction) ||
        WalletTransactionLabels.isDayFlow(transaction)) {
      return WalletTransactionLabels.isCredit(transaction)
          ? AppColors.success500
          : WalletTransactionLabels.isDayEarn(transaction)
              ? dayEarnIconColor
              : dayFlowIconColor;
    }
    if (transaction.status.toLowerCase().contains('collection')) {
      return AppColors.success500;
    }
    if (transaction.status.toLowerCase().contains('payment')) {
      return AppColors.warning500;
    }
    return AppColors.neutral500;
  }

  /// Short label under the amount on transaction details.
  static String detailPrimaryLabel(WalletTransaction transaction) {
    final feature = WalletTransactionLabels.detailHeadline(transaction);
    if (feature.isNotEmpty) return feature;
    if (isCrossBorderBankSend(transaction)) {
      return RecipientHistoryHelper.transactionRecipientName(transaction);
    }
    if (isNgnBankDeposit(transaction)) return 'NGN bank deposit';
    final isCollection =
        effectiveStatus(transaction).toLowerCase().contains('collection');
    if (isCollection) return 'Wallet Top Up';
    return RecipientHistoryHelper.transactionRecipientName(transaction);
  }

  static String formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp).add(const Duration(hours: 1));
      final hour =
          date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (_) {
      return '';
    }
  }

  static String formatNumber(double amount) {
    final formatted = amount.toStringAsFixed(2);
    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';
    final buffer = StringBuffer();
    for (var i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(integerPart[i]);
    }
    return '${buffer.toString()}.$decimalPart';
  }

  static String capitalizeWords(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  static String currencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'NGN':
        return '₦';
      default:
        return r'$';
    }
  }

  static String currencySymbolFromCode(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'NGN':
        return '₦';
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '₦';
    }
  }

  static String currencyCodeFromCountry(String country) {
    switch (country.toUpperCase()) {
      case 'NG':
      case 'NIGERIA':
        return 'NGN';
      case 'US':
      case 'USA':
      case 'UNITED STATES':
        return 'USD';
      case 'GB':
      case 'UK':
        return 'GBP';
      case 'EU':
        return 'EUR';
      default:
        return 'NGN';
    }
  }

  /// Whether a transaction belongs on a specific wallet tab.
  static bool belongsToWallet(WalletTransaction tx, String walletCurrency) {
    final target = walletCurrency.toUpperCase();
    final ledger = (tx.ledgerCurrency ?? '').toUpperCase();
    return ledger.isNotEmpty && ledger == target;
  }

  static Map<String, List<WalletTransaction>> groupByDateLabel(
    List<WalletTransaction> transactions,
  ) {
    final grouped = <String, List<WalletTransaction>>{};
    final dateMap = <String, DateTime>{};

    for (final transaction in transactions) {
      final label = dateLabel(transaction.timestamp);
      final actualDate = _parseDate(transaction.timestamp);
      grouped.putIfAbsent(label, () => []);
      grouped[label]!.add(transaction);
      dateMap[label] = actualDate;
    }

    final keys =
        grouped.keys.toList()
          ..sort((a, b) => dateMap[b]!.compareTo(dateMap[a]!));
    return {for (final key in keys) key: grouped[key]!};
  }

  static String dateLabel(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final transactionDate = DateTime(date.year, date.month, date.day);

      if (transactionDate == today) return 'Today';
      if (transactionDate == yesterday) return 'Yesterday';

      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      final day = date.day;
      return '$day${_ordinalSuffix(day)} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return 'Unknown Date';
    }
  }

  static DateTime _parseDate(String timestamp) {
    try {
      return DateTime.parse(timestamp);
    } catch (_) {
      return DateTime.now();
    }
  }

  static String _ordinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
