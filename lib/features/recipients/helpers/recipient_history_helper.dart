import 'package:dayfi/common/helpers/wallet_transaction_display.dart';
import 'package:dayfi/common/helpers/wallet_transaction_labels.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/send/services/ngn_banks_cache.dart';
import 'package:dayfi/features/wallet/constants/global_wallet.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:dayfi/models/payment_response.dart' as payment;
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/services/remote/dayearn_service.dart';

/// Builds recipient rows from wallet history and formats labels for UI.
enum TransactionRecipientKind { p2p, crypto, bank, mobile, other }

class RecipientHistoryHelper {
  RecipientHistoryHelper._();

  /// Canonical types used for dedup and backend saves:
  /// `dayfi`, `crypto`, `bank`, `mobile_money`, `bill`, `dayearn`, `dayflow`.
  static String normalizeAccountType(String? type) {
    switch (type?.toLowerCase()) {
      case 'bill':
      case 'bill_pay':
        return 'bill';
      case 'dayearn':
        return 'dayearn';
      case 'dayflow':
      case 'daybudget':
        return 'dayflow';
      case 'bank':
      case 'bank_transfer':
      case 'eft':
      case 'p2p':
      case 'peer_to_peer':
      case 'peer-to-peer':
        return 'bank';
      case 'dayfi':
      case 'dayfi_tag':
        return 'dayfi';
      case 'crypto':
      case 'cryptocurrency':
        return 'crypto';
      case 'phone':
      case 'mobile':
      case 'mobile_money':
      case 'momo':
      case 'mobilemoney':
        return 'mobile_money';
      default:
        return type?.trim().toLowerCase() ?? 'unknown';
    }
  }

  static bool isBankDeliveryMethod(String? method) {
    switch (method?.toLowerCase()) {
      case 'bank':
      case 'bank_transfer':
      case 'eft':
      case 'p2p':
      case 'peer_to_peer':
      case 'peer-to-peer':
        return true;
      default:
        return false;
    }
  }

  /// Maps Send delivery method → saved recipient account type.
  static String accountTypeFromDeliveryMethod(String? method) {
    if (isBankDeliveryMethod(method)) return 'bank';
    switch (method?.toLowerCase()) {
      case 'dayfi_tag':
      case 'dayfi':
        return 'dayfi';
      case 'crypto':
      case 'cryptocurrency':
        return 'crypto';
      default:
        return 'mobile_money';
    }
  }

  static bool isMobileAccountType(String? type) {
    switch (normalizeAccountType(type)) {
      case 'mobile_money':
        return true;
      default:
        return false;
    }
  }

  static bool isP2pTransaction(WalletTransaction transaction) {
    final reason = (transaction.reason ?? '').toLowerCase();
    if (reason.contains('via p2p') || reason.contains('p2p:')) return true;
    if (transaction.id.toLowerCase().contains('p2p')) return true;
    if (transaction.source.accountType?.toLowerCase() == 'dayfi' ||
        transaction.beneficiary.accountType?.toLowerCase() == 'dayfi') {
      return true;
    }
    return p2pTagFromTransaction(transaction) != null;
  }

  static bool isCryptoTransaction(WalletTransaction transaction) {
    if (transaction.sendChannel?.toLowerCase() == 'crypto') return true;
    if (transaction.source.accountType?.toLowerCase() == 'crypto') return true;
    final reason = (transaction.reason ?? '').toLowerCase();
    if (reason.contains('send usdc') ||
        reason.contains('send eurc') ||
        reason.contains('crypto')) {
      return true;
    }
    final name = transaction.beneficiary.name.trim();
    return name.length >= 20 && _looksLikeBlockchainAddress(name);
  }

  static TransactionRecipientKind transactionKind(WalletTransaction transaction) {
    if (isP2pTransaction(transaction)) return TransactionRecipientKind.p2p;
    if (isCryptoTransaction(transaction)) return TransactionRecipientKind.crypto;
    final type = transaction.source.accountType?.toLowerCase() ?? '';
    if (type == 'bank') return TransactionRecipientKind.bank;
    if (type == 'phone' ||
        type == 'mobile' ||
        type == 'mobile_money' ||
        type == 'momo') {
      return TransactionRecipientKind.mobile;
    }
    return TransactionRecipientKind.other;
  }

  static String? inferLedgerCurrency(WalletTransaction transaction) {
    final ledger = transaction.ledgerCurrency?.trim().toUpperCase();
    if (ledger != null && ledger.isNotEmpty) return ledger;
    final reason = (transaction.reason ?? '').toLowerCase();
    if (reason.contains('eurc') || reason.contains('send eur')) return 'EUR';
    if (reason.contains('usdc') ||
        reason.contains('usd sent') ||
        reason.contains('send usd')) {
      return 'USD';
    }
    if (reason.contains('stellar') || reason.contains('crypto')) {
      if (reason.contains('eur')) return 'EUR';
      if (reason.contains('usd') || reason.contains('usdc')) return 'USD';
    }
    if (transaction.sendChannel?.toLowerCase() == 'crypto') {
      if (reason.contains('eur')) return 'EUR';
      return 'USD';
    }
    if (reason.contains('ngn') || reason.contains('₦')) return 'NGN';
    if (reason.contains('gbp')) return 'GBP';
    if (isP2pTransaction(transaction) && reason.contains('usd')) return 'USD';
    if (isCryptoTransaction(transaction)) {
      if (reason.contains('eur')) return 'EUR';
      return 'USD';
    }
    return null;
  }

  static bool isOutgoingSend(WalletTransaction transaction) {
    if (isDayflowTransaction(transaction)) return false;
    if (WalletTransactionLabels.isBillPayment(transaction)) return false;
    if (WalletTransactionLabels.isDayEarn(transaction)) return false;
    if (WalletTransactionLabels.isDayFlow(transaction)) return false;
    final status = transaction.status.toLowerCase();
    if (!status.contains('payment')) return false;
    if (isCurrencyConversion(transaction)) return false;
    if (WalletTransactionLabels.isInvestment(transaction)) return false;
    final name = transaction.beneficiary.name.trim().toLowerCase();
    if (name == 'wallet top up' || name == 'currency conversion') return false;
    return true;
  }

  /// DayFlow budget holds (not real transfer recipients).
  static bool isDayflowTransaction(WalletTransaction transaction) {
    final sourceType = transaction.source.accountType?.toLowerCase() ?? '';
    if (sourceType == 'dayflow') return true;
    final beneficiaryType =
        transaction.beneficiary.accountType?.toLowerCase() ?? '';
    if (beneficiaryType == 'dayflow') return true;
    final name = transaction.beneficiary.name.trim().toLowerCase();
    if (name == 'dayflow') return true;
    final reason = (transaction.reason ?? '').toLowerCase();
    if (reason.contains('dayflow') || reason.contains('set aside for')) {
      return true;
    }
    return false;
  }

  static bool isBillRecipient(BeneficiaryWithSource entry) {
    if (normalizeAccountType(entry.source.accountType) == 'bill') return true;
    if (normalizeAccountType(entry.beneficiary.accountType) == 'bill') {
      return true;
    }
    final name = entry.beneficiary.name.trim().toLowerCase();
    return name.contains('airtime') ||
        name.contains('data bundle') ||
        name.contains('data topup') ||
        name.contains('topup');
  }

  static bool isDayflowRecipient(BeneficiaryWithSource entry) {
    if (normalizeAccountType(entry.source.accountType) == 'dayflow') return true;
    if (normalizeAccountType(entry.beneficiary.accountType) == 'dayflow') {
      return true;
    }
    return entry.beneficiary.id.startsWith('daybudget-');
  }

  static bool isDayEarnRecipient(BeneficiaryWithSource entry) {
    if (normalizeAccountType(entry.source.accountType) == 'dayearn') return true;
    if (normalizeAccountType(entry.beneficiary.accountType) == 'dayearn') {
      return true;
    }
    return entry.beneficiary.id.startsWith('dayearn-');
  }

  static bool isFeatureRecipient(BeneficiaryWithSource entry) {
    return isBillRecipient(entry) ||
        isDayEarnRecipient(entry) ||
        isDayflowRecipient(entry);
  }

  /// People tab + Send pickers: username, bank, mobile money, crypto only.
  static bool isSendRecipient(BeneficiaryWithSource entry) {
    if (isFeatureRecipient(entry)) return false;
    switch (normalizeAccountType(entry.source.accountType)) {
      case 'dayfi':
      case 'bank':
      case 'mobile_money':
      case 'crypto':
        return true;
      default:
        return false;
    }
  }

  static bool isHiddenFromSendPicker(BeneficiaryWithSource entry) {
    return !isSendRecipient(entry);
  }

  static bool isHiddenFromPeopleList(BeneficiaryWithSource entry) {
    return !isSendRecipient(entry);
  }

  static List<BeneficiaryWithSource> excludeInternalRecipients(
    List<BeneficiaryWithSource> entries,
  ) {
    return entries.where(isSendRecipient).toList();
  }

  static BeneficiaryWithSource _normalizeRecipientEntry(
    BeneficiaryWithSource entry,
  ) {
    final bank = normalizeBankDisplayName(
      entry.beneficiary.bankName,
      networkId: entry.source.networkId,
    );
    var name = entry.beneficiary.name;
    if (bank.isNotEmpty) {
      final split = splitDisplayName(name);
      if (split.secondary != null &&
          normalizeBankDisplayName(split.secondary) == bank) {
        name = split.primary;
      }
    }
    if (bank.isEmpty) {
      return BeneficiaryWithSource(
        beneficiary: Beneficiary(
          id: entry.beneficiary.id,
          name: name,
          country: entry.beneficiary.country,
          phone: entry.beneficiary.phone,
          address: entry.beneficiary.address,
          dob: entry.beneficiary.dob,
          email: entry.beneficiary.email,
          idNumber: entry.beneficiary.idNumber,
          idType: entry.beneficiary.idType,
          accountNumber: entry.beneficiary.accountNumber,
          accountType: entry.beneficiary.accountType,
          bankName: entry.beneficiary.bankName,
        ),
        source: entry.source,
        ledgerCurrency: entry.ledgerCurrency,
      );
    }
    return BeneficiaryWithSource(
      beneficiary: Beneficiary(
        id: entry.beneficiary.id,
        name: name,
        country: entry.beneficiary.country,
        phone: entry.beneficiary.phone,
        address: entry.beneficiary.address,
        dob: entry.beneficiary.dob,
        email: entry.beneficiary.email,
        idNumber: entry.beneficiary.idNumber,
        idType: entry.beneficiary.idType,
        accountNumber: entry.beneficiary.accountNumber,
        accountType: entry.beneficiary.accountType,
        bankName: bank,
      ),
      source: entry.source,
      ledgerCurrency:
          entry.ledgerCurrency?.trim().isNotEmpty == true
              ? entry.ledgerCurrency
              : (normalizeAccountType(entry.source.accountType) == 'bank' ||
                      normalizeAccountType(entry.source.accountType) ==
                          'mobile_money'
                  ? 'USD'
                  : entry.ledgerCurrency),
    );
  }

  static List<BeneficiaryWithSource> mergeRecipients(
    List<BeneficiaryWithSource> primary,
    List<BeneficiaryWithSource> secondary,
  ) {
    final byKey = <String, BeneficiaryWithSource>{};
    for (final entry in [...primary, ...secondary]) {
      if (isHiddenFromPeopleList(entry)) continue;
      final normalized = _normalizeRecipientEntry(entry);
      final key = peopleListDedupKey(normalized);
      final existing = byKey[key];
      if (existing == null || shouldReplaceRecipient(normalized, existing)) {
        byKey[key] = normalized;
      }
    }
    return byKey.values.toList()
      ..sort((a, b) => a.beneficiary.name.compareTo(b.beneficiary.name));
  }

  static bool isCurrencyConversion(WalletTransaction transaction) {
    final reason = (transaction.reason ?? '').toLowerCase();
    final name = transaction.beneficiary.name.toLowerCase();
    return reason.contains('convert') || name.contains('currency conversion');
  }

  static String displayCountryCode({
    String? beneficiaryCountry,
    String? ledgerCurrency,
    bool forPayout = false,
  }) {
    final country = (beneficiaryCountry ?? '').trim().toUpperCase();
    if (country == 'NIGERIA') return 'NG';
    if (country.length == 2 && (!forPayout || country != 'US' && country != 'EU')) {
      return country;
    }

    if (!forPayout) {
      final currency = (ledgerCurrency ?? '').toUpperCase();
      if (currency.isNotEmpty) {
        return countryForCurrency(currency);
      }
    }

    if (country.isNotEmpty) return country;
    return 'NG';
  }

  /// Parses backend titles like `Send to Kolawole Oluwafemi · OPay`.
  static ({String name, String? bank})? parseSendToReason(String? reason) {
    final raw = reason?.trim() ?? '';
    if (!raw.toLowerCase().startsWith('send to ')) return null;
    final body = raw.substring(8).trim();
    if (body.isEmpty) return null;
    if (body.contains(' · ')) {
      final parts = body.split(' · ');
      final name = parts.first.trim();
      final bank = parts.sublist(1).join(' · ').trim();
      return (
        name: name,
        bank: bank.isNotEmpty ? bank : null,
      );
    }
    return (name: body, bank: null);
  }

  static bool isWalletFundedBankSend(WalletTransaction transaction) {
    return WalletTransactionDisplay.isCrossBorderBankSend(transaction);
  }

  static String? transactionRecipientBank(WalletTransaction transaction) {
    String? raw;

    final fromBeneficiary = transaction.beneficiary.bankName?.trim();
    if (fromBeneficiary != null &&
        fromBeneficiary.isNotEmpty &&
        !WalletTransactionDisplay.isPlaceholderDetail(fromBeneficiary)) {
      raw = fromBeneficiary;
    }

    if (raw == null) {
      final parsed = parseSendToReason(transaction.reason);
      final fromReason = parsed?.bank?.trim();
      if (fromReason != null &&
          fromReason.isNotEmpty &&
          !WalletTransactionDisplay.isPlaceholderDetail(fromReason)) {
        raw = fromReason;
      }
    }

    if (raw == null) {
      final meta = transaction.ledgerMetadata?['bankName']?.toString().trim();
      if (meta != null &&
          meta.isNotEmpty &&
          !WalletTransactionDisplay.isPlaceholderDetail(meta)) {
        raw = meta;
      }
    }

    if (raw == null) {
      final reason = transaction.reason?.trim() ?? '';
      if (reason.contains(' · ')) {
        final bank = reason.split(' · ').last.trim();
        if (bank.isNotEmpty &&
            !WalletTransactionDisplay.isPlaceholderDetail(bank)) {
          raw = bank;
        }
      }
    }

    if (raw == null) {
      final split = splitDisplayName(transaction.beneficiary.name.trim());
      if (split.secondary != null &&
          !WalletTransactionDisplay.isPlaceholderDetail(split.secondary!)) {
        raw = split.secondary;
      }
    }

    if (raw == null) {
      final meta = transaction.ledgerMetadata;
      if (meta != null) {
        for (final key in [
          'networkName',
          'provider',
          'mobileMoneyProvider',
          'bank_name',
        ]) {
          final candidate = meta[key]?.toString().trim();
          if (candidate != null &&
              candidate.isNotEmpty &&
              !WalletTransactionDisplay.isPlaceholderDetail(candidate)) {
            raw = candidate;
            break;
          }
        }
      }
    }

    final networkId = transaction.source.networkId ?? transaction.sendNetwork;
    if (raw == null) {
      final fromNetwork = bankNameFromNetworkId(networkId);
      if (fromNetwork != null &&
          fromNetwork.isNotEmpty &&
          !WalletTransactionDisplay.isPlaceholderDetail(fromNetwork)) {
        raw = fromNetwork;
      }
    }

    if (raw == null) return null;
    return normalizeBankDisplayName(
      raw,
      networkId: networkId,
    );
  }

  static String payoutCountryCode(WalletTransaction transaction) {
    final ben = transaction.beneficiary.country.trim().toUpperCase();
    if (ben == 'NIGERIA') return 'NG';
    if (ben.length == 2 && ben != 'US' && ben != 'EU') return ben;

    final metaCountry =
        transaction.ledgerMetadata?['payoutCountry']?.toString().trim().toUpperCase();
    if (metaCountry != null && metaCountry.length == 2) return metaCountry;

    final recvCur =
        transaction.ledgerMetadata?['receiveCurrency']?.toString().toUpperCase() ??
        transaction.receiveNetwork?.toUpperCase();
    if (recvCur == 'NGN') return 'NG';

    if (isWalletFundedBankSend(transaction)) {
      final ngn =
          transaction.receiveAmount ??
          WalletTransactionDisplay.crossBorderReceiveNgn(transaction);
      if (ngn != null && ngn >= 50) return 'NG';
    }

    return displayCountryCode(
      beneficiaryCountry: transaction.beneficiary.country,
      forPayout: true,
    );
  }

  static String? p2pLegalName(WalletTransaction transaction) {
    final raw = transaction.beneficiary.name.trim();
    if (!isGenericRecipientName(raw)) {
      final split = splitDisplayName(raw);
      if (!split.primary.startsWith('@')) return split.primary;
    }
    return null;
  }

  static String? p2pUsername(WalletTransaction transaction) {
    final tag = p2pTagFromTransaction(transaction);
    if (tag == null || tag.isEmpty) return null;
    return '@$tag';
  }

  static String cryptoAssetLabel(WalletTransaction transaction) {
    final currency = inferLedgerCurrency(transaction) ?? 'USD';
    return currency == 'EUR' ? 'EURC' : 'USDC';
  }

  static String cryptoNetworkLabel(WalletTransaction transaction) {
    final network = transaction.sendNetwork ??
        transaction.source.networkId ??
        transaction.beneficiary.address;
    return _networkLabel(network.toString());
  }

  static String cryptoAddress(WalletTransaction transaction) {
    if (transaction.source.accountNumber?.trim().isNotEmpty == true) {
      return transaction.source.accountNumber!.trim();
    }
    return transaction.beneficiary.name.trim();
  }

  static const String dayfiLogoAsset = 'assets/images/logo.png';

  static bool isDayfiRecipient(BeneficiaryWithSource entry) {
    return normalizeAccountType(entry.source.accountType) == 'dayfi';
  }

  static String flagCountryForRecipient(BeneficiaryWithSource entry) {
    return displayCountryCode(
      beneficiaryCountry: entry.beneficiary.country,
      ledgerCurrency: entry.ledgerCurrency,
    );
  }

  static bool _looksLikeBlockchainAddress(String value) {
    final v = value.trim();
    if (v.startsWith('G') && v.length >= 20) return true;
    if (v.startsWith('0x') && v.length >= 20) return true;
    return v.length >= 32;
  }

  static String? _inferAccountType(
    WalletTransaction transaction, {
    String? accountNumber,
  }) {
    final acct = (accountNumber ?? transaction.source.accountNumber ?? '')
        .trim();
    if (isCryptoTransaction(transaction) ||
        _looksLikeBlockchainAddress(acct) ||
        _looksLikeBlockchainAddress(transaction.beneficiary.name)) {
      return 'crypto';
    }
    if (isP2pTransaction(transaction)) return 'dayfi';
    final type = transaction.source.accountType?.toLowerCase();
    if (type != null && type.isNotEmpty) return type;
    return null;
  }

  static String? p2pTagFromReason(String? reason) {
    final match = RegExp(r'^p2p:@?(.+)$', caseSensitive: false)
        .firstMatch(reason?.trim() ?? '');
    final tag = match?.group(1)?.trim();
    return tag != null && tag.isNotEmpty ? tag : null;
  }

  static String? p2pTagFromTransaction(WalletTransaction transaction) {
    final fromReason = p2pTagFromReason(transaction.reason);
    if (fromReason != null) return fromReason;

    final sourceType = transaction.source.accountType?.toLowerCase();
    final beneficiaryType = transaction.beneficiary.accountType?.toLowerCase();
    if (sourceType == 'dayfi' || beneficiaryType == 'dayfi') {
      final fromSource = transaction.source.accountNumber?.trim();
      if (fromSource != null && fromSource.isNotEmpty) {
        return fromSource.replaceFirst('@', '');
      }
      final fromDayfiId = transaction.source.dayfiId?.trim();
      if (fromDayfiId != null && fromDayfiId.isNotEmpty) {
        return fromDayfiId.replaceFirst('@', '');
      }
      final fromBeneficiary = transaction.beneficiary.accountNumber?.trim();
      if (fromBeneficiary != null && fromBeneficiary.isNotEmpty) {
        return fromBeneficiary.replaceFirst('@', '');
      }
    }

    final name = transaction.beneficiary.name.trim();
    if (name.startsWith('@')) {
      return name.replaceFirst('@', '').split(' · ').first.trim();
    }
    if (name.contains(' · ')) {
      return name.split(' · ').first.replaceFirst('@', '').trim();
    }

    final transferTo = RegExp(
      r'transfer to @?([a-z0-9_]+)',
      caseSensitive: false,
    ).firstMatch(transaction.reason ?? '');
    final tagFromTitle = transferTo?.group(1)?.trim();
    if (tagFromTitle != null && tagFromTitle.isNotEmpty) return tagFromTitle;

    return null;
  }

  static String recipientCountryCode(WalletTransaction transaction) {
    return payoutCountryCode(transaction);
  }

  static bool isGenericRecipientName(String name) {
    final n = name.trim().toLowerCase();
    return n.isEmpty || n == 'recipient' || n == 'wallet top up';
  }

  static ({String primary, String? secondary}) splitDisplayName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.contains(' · ')) {
      final parts = trimmed.split(' · ');
      final tagPart = parts.first.trim();
      final namePart = parts.sublist(1).join(' · ').trim();
      if (tagPart.startsWith('@') && namePart.isNotEmpty) {
        return (primary: namePart, secondary: tagPart);
      }
    }
    if (trimmed.startsWith('@')) {
      return (primary: trimmed, secondary: null);
    }
    return (primary: trimmed, secondary: null);
  }

  static String primaryLabel(Beneficiary beneficiary, payment.Source source) {
    final raw = beneficiary.name.trim();
    final type = normalizeAccountType(source.accountType);

    if (type == 'dayearn') {
      final pot = source.accountNumber?.trim();
      if (pot != null && pot.isNotEmpty) return pot;
    }

    if (type == 'dayflow') {
      if (raw.isNotEmpty && raw.toLowerCase() != 'dayflow') return raw;
      final schedule = source.accountNumber?.trim();
      if (schedule != null && schedule.isNotEmpty) return schedule;
    }

    if (source.accountType?.toLowerCase() == 'dayfi') {
      if (!isGenericRecipientName(raw)) {
        final split = splitDisplayName(raw);
        if (!split.primary.startsWith('@')) return split.primary;
      }
      final tag = source.accountNumber?.trim().replaceFirst('@', '');
      if (tag != null && tag.isNotEmpty) return '@$tag';
    }

    if (source.accountType?.toLowerCase() == 'crypto') {
      final address = source.accountNumber?.trim().isNotEmpty == true
          ? source.accountNumber!.trim()
          : raw;
      return truncateAddress(address);
    }

    if (!isGenericRecipientName(raw)) {
      final split = splitDisplayName(raw);
      return split.primary;
    }

    if (source.accountNumber?.trim().isNotEmpty == true) {
      return source.accountNumber!.trim();
    }
    return raw.isNotEmpty ? raw : 'Recipient';
  }

  static String secondaryLabel(
    Beneficiary beneficiary,
    payment.Source source, {
    String? ledgerCurrency,
  }) {
    final type = normalizeAccountType(source.accountType);
    final currency = (ledgerCurrency ?? '').toUpperCase();

    if (type == 'bill') {
      final customer = source.accountNumber?.trim();
      if (customer != null && customer.isNotEmpty) {
        return '@$customer · Bill pay';
      }
      return 'Bill pay · NGN';
    }

    if (type == 'dayearn') {
      return currency.isNotEmpty ? 'DayEarn · $currency' : 'DayEarn · USD';
    }

    if (type == 'dayflow') {
      return 'DayFlow · NGN';
    }

    if (type == 'dayfi') {
      final split = splitDisplayName(beneficiary.name.trim());
      final tag = source.accountNumber?.trim().replaceFirst('@', '');
      final tagLabel = split.secondary ??
          (tag != null && tag.isNotEmpty ? '@$tag' : 'Username');
      return currency.isNotEmpty ? '$tagLabel · $currency' : tagLabel;
    }

    if (type == 'crypto') {
      final asset = currency == 'EUR' ? 'EURC' : 'USDC';
      final network = _networkLabel(source.networkId);
      return network.isNotEmpty ? 'Crypto · $asset · $network' : 'Crypto · $asset';
    }

    if (type == 'bank') {
      final bank = _bankLabelForEntry(beneficiary, source);
      final country = beneficiary.country.trim().toUpperCase();
      final countrySuffix =
          country.length == 2 ? country : (currency == 'NGN' ? 'NG' : '');
      if (bank.isNotEmpty && countrySuffix.isNotEmpty) {
        return '$bank · $countrySuffix';
      }
      if (bank.isNotEmpty) return bank;
      return currency.isNotEmpty ? 'Bank transfer · $currency' : 'Bank transfer';
    }

    if (type == 'phone' ||
        type == 'mobile' ||
        type == 'mobile_money' ||
        type == 'momo') {
      return currency.isNotEmpty ? 'Mobile money · $currency' : 'Mobile money';
    }

    return currency.isNotEmpty ? currency : 'Transfer';
  }

  static String actionLabelForRecipient(BeneficiaryWithSource entry) {
    if (isBillRecipient(entry)) return 'Pay';
    if (isDayEarnRecipient(entry)) return 'Add';
    if (isDayflowRecipient(entry)) return 'Pay';
    return 'Send';
  }

  static BeneficiaryWithSource fromDayEarnPot(DayEarnPot pot) {
    return BeneficiaryWithSource(
      beneficiary: Beneficiary(
        id: 'dayearn-${pot.id}',
        name: pot.name,
        country: 'US',
        phone: '',
        address: '',
        dob: '',
        email: '',
        idNumber: '',
        idType: 'individual',
        accountNumber: pot.id,
        accountType: 'dayearn',
      ),
      source: payment.Source(
        accountType: 'dayearn',
        accountNumber: pot.name,
        networkId: pot.id,
      ),
      ledgerCurrency: pot.currency.toUpperCase(),
    );
  }

  static BeneficiaryWithSource fromDayBudgetSchedule(
    DayBudgetScheduleInstance item,
  ) {
    final title = item.title.trim().isNotEmpty
        ? item.title.trim()
        : (item.recipientHint ?? 'DayFlow').trim();
    final flowTitle = item.flowTitle?.trim();
    return BeneficiaryWithSource(
      beneficiary: Beneficiary(
        id: 'daybudget-${item.flowId}-${item.scheduleId}',
        name: flowTitle?.isNotEmpty == true ? flowTitle! : title,
        country: 'NG',
        phone: '',
        address: '',
        dob: '',
        email: '',
        idNumber: item.flowId,
        idType: 'individual',
        accountNumber: item.scheduleId,
        accountType: 'dayflow',
      ),
      source: payment.Source(
        accountType: 'dayflow',
        accountNumber: title,
        networkId: '${item.flowId}:${item.scheduleId}',
      ),
      ledgerCurrency: 'NGN',
    );
  }

  static String? _potNameFromReason(String? reason) {
    final match = RegExp(
      r'(?:added to|withdrawal from|created)\s+(.+?)\s+dayearn',
      caseSensitive: false,
    ).firstMatch(reason?.trim() ?? '');
    return match?.group(1)?.trim();
  }

  static String? _flowNameFromReason(String? reason) {
    final match = RegExp(
      r'(?:set aside for|returned unused funds from)\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(reason?.trim() ?? '');
    return match?.group(1)?.trim();
  }

  static BeneficiaryWithSource? _fromBillTransaction(WalletTransaction tx) {
    final label = WalletTransactionLabels.billProviderName(tx) ??
        tx.beneficiary.name.trim();
    if (label.isEmpty) return null;
    final customerId = WalletTransactionLabels.billCustomerId(tx) ??
        tx.source.accountNumber?.trim() ??
        '';
    final billerCode = tx.ledgerMetadata?['billerCode']?.toString() ??
        tx.source.networkId ??
        '';
    return BeneficiaryWithSource(
      beneficiary: Beneficiary(
        id: tx.beneficiary.id.isNotEmpty
            ? tx.beneficiary.id
            : 'bill-$customerId-${label.hashCode}',
        name: label,
        country: 'NG',
        phone: customerId,
        address: '',
        dob: '',
        email: '',
        idNumber: WalletTransactionLabels.billCategoryCode(tx) ?? '',
        idType: 'individual',
        accountNumber: customerId,
        accountType: 'bill',
      ),
      source: payment.Source(
        accountType: 'bill',
        accountNumber: customerId,
        networkId: billerCode,
      ),
      ledgerCurrency: 'NGN',
    );
  }

  static BeneficiaryWithSource? _fromDayEarnTransaction(WalletTransaction tx) {
    final potName = tx.source.accountNumber?.trim() ??
        tx.beneficiary.accountNumber?.trim() ??
        _potNameFromReason(tx.reason) ??
        'DayEarn';
    final potId = tx.ledgerMetadata?['potId']?.toString() ??
        tx.externalReference ??
        potName;
    return BeneficiaryWithSource(
      beneficiary: Beneficiary(
        id: tx.beneficiary.id.isNotEmpty ? tx.beneficiary.id : 'dayearn-$potId',
        name: potName,
        country: 'US',
        phone: '',
        address: '',
        dob: '',
        email: '',
        idNumber: '',
        idType: 'individual',
        accountNumber: potId,
        accountType: 'dayearn',
      ),
      source: payment.Source(
        accountType: 'dayearn',
        accountNumber: potName,
        networkId: potId,
      ),
      ledgerCurrency: inferLedgerCurrency(tx) ?? 'USD',
    );
  }

  static BeneficiaryWithSource? _fromDayFlowTransaction(WalletTransaction tx) {
    final flowName = _flowNameFromReason(tx.reason) ??
        (tx.beneficiary.name.trim().isNotEmpty &&
                tx.beneficiary.name.toLowerCase() != 'dayflow'
            ? tx.beneficiary.name.trim()
            : null) ??
        tx.source.accountNumber?.trim() ??
        'DayFlow';
    final flowKey = tx.externalReference ?? tx.id;
    return BeneficiaryWithSource(
      beneficiary: Beneficiary(
        id: tx.beneficiary.id.isNotEmpty
            ? tx.beneficiary.id
            : 'daybudget-$flowKey',
        name: flowName,
        country: 'NG',
        phone: '',
        address: '',
        dob: '',
        email: '',
        idNumber: '',
        idType: 'individual',
        accountNumber: flowName,
        accountType: 'dayflow',
      ),
      source: payment.Source(
        accountType: 'dayflow',
        accountNumber: flowName,
        networkId: flowKey,
      ),
      ledgerCurrency: 'NGN',
    );
  }

  static BeneficiaryWithSource? fromFeatureTransaction(
    WalletTransaction transaction,
  ) {
    if (WalletTransactionLabels.isBillPayment(transaction)) {
      return _fromBillTransaction(transaction);
    }
    if (WalletTransactionLabels.isDayEarn(transaction) &&
        WalletTransactionLabels.isDebit(transaction)) {
      return _fromDayEarnTransaction(transaction);
    }
    if (WalletTransactionLabels.isDayFlow(transaction) &&
        WalletTransactionLabels.isDebit(transaction)) {
      return _fromDayFlowTransaction(transaction);
    }
    return null;
  }

  static String transactionListTitle(WalletTransaction transaction) {
    final parsed = parseSendToReason(transaction.reason);
    if (parsed != null && !isGenericRecipientName(parsed.name)) {
      return 'TO ${parsed.name.toUpperCase()}';
    }

    if (isP2pTransaction(transaction)) {
      final legalName = p2pLegalName(transaction);
      if (legalName != null && legalName.isNotEmpty) {
        return 'TO ${legalName.toUpperCase()}';
      }
      final username = p2pUsername(transaction);
      if (username != null) return 'TO ${username.toUpperCase()}';
    }

    final p2pTag = p2pTagFromTransaction(transaction);
    if (p2pTag != null) {
      return 'TO @${p2pTag.toUpperCase()}';
    }

    if (isCryptoTransaction(transaction)) {
      final address = cryptoAddress(transaction);
      final asset = cryptoAssetLabel(transaction);
      return 'TO ${truncateAddress(address).toUpperCase()} · $asset';
    }

    return '';
  }

  static String transactionRecipientName(WalletTransaction transaction) {
    final parsed = parseSendToReason(transaction.reason);
    if (parsed != null &&
        parsed.name.isNotEmpty &&
        !isGenericRecipientName(parsed.name)) {
      return splitDisplayName(parsed.name).primary;
    }

    if (WalletTransactionDisplay.isCrossBorderBankSend(transaction) ||
        isWalletFundedBankSend(transaction)) {
      final meta = transaction.ledgerMetadata;
      final fromMeta = meta?['accountName']?.toString().trim();
      if (fromMeta != null &&
          fromMeta.isNotEmpty &&
          !isGenericRecipientName(fromMeta)) {
        return splitDisplayName(fromMeta).primary;
      }
    }

    if (isP2pTransaction(transaction)) {
      final legalName = p2pLegalName(transaction);
      if (legalName != null && legalName.isNotEmpty) return legalName;
      final username = p2pUsername(transaction);
      if (username != null) return username;
    }

    final p2pTag = p2pTagFromTransaction(transaction);
    if (p2pTag != null) return '@$p2pTag';

    if (isCryptoTransaction(transaction)) {
      return truncateAddress(cryptoAddress(transaction));
    }

    final raw = transaction.beneficiary.name.trim();
    if (!isGenericRecipientName(raw)) return splitDisplayName(raw).primary;
    return raw.isNotEmpty ? raw : 'Recipient';
  }

  static String _recipientAccountKey(BeneficiaryWithSource entry) {
    final raw =
        entry.source.accountNumber?.trim().isNotEmpty == true
            ? entry.source.accountNumber!
            : (entry.beneficiary.accountNumber?.trim().isNotEmpty == true
                ? entry.beneficiary.accountNumber!
                : entry.beneficiary.name);
    return raw.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '');
  }

  static String uniqueKey(BeneficiaryWithSource entry) {
    final type = normalizeAccountType(entry.source.accountType);
    final account = _recipientAccountKey(entry);
    var currency = (entry.ledgerCurrency ?? '').trim().toUpperCase();
    // Bank/mobile rows from history vs saved API often differ on empty vs USD.
    if ((type == 'bank' || type == 'mobile_money') && currency.isEmpty) {
      currency = 'USD';
    }
    if (type == 'bank' || type == 'mobile_money') {
      return '$type|$account|$currency';
    }
    final network = (entry.source.networkId ?? '').trim().toLowerCase();
    return '$type|$account|$currency|$network';
  }

  /// People tab dedup: same payout recipient even when type/account/name casing differs.
  static String peopleListDedupKey(BeneficiaryWithSource entry) {
    final type = normalizeAccountType(entry.source.accountType);
    if (type == 'bank' || type == 'mobile_money') {
      final account = _recipientAccountKey(entry);
      final hasNumericAccount = RegExp(r'\d{6,}').hasMatch(account);
      final country = displayCountryCode(
        beneficiaryCountry: entry.beneficiary.country,
        ledgerCurrency: entry.ledgerCurrency,
        forPayout: true,
      );
      final bank = normalizeBankDisplayName(
        entry.beneficiary.bankName,
        networkId: entry.source.networkId,
      ).toLowerCase();
      final name =
          splitDisplayName(entry.beneficiary.name).primary.toLowerCase().trim();
      final identity = hasNumericAccount ? account : '$name|$bank';
      return 'payout|$identity|$country';
    }
    return uniqueKey(entry);
  }

  /// When two history rows share a [uniqueKey], keep the richer row (real name,
  /// ledger currency, etc.) instead of an older generic "Recipient" entry.
  static bool shouldReplaceRecipient(
    BeneficiaryWithSource candidate,
    BeneficiaryWithSource existing,
  ) {
    final candidateScore = _recipientQualityScore(candidate);
    final existingScore = _recipientQualityScore(existing);
    if (candidateScore != existingScore) {
      return candidateScore > existingScore;
    }
    return candidate.beneficiary.name.trim().length >
        existing.beneficiary.name.trim().length;
  }

  static int _recipientQualityScore(BeneficiaryWithSource entry) {
    var score = 0;
    final name = entry.beneficiary.name.trim();

    if (!isGenericRecipientName(name)) score += 10;
    if (entry.beneficiary.bankName?.trim().isNotEmpty == true) score += 4;
    final bank = normalizeBankDisplayName(
      entry.beneficiary.bankName,
      networkId: entry.source.networkId,
    );
    if (bank == 'Opay') score += 2;
    if (entry.source.networkId?.trim().isNotEmpty == true) score += 3;
    if (entry.ledgerCurrency?.trim().isNotEmpty == true) score += 5;
    if (name.contains(' · ') && entry.beneficiary.bankName?.trim().isNotEmpty == true) {
      score -= 2;
    } else if (name.contains(' · ')) {
      score += 1;
    }
    if (entry.beneficiary.country.trim().isNotEmpty) score += 2;
    if (entry.beneficiary.id.trim().isNotEmpty) score += 1;

    return score;
  }

  static BeneficiaryWithSource? fromTransaction(WalletTransaction transaction) {
    if (!isOutgoingSend(transaction)) return null;

    final beneficiary = transaction.beneficiary;
    final source = transaction.source;
    final ledgerCurrency =
        inferLedgerCurrency(transaction) ??
        transaction.ledgerCurrency?.trim().toUpperCase();
    final resolvedCountry = payoutCountryCode(transaction);
    final resolvedName = transactionRecipientName(transaction);
    final resolvedBank = transactionRecipientBank(transaction);

    if (source.accountNumber != null && source.accountNumber!.trim().isNotEmpty) {
      var accountType =
          source.accountType ??
          _inferAccountType(transaction, accountNumber: source.accountNumber);
      if (WalletTransactionLabels.isBillPayment(transaction)) {
        accountType = 'bill';
      }
      final resolvedAccountNumber = accountType == 'crypto'
          ? cryptoAddress(transaction)
          : source.accountNumber!.trim();
      return BeneficiaryWithSource(
        beneficiary: Beneficiary(
          id: beneficiary.id,
          name: accountType == 'crypto'
              ? resolvedAccountNumber
              : resolvedName,
          country: resolvedCountry,
          phone: beneficiary.phone,
          address: beneficiary.address,
          dob: beneficiary.dob,
          email: beneficiary.email,
          idNumber: beneficiary.idNumber,
          idType: beneficiary.idType,
          accountNumber:
              beneficiary.accountNumber ??
              (accountType == 'dayfi'
                  ? resolvedAccountNumber.replaceFirst('@', '')
                  : resolvedAccountNumber),
          accountType: beneficiary.accountType ?? accountType,
          bankName: resolvedBank,
        ),
        source: payment.Source(
          accountType: accountType,
          accountNumber: resolvedAccountNumber,
          networkId: source.networkId ?? transaction.sendNetwork,
        ),
        ledgerCurrency: ledgerCurrency,
      );
    }

    final p2pTag = p2pTagFromTransaction(transaction);
    if (p2pTag != null && p2pTag.isNotEmpty) {
      return BeneficiaryWithSource(
        beneficiary: Beneficiary(
          id: beneficiary.id.isNotEmpty ? beneficiary.id : 'p2p-$p2pTag',
          name: !isGenericRecipientName(beneficiary.name.trim())
              ? beneficiary.name.trim()
              : '@$p2pTag',
          country: resolvedCountry,
          phone: beneficiary.phone,
          address: beneficiary.address,
          dob: beneficiary.dob,
          email: beneficiary.email,
          idNumber: beneficiary.idNumber,
          idType: beneficiary.idType,
          accountNumber: p2pTag,
          accountType: 'dayfi',
        ),
        source: payment.Source(
          accountType: 'dayfi',
          accountNumber: p2pTag,
          networkId: '',
        ),
        ledgerCurrency: ledgerCurrency,
      );
    }

    if (beneficiary.name.trim().startsWith('@') ||
        beneficiary.accountType?.toLowerCase() == 'dayfi') {
      final tag = beneficiary.name.trim().startsWith('@')
          ? beneficiary.name.trim().replaceFirst('@', '').split(' · ').first
          : beneficiary.accountNumber?.trim() ?? '';
      if (tag.isEmpty) return null;
      return BeneficiaryWithSource(
        beneficiary: Beneficiary(
          id: beneficiary.id,
          name: beneficiary.name,
          country: resolvedCountry,
          phone: beneficiary.phone,
          address: beneficiary.address,
          dob: beneficiary.dob,
          email: beneficiary.email,
          idNumber: beneficiary.idNumber,
          idType: beneficiary.idType,
          accountNumber: beneficiary.accountNumber ?? tag,
          accountType: beneficiary.accountType ?? 'dayfi',
        ),
        source: payment.Source(
          accountType: 'dayfi',
          accountNumber: tag,
          networkId: '',
        ),
        ledgerCurrency: ledgerCurrency,
      );
    }

    if (isCryptoTransaction(transaction) && beneficiary.name.trim().isNotEmpty) {
      final address = cryptoAddress(transaction);
      return BeneficiaryWithSource(
        beneficiary: Beneficiary(
          id: beneficiary.id,
          name: address,
          country: resolvedCountry,
          phone: beneficiary.phone,
          address: beneficiary.address,
          dob: beneficiary.dob,
          email: beneficiary.email,
          idNumber: beneficiary.idNumber,
          idType: beneficiary.idType,
          accountNumber: address,
          accountType: 'crypto',
        ),
        source: payment.Source(
          accountType: 'crypto',
          accountNumber: address,
          networkId: transaction.sendNetwork ?? source.networkId ?? '',
        ),
        ledgerCurrency: ledgerCurrency,
      );
    }

    if (isGenericRecipientName(beneficiary.name.trim())) {
      return null;
    }

    return null;
  }

  static List<BeneficiaryWithSource> filterDayfiRecipients(
    List<BeneficiaryWithSource> all, {
    required String currency,
    String? excludeTag,
  }) {
    final cur = currency.toUpperCase();
    final excluded = excludeTag?.replaceFirst('@', '').trim().toLowerCase();
    return all.where((entry) {
      if (entry.source.accountType?.toLowerCase() != 'dayfi') return false;
      final tag = entry.source.accountNumber?.replaceFirst('@', '').trim();
      if (excluded != null &&
          excluded.isNotEmpty &&
          tag?.toLowerCase() == excluded) {
        return false;
      }
      final entryCurrency = (entry.ledgerCurrency ?? '').toUpperCase();
      return entryCurrency.isEmpty || entryCurrency == cur;
    }).toList();
  }

  static bool matchesDeliveryMethod(
    BeneficiaryWithSource entry,
    String deliveryMethod,
  ) {
    final method = deliveryMethod.toLowerCase();
    final type = normalizeAccountType(entry.source.accountType);
    if (method == 'dayfi_tag' || method == 'dayfi') return type == 'dayfi';
    if (method == 'crypto' || method == 'cryptocurrency') return type == 'crypto';
    if (isBankDeliveryMethod(method)) return type == 'bank';
    if (method.contains('mobile') || method == 'momo') {
      return type == 'mobile_money';
    }
    return true;
  }

  static List<BeneficiaryWithSource> filterForSendContext(
    List<BeneficiaryWithSource> all, {
    String? deliveryMethod,
    String? currency,
    String? receiveCountry,
    String? receiveCurrency,
  }) {
    final cur = currency?.toUpperCase();
    final receiveCur = receiveCurrency?.toUpperCase();
    final country = receiveCountry?.toUpperCase();

    return all.where((entry) {
      if (!isSendRecipient(entry)) return false;

      if (deliveryMethod != null &&
          deliveryMethod.isNotEmpty &&
          !matchesDeliveryMethod(entry, deliveryMethod)) {
        return false;
      }

      if (country != null && country.isNotEmpty && !isDayfiRecipient(entry)) {
        final type = normalizeAccountType(entry.source.accountType);
        if (type != 'crypto') {
          final entryCountry = entry.beneficiary.country.toUpperCase();
          if (entryCountry.isNotEmpty && entryCountry != country) {
            return false;
          }
        }
      }

      // Pay-with currency only filters Dayfi Tag picks (same-currency P2P).
      if (cur != null && cur.isNotEmpty && isDayfiRecipient(entry)) {
        final entryCurrency = (entry.ledgerCurrency ?? '').toUpperCase();
        if (entryCurrency.isNotEmpty && entryCurrency != cur) return false;
      }

      // Optional receive-currency guard for bank / mobile rows.
      if (receiveCur != null &&
          receiveCur.isNotEmpty &&
          !isDayfiRecipient(entry)) {
        final type = normalizeAccountType(entry.source.accountType);
        if (type == 'bank' || type == 'mobile_money') {
          final entryCurrency = resolveReceiveCurrency(entry).toUpperCase();
          if (entryCurrency.isNotEmpty && entryCurrency != receiveCur) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }

  static String resolveLedgerCurrency(BeneficiaryWithSource entry) {
    final ledger = entry.ledgerCurrency?.trim().toUpperCase();
    if (ledger != null && ledger.isNotEmpty) return ledger;

    final country = entry.beneficiary.country.trim().toUpperCase();
    if (country.isNotEmpty) {
      return currencyForCountry(country);
    }
    return 'NGN';
  }

  /// Payout destination currency (e.g. NGN for Opay), not USD wallet ledger.
  static String resolveReceiveCurrency(BeneficiaryWithSource entry) {
    final type = normalizeAccountType(entry.source.accountType);
    if (type == 'bank' || type == 'mobile_money') {
      final country = displayCountryCode(
        beneficiaryCountry: entry.beneficiary.country,
        forPayout: true,
      );
      return currencyForCountry(country);
    }
    return resolveLedgerCurrency(entry);
  }

  static String resolveReceiveCountry(BeneficiaryWithSource entry) {
    return displayCountryCode(
      beneficiaryCountry: entry.beneficiary.country,
      forPayout: true,
    );
  }

  static String currencyForCountry(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'NG':
        return 'NGN';
      case 'GH':
        return 'GHS';
      case 'KE':
        return 'KES';
      case 'RW':
        return 'RWF';
      case 'UG':
        return 'UGX';
      case 'TZ':
        return 'TZS';
      case 'ZA':
        return 'ZAR';
      case 'US':
        return 'USD';
      case 'GB':
        return 'GBP';
      case 'EU':
      case 'DE':
        return 'EUR';
      default:
        return 'NGN';
    }
  }

  static String countryForCurrency(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return 'US';
      case 'EUR':
        return 'EU';
      case 'GBP':
        return 'GB';
      case 'NGN':
        return 'NG';
      default:
        return 'NG';
    }
  }

  static String truncateAddress(String address, {int head = 8, int tail = 6}) {
    final value = address.trim();
    if (value.length <= head + tail + 3) return value;
    return '${value.substring(0, head)}…${value.substring(value.length - tail)}';
  }

  static String _networkLabel(String? networkId) {
    final n = networkId?.trim().toLowerCase() ?? '';
    if (n.contains('stellar')) return 'Stellar';
    if (n.contains('eth')) return 'Ethereum';
    return n.isEmpty ? '' : n;
  }

  static String? bankNameFromNetworkId(String? networkId) {
    final id = networkId?.trim() ?? '';
    if (id.isEmpty) return null;

    final banks = NgnBanksCache.cached;
    if (banks != null) {
      for (final network in banks) {
        if (network.id == id) return network.name?.trim();
        final code = network.code;
        if (code is String && code == id) return network.name?.trim();
      }
    }
    return null;
  }

  /// Consistent bank labels in lists (Opay, not OPay/opay/paycom).
  static String normalizeBankDisplayName(
    String? raw, {
    String? networkId,
    String? networkName,
  }) {
    final fromNetwork =
        networkName?.trim().isNotEmpty == true
            ? networkName!.trim()
            : bankNameFromNetworkId(networkId);
    if (fromNetwork != null &&
        fromNetwork.isNotEmpty &&
        !WalletTransactionDisplay.isPlaceholderDetail(fromNetwork)) {
      return _canonicalBankName(fromNetwork);
    }

    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) return '';
    return _canonicalBankName(trimmed);
  }

  static String _canonicalBankName(String name) {
    final compact = name.toLowerCase().replaceAll(RegExp(r'[\s._-]'), '');
    const aliases = <String, String>{
      'opay': 'Opay',
      'paycom': 'Opay',
      'palmpay': 'PalmPay',
      'gtbank': 'GTBank',
      'gtb': 'GTBank',
      'accessbank': 'Access Bank',
      'zenithbank': 'Zenith Bank',
      'firstbank': 'First Bank',
      'ubapl': 'UBA',
      'uba': 'UBA',
    };
    return aliases[compact] ?? name;
  }

  static String _bankLabelForEntry(
    Beneficiary beneficiary,
    payment.Source source, {
    String? networkName,
  }) {
    final fromField = beneficiary.bankName?.trim();
    if (fromField != null &&
        fromField.isNotEmpty &&
        !WalletTransactionDisplay.isPlaceholderDetail(fromField)) {
      return normalizeBankDisplayName(
        fromField,
        networkId: source.networkId,
        networkName: networkName,
      );
    }

    final resolvedNetwork = networkName?.trim().isNotEmpty == true
        ? networkName!.trim()
        : bankNameFromNetworkId(source.networkId);
    if (resolvedNetwork != null &&
        resolvedNetwork.isNotEmpty &&
        !WalletTransactionDisplay.isPlaceholderDetail(resolvedNetwork)) {
      return normalizeBankDisplayName(
        resolvedNetwork,
        networkId: source.networkId,
        networkName: networkName,
      );
    }

    final split = splitDisplayName(beneficiary.name.trim());
    if (split.secondary != null &&
        !WalletTransactionDisplay.isPlaceholderDetail(split.secondary!)) {
      return normalizeBankDisplayName(
        split.secondary,
        networkId: source.networkId,
        networkName: networkName,
      );
    }

    final parsed = parseSendToReason(beneficiary.name);
    if (parsed?.bank != null &&
        !WalletTransactionDisplay.isPlaceholderDetail(parsed!.bank!)) {
      return normalizeBankDisplayName(
        parsed.bank,
        networkId: source.networkId,
        networkName: networkName,
      );
    }

    return '';
  }

  /// Bank / provider line for recipients list (bank, mobile, crypto, username).
  static String recipientChannelLabel(
    BeneficiaryWithSource entry, {
    String? networkName,
  }) {
    final type = normalizeAccountType(entry.source.accountType);
    if (type == 'dayfi') {
      return secondaryLabel(
        entry.beneficiary,
        entry.source,
        ledgerCurrency: entry.ledgerCurrency,
      );
    }
    if (type == 'crypto') {
      return secondaryLabel(
        entry.beneficiary,
        entry.source,
        ledgerCurrency: entry.ledgerCurrency,
      );
    }
    if (type == 'bank') {
      final bank =
          networkName?.trim().isNotEmpty == true
              ? networkName!.trim()
              : _bankLabelForEntry(
                entry.beneficiary,
                entry.source,
                networkName: networkName,
              );
      final country = flagCountryForRecipient(entry);
      if (bank.isNotEmpty) return '$bank · $country';
      return 'Bank · $country';
    }
    if (type == 'phone' ||
        type == 'mobile' ||
        type == 'mobile_money' ||
        type == 'momo') {
      final provider =
          networkName?.trim().isNotEmpty == true
              ? networkName!.trim()
              : _bankLabelForEntry(
                entry.beneficiary,
                entry.source,
                networkName: networkName,
              );
      final country = flagCountryForRecipient(entry);
      if (provider.isNotEmpty) return '$provider · $country';
      return 'Mobile money · $country';
    }
    return secondaryLabel(
      entry.beneficiary,
      entry.source,
      ledgerCurrency: entry.ledgerCurrency,
    );
  }

  /// Route args for [SendAddRecipientsView] when sending to a saved bank/MM recipient.
  static Map<String, dynamic> addRecipientsSelectedData(
    BeneficiaryWithSource entry, {
    Map<String, dynamic>? extra,
    String? payWithCurrency,
  }) {
    final type = normalizeAccountType(entry.source.accountType);
    final receiveCurrency = resolveReceiveCurrency(entry);
    final receiveCountry = resolveReceiveCountry(entry);
    final deliveryMethod = type == 'bank' ? 'bank' : 'mobile_money';

    return {
      'receiveCountry': receiveCountry,
      'receiveCurrency': receiveCurrency,
      ...payWithRouteArgs(
        payWithCurrency: payWithCurrency,
        receiveCurrency: receiveCurrency,
      ),
      'recipientDeliveryMethod': deliveryMethod,
      'prefillBeneficiary': entry,
      ...?extra,
    };
  }

  static Map<String, dynamic> cryptoSendSelectedData(
    BeneficiaryWithSource entry, {
    Map<String, dynamic>? extra,
  }) {
    final currency = resolveLedgerCurrency(entry);
    final networkId = entry.source.networkId?.trim() ?? '';
    return {
      'debitCurrency': currency,
      'receiveCurrency': currency,
      'cryptoAddress': entry.source.accountNumber,
      'accountNumber': entry.source.accountNumber,
      'network': networkId.isNotEmpty ? networkId : 'stellar',
      ...?extra,
    };
  }

  static Map<String, dynamic> dayfiSendSelectedData(
    BeneficiaryWithSource entry, {
    Map<String, dynamic>? extra,
    String? payWithCurrency,
  }) {
    final payWith = resolvePayWithCurrency(payWithCurrency);
    final receiveCountry = displayCountryCode(
      beneficiaryCountry: entry.beneficiary.country,
      ledgerCurrency: payWith,
    );
    final tag =
        entry.source.accountNumber?.replaceFirst('@', '').trim() ?? '';

    return {
      ...payWithRouteArgs(payWithCurrency: payWith),
      'receiveCurrency': payWith,
      'receiveCountry': receiveCountry,
      'recipientDeliveryMethod': 'dayfi_tag',
      'accountNumber': tag,
      'recipientName': primaryLabel(entry.beneficiary, entry.source),
      ...?extra,
    };
  }

  static bool isBankOrMobileRecipient(BeneficiaryWithSource entry) {
    switch (normalizeAccountType(entry.source.accountType)) {
      case 'bank':
      case 'mobile_money':
        return true;
      default:
        return false;
    }
  }
}
