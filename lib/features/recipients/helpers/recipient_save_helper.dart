import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/features/recipients/vm/recipients_viewmodel.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:dayfi/models/payment_response.dart' as payment;
import 'package:dayfi/models/wallet_transaction.dart' show Beneficiary;
import 'package:dayfi/app_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/navigation/navigator_key.dart';

/// Persists a manually saved recipient locally and on the backend.
class RecipientSaveHelper {
  RecipientSaveHelper._();

  static const _empty = '';

  static Future<BeneficiaryWithSource> save(
    WidgetRef ref,
    BeneficiaryWithSource entry,
  ) async {
    BeneficiaryWithSource persisted = entry;
    try {
      persisted = await walletService.saveBeneficiary(entry);
    } catch (e, st) {
      AppLogger.error('Backend recipient save failed, keeping local copy: $e');
      AppLogger.debug('$st');
    }
    await ref.read(recipientsProvider.notifier).saveRecipient(persisted);
    return persisted;
  }

  /// Pops save-recipient screens, then shows success (snackbar after pop — never
  /// while a Flushbar route is on the stack).
  static void completeSaveRecipientOnlyNavigation(BuildContext context) {
    if (!context.mounted) return;
    final navigator = Navigator.of(context);
    navigator.pop();
    if (navigator.canPop()) navigator.pop();
    TopSnackbar.showSafe(
      NavigatorKey.appNavigatorKey.currentContext ?? context,
      message: 'Recipient saved',
    );
  }

  static BeneficiaryWithSource dayfi({
    required String tag,
    required String displayName,
    required String currency,
    String country = 'NG',
  }) {
    final cleanTag = tag.replaceFirst('@', '').trim();
    return BeneficiaryWithSource(
      beneficiary: Beneficiary(
        id: 'saved-dayfi-$cleanTag',
        name: displayName.trim().isNotEmpty ? displayName.trim() : '@$cleanTag',
        country: RecipientHistoryHelper.countryForCurrency(currency),
        phone: _empty,
        address: _empty,
        dob: _empty,
        email: _empty,
        idNumber: _empty,
        idType: _empty,
        accountNumber: cleanTag,
        accountType: 'dayfi',
      ),
      source: payment.Source(
        accountType: 'dayfi',
        accountNumber: cleanTag,
        networkId: '',
      ),
      ledgerCurrency: currency.toUpperCase(),
    );
  }

  static BeneficiaryWithSource crypto({
    required String address,
    required String networkKey,
    required String currency,
  }) {
    final cur = currency.toUpperCase();
    return BeneficiaryWithSource(
      beneficiary: Beneficiary(
        id: 'saved-crypto-${address.hashCode}',
        name: address.trim(),
        country: RecipientHistoryHelper.countryForCurrency(cur),
        phone: _empty,
        address: _empty,
        dob: _empty,
        email: _empty,
        idNumber: _empty,
        idType: _empty,
        accountNumber: address.trim(),
        accountType: 'crypto',
      ),
      source: payment.Source(
        accountType: 'crypto',
        accountNumber: address.trim(),
        networkId: networkKey,
      ),
      ledgerCurrency: cur == 'EUR' ? 'EUR' : 'USD',
    );
  }

  static BeneficiaryWithSource bankOrMobile({
    required String name,
    required String country,
    required String currency,
    required String accountNumber,
    required String networkId,
    required String accountType,
    String? phone,
    String? bankName,
  }) {
    final normalizedType =
        RecipientHistoryHelper.normalizeAccountType(accountType);
    final resolvedBank = bankName?.trim();
    return BeneficiaryWithSource(
      beneficiary: Beneficiary(
        id: 'saved-$normalizedType-${accountNumber.hashCode}',
        name: name.trim(),
        country: country.toUpperCase(),
        phone: phone ?? _empty,
        address: _empty,
        dob: _empty,
        email: _empty,
        idNumber: _empty,
        idType: _empty,
        accountNumber: accountNumber.trim(),
        accountType: normalizedType,
        bankName: resolvedBank?.isNotEmpty == true ? resolvedBank : null,
      ),
      source: payment.Source(
        accountType: normalizedType,
        accountNumber: accountNumber.trim(),
        networkId: networkId,
      ),
      ledgerCurrency: currency.toUpperCase(),
    );
  }
}
