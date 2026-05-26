/// Shared flag asset paths for PRD wallet currencies.
class WalletFlagAssets {
  WalletFlagAssets._();

  static const String usd =
      'assets/icons/svgs/world_flags/united states.svg';
  static const String gbp =
      'assets/icons/svgs/world_flags/united kingdom.svg';
  static const String eur =
      'assets/icons/svgs/world_flags/european-union.svg';
  static const String ngn = 'assets/icons/svgs/world_flags/nigeria.svg';

  static String forCurrency(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return usd;
      case 'GBP':
        return gbp;
      case 'EUR':
        return eur;
      case 'NGN':
        return ngn;
      default:
        return ngn;
    }
  }
}
