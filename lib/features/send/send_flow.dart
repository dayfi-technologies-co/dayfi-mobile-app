import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/send/widgets/delivery_methods_sheet.dart';
import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';
import 'package:dayfi/features/wallet/widgets/debit_wallet_picker_sheet.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PRD core wallets shown at top of Send tab + shortcut destinations.
const List<({String country, String currency, String label})> kCoreSendDestinations =
    [
  (country: 'NG', currency: 'NGN', label: 'Nigeria'),
  (country: 'US', currency: 'USD', label: 'United States'),
  (country: 'GB', currency: 'GBP', label: 'United Kingdom'),
  (country: 'DE', currency: 'EUR', label: 'Euro area'),
];

const Set<String> kCoreSendCurrencies = {'USD', 'GBP', 'EUR', 'NGN'};

String countryForCurrency(String currency) {
  switch (currency.toUpperCase()) {
    case 'NGN':
      return 'NG';
    case 'USD':
      return 'US';
    case 'GBP':
      return 'GB';
    case 'EUR':
      return 'DE';
    default:
      return currency.length >= 2 ? currency.substring(0, 2).toUpperCase() : 'NG';
  }
}

bool userHasLedgerWallet(WidgetRef ref, String currency) {
  final row = ref.read(walletHubProvider).hub?.rowFor(currency);
  return row?.hasLedgerWallet == true;
}

/// Home Send — same destination list as Send tab (no debit picker upfront).
Future<void> openSendFromHomeOrTab(BuildContext context) async {
  try {
    final container = ProviderScope.containerOf(context);
    await container.read(walletHubProvider.notifier).load(showLoading: false);
  } catch (_) {}

  if (!context.mounted) return;
  await appRouter.pushNamed(AppRoute.selectDestinationCountryView);
}

/// Wallet detail Send — delivery methods for [currency] immediately.
Future<void> openSendFromWallet(BuildContext context, String currency) async {
  final c = currency.toUpperCase();
  try {
    final container = ProviderScope.containerOf(context);
    await container.read(walletHubProvider.notifier).load(showLoading: false);
    container.read(selectedDebitCurrencyProvider.notifier).state = c;
  } catch (_) {}

  if (!context.mounted) return;

  await showSendDeliveryMethodsSheet(
    context,
    selectedCountry: countryForCurrency(c),
    selectedCurrency: c,
    debitCurrency: c,
  );
}

/// After user picks a destination country/currency on Send tab.
Future<void> handleSendDestinationSelected(
  BuildContext context,
  WidgetRef ref, {
  required String countryCode,
  required String receiveCurrency,
}) async {
  await ref.read(walletHubProvider.notifier).load(showLoading: false);

  final receive = receiveCurrency.toUpperCase();
  final hasWallet = userHasLedgerWallet(ref, receive);

  String debitCurrency;
  if (hasWallet) {
    debitCurrency = receive;
    ref.read(selectedDebitCurrencyProvider.notifier).state = debitCurrency;
  } else {
    if (!context.mounted) return;
    final picked = await showDebitWalletPicker(context);
    if (!context.mounted) return;
    if (picked == null || picked.isEmpty) return;
    debitCurrency = picked;
  }

  if (!context.mounted) return;
  await showSendDeliveryMethodsSheet(
    context,
    selectedCountry: countryCode.toUpperCase(),
    selectedCurrency: receive,
    debitCurrency: debitCurrency,
  );
}

Future<void> showSendDeliveryMethodsSheet(
  BuildContext context, {
  required String selectedCountry,
  required String selectedCurrency,
  required String debitCurrency,
}) {
  return showModalBottomSheet<void>(
    barrierColor: Colors.black.withOpacity(0.85),
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (ctx) => DeliveryMethodsSheet(
      selectedCountry: selectedCountry,
      selectedCurrency: selectedCurrency,
      debitCurrency: debitCurrency,
    ),
  );
}
