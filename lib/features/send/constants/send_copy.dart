/// User-facing helper copy for Send money flows.
abstract final class SendCopy {
  static const addRecipient = 'Enter bank or mobile money details.';
  static const saveRecipient = 'Save their details for next time.';
  static const enterAmount =
      'Type an amount in either field — we convert at the live rate.';

  static String cryptoEnterAmount({
    required String currency,
    required String address,
    required String network,
  }) =>
      'Sending $currency to $address on $network.';

  static String sendingToRecipient(String name) => 'Sending to $name.';
  static const reviewTransfer =
      'Confirm the details of your transfer before sending.';
  static const chooseDestination = 'Pick a country and currency to send to.';
  static const chooseRecipientCountry = 'Choose your recipient\'s country.';

  /// Platform transfer fee for bank / P2P (always charged in USD).
  static const double transferFeeUsd = 0.05;

  /// Default transfer reason sent to the API when the user does not pick one.
  static const String defaultTransferReason = 'other';
}
