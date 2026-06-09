import 'package:dayfi/features/send/send_flow.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Entry for adding a saved recipient from the Recipients tab (+).
abstract final class SaveRecipientFlow {
  static Future<void> start(BuildContext context, WidgetRef ref) async {
    await Navigator.pushNamed(
      context,
      AppRoute.selectDestinationCountryView,
      arguments: <String, dynamic>{
        'hasBackButton': true,
        'addRecipientOnly': true,
      },
    );
  }

  static Future<void> showDeliverySheet(
    BuildContext context, {
    required String selectedCountry,
    required String selectedCurrency,
    required String debitCurrency,
  }) {
    return showSendDeliveryMethodsSheet(
      context,
      selectedCountry: selectedCountry,
      selectedCurrency: selectedCurrency,
      debitCurrency: debitCurrency,
      saveRecipientOnly: true,
    );
  }
}
