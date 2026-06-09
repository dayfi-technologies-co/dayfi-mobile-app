import 'package:dayfi/common/helpers/wallet_transaction_display.dart';
import 'package:dayfi/common/helpers/wallet_transaction_labels.dart';
import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/models/wallet_transaction.dart';

/// Copy + detection for USD → NGN Nigerian bank payouts (all banks / mobile).
class NgnBankTransferPartner {
  NgnBankTransferPartner._();

  static const String name = 'Eded Technologies Limited';
  static const String expectedCredit = 'Within 5 minutes';
  static const String successFootnote =
      'Processing partner: Eded Technologies Limited. '
      'Nigerian bank accounts are usually credited within 5 minutes.';

  static bool matchesTransaction(WalletTransaction transaction) {
    if (!WalletTransactionLabels.isDebit(transaction)) return false;
    if (WalletTransactionLabels.isBillPayment(transaction) ||
        WalletTransactionLabels.isBillReversal(transaction)) {
      return false;
    }
    if (RecipientHistoryHelper.isCryptoTransaction(transaction)) return false;
    if (_isDayfiUsernameTransfer(transaction)) return false;
    if (!_isNigeria(transaction.beneficiary.country)) return false;
    if (!_isBankOrMobilePayout(transaction)) return false;

    final ledger = (transaction.ledgerCurrency ?? 'USD').toUpperCase();
    if (ledger != 'USD') return false;

    final profile = WalletTransactionDisplay.resolveLocalPayout(transaction);
    if (profile.isPayout &&
        profile.localCurrency == 'NGN' &&
        (profile.hasUsdSend || profile.hasLocalReceive)) {
      return true;
    }

    if (WalletTransactionDisplay.isCrossBorderBankSend(transaction)) {
      return true;
    }

    final receive = transaction.receiveAmount ?? 0;
    return receive >= 50;
  }

  static bool matchesSendFlow({
    Map<String, dynamic>? selectedData,
    Map<String, dynamic>? recipientData,
  }) {
    final country = _countryFromMaps(selectedData, recipientData);
    if (!_isNigeria(country)) return false;

    final receiveCurrency =
        '${selectedData?['receiveCurrency'] ?? recipientData?['currency'] ?? ''}'
            .trim()
            .toUpperCase();
    if (receiveCurrency != 'NGN') return false;

    final sendCurrency =
        '${selectedData?['sendCurrency'] ?? selectedData?['debitCurrency'] ?? selectedData?['payWithCurrency'] ?? selectedData?['spendCurrency'] ?? ''}'
            .trim()
            .toUpperCase();
    if (sendCurrency != 'USD') return false;

    return _isBankRailFromMaps(selectedData, recipientData);
  }

  static bool _isDayfiUsernameTransfer(WalletTransaction transaction) {
    final type =
        transaction.source.accountType?.toLowerCase() ??
        transaction.beneficiary.accountType?.toLowerCase() ??
        '';
    if (type == 'dayfi') return true;
    return RecipientHistoryHelper.p2pTagFromTransaction(transaction) != null;
  }

  static bool _isBankOrMobilePayout(WalletTransaction transaction) {
    final accountType =
        transaction.source.accountType?.toLowerCase() ??
        transaction.beneficiary.accountType?.toLowerCase() ??
        '';
    if (accountType == 'bank' ||
        accountType == 'mobile_money' ||
        accountType == 'mobile' ||
        accountType == 'phone' ||
        RecipientHistoryHelper.isMobileAccountType(accountType)) {
      return true;
    }

    final channel = (transaction.sendChannel ?? '').toLowerCase();
    return channel == 'bank' ||
        channel == 'mobile_money' ||
        channel == 'p2p';
  }

  static bool _isBankRailFromMaps(
    Map<String, dynamic>? selectedData,
    Map<String, dynamic>? recipientData,
  ) {
    final method =
        '${selectedData?['recipientDeliveryMethod'] ?? ''}'.toLowerCase();
    if (_isBankRailMethod(method)) return true;

    final accountType =
        '${recipientData?['accountType'] ?? selectedData?['accountType'] ?? ''}'
            .toLowerCase();
    return accountType == 'bank' ||
        accountType == 'mobile_money' ||
        accountType == 'mobile' ||
        accountType == 'phone' ||
        RecipientHistoryHelper.isMobileAccountType(accountType);
  }

  static bool _isBankRailMethod(String method) {
    return method == 'bank' ||
        method == 'p2p' ||
        method == 'bank_transfer' ||
        method == 'mobile_money' ||
        method == 'momo' ||
        method == 'mobile' ||
        method == 'eft' ||
        method == 'electronic_funds_transfer';
  }

  static String? _countryFromMaps(
    Map<String, dynamic>? selectedData,
    Map<String, dynamic>? recipientData,
  ) {
    return '${selectedData?['receiveCountry'] ?? selectedData?['receiverCountry'] ?? selectedData?['recipientCountry'] ?? recipientData?['country'] ?? ''}';
  }

  static bool _isNigeria(String? country) {
    final normalized = country?.trim().toUpperCase() ?? '';
    return normalized == 'NG' || normalized == 'NIGERIA';
  }
}
