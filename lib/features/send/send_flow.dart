import 'dart:async';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/send/widgets/delivery_methods_sheet.dart';
import 'package:dayfi/features/wallet/constants/global_wallet.dart';
import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';
import 'package:dayfi/models/payment_response.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PRD core wallets shown at top of Send tab + shortcut destinations.
const List<({String country, String currency, String label})> kCoreSendDestinations =
    [
  (country: 'NG', currency: 'NGN', label: 'Nigeria'),
  (country: 'US', currency: 'USD', label: 'United States'),
  (country: 'GB', currency: 'GBP', label: 'United Kingdom'),
  (country: 'DE', currency: 'EUR', label: 'Euro'),
];

const Set<String> kCoreSendCurrencies = {'USD', 'GBP', 'EUR', 'NGN'};

/// Launch market + global wallets — order on the Send destination screen.
const List<String> kGlobalSendCurrencyOrder = ['NGN', 'USD', 'EUR', 'GBP'];

/// African corridors — priority order (top markets first).
const List<String> kStandardAfricanCountryOrder = [
  'ZA',
  'KE',
  'GH',
  'UG',
  'TZ',
  'RW',
  'ZM',
  'BW',
  'MW',
  'SN',
  'CM',
  'CI',
  'CD',
  'CG',
  'GA',
  'BJ',
  'BF',
  'ML',
  'TG',
];

bool isGlobalSendDestination(Channel channel) {
  final currency = channel.currency?.toUpperCase() ?? '';
  return kGlobalSendCurrencyOrder.contains(currency);
}

int _globalSendSortIndex(Channel channel) {
  final currency = channel.currency?.toUpperCase() ?? '';
  final index = kGlobalSendCurrencyOrder.indexOf(currency);
  return index >= 0 ? index : kGlobalSendCurrencyOrder.length;
}

int _standardSendSortIndex(Channel channel) {
  final country = channel.country?.toUpperCase() ?? '';
  final index = kStandardAfricanCountryOrder.indexOf(country);
  return index >= 0 ? index : kStandardAfricanCountryOrder.length;
}

void sortGlobalSendDestinations(List<Channel> channels) {
  channels.sort((a, b) {
    final byRank = _globalSendSortIndex(a).compareTo(_globalSendSortIndex(b));
    if (byRank != 0) return byRank;
    return (a.country ?? '').compareTo(b.country ?? '');
  });
}

void sortStandardSendDestinations(List<Channel> channels) {
  channels.sort((a, b) {
    final byRank = _standardSendSortIndex(a).compareTo(_standardSendSortIndex(b));
    if (byRank != 0) return byRank;
    return (a.country ?? '').compareTo(b.country ?? '');
  });
}

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

/// Pay-with currency for Send (global wallet). Defaults from home display pill.
String resolveDebitCurrency(WidgetRef ref, String receiveCurrency) {
  final payWith = ref.read(selectedDebitCurrencyProvider).toUpperCase();
  final receive = receiveCurrency.toUpperCase();
  if (!isGlobalPayCurrency(payWith)) {
    return resolvePayWithCurrencyForTransfer(
      payWithCurrency: isGlobalPayCurrency(receive) ? receive : 'USD',
      receiveCurrency: receive,
    );
  }
  return resolvePayWithCurrencyForTransfer(
    payWithCurrency: payWith,
    receiveCurrency: receive,
  );
}

/// Home Send — navigate immediately; refresh wallet hub in background.
Future<void> openSendFromHomeOrTab(
  BuildContext context, {
  String? payWithCurrency,
}) async {
  try {
    final container = ProviderScope.containerOf(context);
    if (payWithCurrency != null && isGlobalPayCurrency(payWithCurrency)) {
      container.read(selectedDebitCurrencyProvider.notifier).state =
          payWithCurrency.toUpperCase();
    }
    unawaited(
      container
          .read(walletHubProvider.notifier)
          .load(showLoading: false)
          .catchError((_) {}),
    );
  } catch (_) {}

  if (!context.mounted) return;
  await appRouter.pushNamed(AppRoute.selectDestinationCountryView);
}

/// Wallet detail Send — delivery methods for [currency] immediately.
Future<void> openSendFromWallet(BuildContext context, String currency) async {
  final c = currency.toUpperCase();
  try {
    final container = ProviderScope.containerOf(context);
    // Keep tap-to-sheet interaction instant; refresh wallet hub in background.
    unawaited(
      container
          .read(walletHubProvider.notifier)
          .load(showLoading: false)
          .catchError((_) {}),
    );
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
  // Keep tap-to-sheet interaction instant; refresh wallet hub in background.
  unawaited(
    ref.read(walletHubProvider.notifier).load(showLoading: false).catchError((_) {}),
  );

  final receive = receiveCurrency.toUpperCase();
  final debitCurrency = resolveDebitCurrency(ref, receive);
  ref.read(selectedDebitCurrencyProvider.notifier).state = debitCurrency;

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
  bool saveRecipientOnly = false,
}) {
  return showModalBottomSheet<void>(
    barrierColor: Colors.black.withOpacity(0.85),
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DeliveryMethodsSheet(
      selectedCountry: selectedCountry,
      selectedCurrency: selectedCurrency,
      debitCurrency: debitCurrency,
      saveRecipientOnly: saveRecipientOnly,
    ),
  );
}

/// After user picks a country/currency when saving a recipient (Recipients +).
Future<void> handleSaveRecipientDestinationSelected(
  BuildContext context,
  WidgetRef ref, {
  required String countryCode,
  required String receiveCurrency,
}) async {
  unawaited(
    ref.read(walletHubProvider.notifier).load(showLoading: false).catchError((_) {}),
  );

  final receive = receiveCurrency.toUpperCase();
  final debitCurrency = resolveDebitCurrency(ref, receive);
  ref.read(selectedDebitCurrencyProvider.notifier).state = debitCurrency;

  if (!context.mounted) return;
  await showSendDeliveryMethodsSheet(
    context,
    selectedCountry: countryCode.toUpperCase(),
    selectedCurrency: receive,
    debitCurrency: debitCurrency,
    saveRecipientOnly: true,
  );
}
