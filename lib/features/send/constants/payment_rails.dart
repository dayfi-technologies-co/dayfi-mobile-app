/// Send payout rails — one provider per corridor type.
///
/// * **African bank / mobile money (incl. NG NGN P2P)** → Yellow Card
/// * **Dayfi-to-Dayfi** → internal USD ledger
library;

const String kFlutterwaveNgnBankChannelId = 'ngn_bank_flutterwave';

bool isYellowCardSendCorridor({
  required String countryCode,
  required String currency,
}) {
  final cc = countryCode.toUpperCase();
  const ycCountries = {
    'NG',
    'ZA',
    'KE',
    'GH',
    'UG',
    'TZ',
    'RW',
    'ZM',
    'BW',
    'CM',
    'CI',
    'SN',
    'ML',
    'BF',
    'TG',
    'BJ',
    'GA',
    'CG',
    'CD',
  };
  return ycCountries.contains(cc);
}

@Deprecated('Use isYellowCardSendCorridor — NG bank P2P goes through Yellow Card')
bool isNigeriaFlutterwaveCorridor({
  required String countryCode,
  required String currency,
}) {
  return countryCode.toUpperCase() == 'NG' && currency.toUpperCase() == 'NGN';
}
