import 'package:dayfi/common/constants/wallet_flag_assets.dart';

/// Global wallet — one USD pool; users view / pay with these display currencies.
const List<String> kGlobalPayCurrencies = ['USD', 'GBP', 'EUR', 'NGN'];

const Map<String, String> kGlobalPayCurrencyNames = {
  'USD': 'US Dollar',
  'GBP': 'British Pound',
  'EUR': 'Euro',
  'NGN': 'Nigerian Naira',
};

const Map<String, String> kGlobalPayCurrencyFlags = {
  'USD': 'assets/icons/svgs/world_flags/united states.svg',
  'GBP': 'assets/icons/svgs/world_flags/united kingdom.svg',
  'EUR': WalletFlagAssets.eur,
  'NGN': 'assets/icons/svgs/world_flags/nigeria.svg',
};

String countryCodeForPayCurrency(String currency) {
  switch (currency.toUpperCase()) {
    case 'NGN':
      return 'NG';
    case 'GBP':
      return 'GB';
    case 'EUR':
      return 'DE';
    case 'USD':
    default:
      return 'US';
  }
}

bool isGlobalPayCurrency(String? currency) {
  return kGlobalPayCurrencies.contains(currency?.toUpperCase());
}

/// Pay-with currency for Send (global wallet). Defaults to USD.
String resolvePayWithCurrency(String? payWithCurrency) {
  if (payWithCurrency != null && isGlobalPayCurrency(payWithCurrency)) {
    return payWithCurrency.toUpperCase();
  }
  return 'USD';
}

/// Pay-with for a corridor: uses home display / explicit pick, but never matches
/// [receiveCurrency] — one global USD pool debited via a display currency.
String resolvePayWithCurrencyForTransfer({
  String? payWithCurrency,
  required String receiveCurrency,
}) {
  final receive = receiveCurrency.toUpperCase();
  final payWith = resolvePayWithCurrency(payWithCurrency);
  if (payWith == receive && receive != 'USD') {
    return 'USD';
  }
  return payWith;
}

/// Route args for debit / send side of a transfer.
Map<String, dynamic> payWithRouteArgs({
  String? payWithCurrency,
  String? receiveCurrency,
}) {
  final payWith = receiveCurrency != null && receiveCurrency.isNotEmpty
      ? resolvePayWithCurrencyForTransfer(
          payWithCurrency: payWithCurrency,
          receiveCurrency: receiveCurrency,
        )
      : resolvePayWithCurrency(payWithCurrency);
  return {
    'sendCurrency': payWith,
    'debitCurrency': payWith,
    'sendCountry': countryCodeForPayCurrency(payWith),
  };
}
