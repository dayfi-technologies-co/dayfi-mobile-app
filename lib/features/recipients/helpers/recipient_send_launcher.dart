import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/features/wallet/constants/global_wallet.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';

/// Opens Send with a saved recipient and optional prefilled amount (DayX, etc.).
abstract final class RecipientSendLauncher {
  RecipientSendLauncher._();

  static Future<BeneficiaryWithSource?> findById(String beneficiaryId) async {
    if (beneficiaryId.trim().isEmpty) return null;
    final list = await walletService.getUniqueBeneficiariesWithSource();
    for (final entry in list) {
      if (entry.beneficiary.id == beneficiaryId) return entry;
    }
    return null;
  }

  static Future<BeneficiaryWithSource?> findByName(String name) async {
    final needle = name.trim().toLowerCase();
    if (needle.isEmpty) return null;
    final list = await walletService.getUniqueBeneficiariesWithSource();
    final matches = list
        .where((e) => e.beneficiary.name.toLowerCase().contains(needle))
        .toList();
    if (matches.length == 1) return matches.first;
    return null;
  }

  static Map<String, dynamic> _amountArgs(double? amount, String? currency) {
    if (amount == null || amount <= 0) return {};
    return {
      'prefillSendAmount': amount,
      if (currency != null && currency.isNotEmpty) 'prefillCurrency': currency,
    };
  }

  static Future<void> launch(
    BuildContext context,
    BeneficiaryWithSource beneficiaryWithSource, {
    double? amount,
    String? currency,
    String? payWithCurrency,
  }) async {
    final payWith = resolvePayWithCurrency(payWithCurrency);
    final resolvedCurrency = currency?.toUpperCase() ??
        (RecipientHistoryHelper.isBankOrMobileRecipient(beneficiaryWithSource)
            ? RecipientHistoryHelper.resolveReceiveCurrency(
                beneficiaryWithSource,
              )
            : RecipientHistoryHelper.resolveLedgerCurrency(
                beneficiaryWithSource,
              ));
    final type =
        RecipientHistoryHelper.normalizeAccountType(
          beneficiaryWithSource.source.accountType,
        );
    final amountArgs = _amountArgs(amount, resolvedCurrency);
    final tag = beneficiaryWithSource.source.accountNumber
        ?.replaceFirst('@', '')
        .trim();

    if (type == 'crypto') {
      await Navigator.pushNamed(
        context,
        AppRoute.walletCryptoSendView,
        arguments: RecipientHistoryHelper.cryptoSendSelectedData(
          beneficiaryWithSource,
          extra: amountArgs,
        ),
      );
      return;
    }

    if (type == 'dayfi' && tag != null && tag.isNotEmpty) {
      await Navigator.pushNamed(
        context,
        AppRoute.sendDayfiIdView,
        arguments: RecipientHistoryHelper.dayfiSendSelectedData(
          beneficiaryWithSource,
          extra: amountArgs,
          payWithCurrency: payWith,
        ),
      );
      return;
    }

    if (RecipientHistoryHelper.isBankOrMobileRecipient(beneficiaryWithSource)) {
      await Navigator.pushNamed(
        context,
        AppRoute.addRecipientsView,
        arguments: RecipientHistoryHelper.addRecipientsSelectedData(
          beneficiaryWithSource,
          extra: amountArgs,
          payWithCurrency: payWith,
        ),
      );
      return;
    }

    final receiveCurrency = resolvedCurrency;
    final receiveCountry = RecipientHistoryHelper.resolveReceiveCountry(
      beneficiaryWithSource,
    );

    await Navigator.pushNamed(
      context,
      AppRoute.sendView,
      arguments: <String, dynamic>{
        'selectedData': {
          'beneficiaryWithSource': beneficiaryWithSource,
          'fromRecipients': true,
          'receiveCountry': receiveCountry,
          'receiveCurrency': receiveCurrency,
          ...payWithRouteArgs(
            payWithCurrency: payWith,
            receiveCurrency: receiveCurrency,
          ),
          ...amountArgs,
        },
      },
    );
  }

  static Future<void> launchWithBeneficiaryId(
    BuildContext context, {
    required String beneficiaryId,
    double? amount,
    String? currency,
    String? fallbackName,
  }) async {
    var match = await findById(beneficiaryId);
    if (match == null && fallbackName != null) {
      match = await findByName(fallbackName);
    }
    if (match != null) {
      await launch(context, match, amount: amount, currency: currency);
      return;
    }

    await Navigator.pushNamed(
      context,
      AppRoute.selectDestinationCountryView,
      arguments: <String, dynamic>{
        ..._amountArgs(amount, currency ?? 'NGN'),
      },
    );
  }
}
