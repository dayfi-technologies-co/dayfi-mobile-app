import 'package:dayfi/features/dayx/models/dayx_intent.dart';
import 'package:dayfi/features/recipients/helpers/recipient_send_launcher.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';

/// Opens Send after DayX biometric verification with optional prefilled data.
abstract final class DayxSendPrefill {
  DayxSendPrefill._();

  static Future<void> open(
    BuildContext context, {
    required DayxTransferProposal proposal,
  }) async {
    final amount = proposal.amount;
    final currency = proposal.currency ?? 'NGN';
    final beneficiaryId = proposal.beneficiaryId?.trim() ?? '';

    if (beneficiaryId.isNotEmpty) {
      await RecipientSendLauncher.launchWithBeneficiaryId(
        context,
        beneficiaryId: beneficiaryId,
        amount: amount,
        currency: currency,
        fallbackName: proposal.recipientName,
      );
      return;
    }

    if (proposal.recipientName != null && proposal.recipientName!.isNotEmpty) {
      final match = await RecipientSendLauncher.findByName(proposal.recipientName!);
      if (match != null) {
        await RecipientSendLauncher.launch(
          context,
          match,
          amount: amount,
          currency: currency,
        );
        return;
      }
    }

    await Navigator.pushNamed(
      context,
      AppRoute.selectDestinationCountryView,
      arguments: <String, dynamic>{
        if (amount != null && amount > 0) 'prefillSendAmount': amount,
        'prefillCurrency': currency,
      },
    );
  }
}
