/// Sandbox-style Grey operating account details for Add-money Bank tab demos.
class GreyDemoBankDetails {
  final String currency;
  final String bankName;
  final String accountNumber;
  final String iban;
  final String routingNumber;

  const GreyDemoBankDetails({
    required this.currency,
    required this.bankName,
    required this.accountNumber,
    this.iban = '',
    this.routingNumber = '',
  });
}

/// USD / GBP / EUR sample accounts (Grey testnet pattern).
GreyDemoBankDetails? greyDemoBankFor(String currency) {
  switch (currency.toUpperCase()) {
    case 'USD':
      return const GreyDemoBankDetails(
        currency: 'USD',
        bankName: 'Lead Bank (via Grey)',
        accountNumber: '823456789012',
        routingNumber: '021000021',
      );
    case 'GBP':
      return const GreyDemoBankDetails(
        currency: 'GBP',
        bankName: 'Grey · UK',
        accountNumber: '29876543',
        routingNumber: '040004',
      );
    case 'EUR':
      return const GreyDemoBankDetails(
        currency: 'EUR',
        bankName: 'Grey · EU',
        accountNumber: '',
        iban: 'DE89 3704 0044 0532 0130 00',
        routingNumber: 'COBADEFFXXX',
      );
    default:
      return null;
  }
}

bool supportsGreyDemoBankTab(String currency) =>
    greyDemoBankFor(currency) != null;
