import 'package:dayfi/features/send/constants/payment_rails.dart';

/// Yellow Card **Send** transaction limits (local payout currency).
/// Source: https://docs.yellowcard.engineering/docs/transaction-limits
class YellowCardSendLimit {
  final String countryCode;
  final String currency;
  final String paymentMethod;
  final double min;
  final double max;

  const YellowCardSendLimit({
    required this.countryCode,
    required this.currency,
    required this.paymentMethod,
    required this.min,
    required this.max,
  });
}

/// Product minimum for USD-wallet Yellow Card sends (before FX).
const double kYellowCardMinSendUsd = 1.0;

const List<YellowCardSendLimit> kYellowCardSendLimits = [
  YellowCardSendLimit(countryCode: 'BJ', currency: 'XOF', paymentMethod: 'mobile_money', min: 500, max: 1500000),
  YellowCardSendLimit(countryCode: 'BW', currency: 'BWP', paymentMethod: 'bank_transfer', min: 150, max: 1000000),
  YellowCardSendLimit(countryCode: 'BW', currency: 'BWP', paymentMethod: 'mobile_money', min: 150, max: 10000),
  YellowCardSendLimit(countryCode: 'BF', currency: 'XOF', paymentMethod: 'mobile_money', min: 500, max: 1500000),
  YellowCardSendLimit(countryCode: 'CM', currency: 'XAF', paymentMethod: 'mobile_money', min: 1000, max: 1000000),
  YellowCardSendLimit(countryCode: 'CG', currency: 'XAF', paymentMethod: 'bank_transfer', min: 1000, max: 1500000),
  YellowCardSendLimit(countryCode: 'CD', currency: 'CDF', paymentMethod: 'mobile_money', min: 1000, max: 5000000),
  YellowCardSendLimit(countryCode: 'CI', currency: 'XOF', paymentMethod: 'mobile_money', min: 500, max: 1500000),
  YellowCardSendLimit(countryCode: 'GA', currency: 'XAF', paymentMethod: 'bank_transfer', min: 1000, max: 10000000),
  YellowCardSendLimit(countryCode: 'KE', currency: 'KES', paymentMethod: 'bank_transfer', min: 500, max: 999999),
  YellowCardSendLimit(countryCode: 'KE', currency: 'KES', paymentMethod: 'mobile_money', min: 150, max: 250000),
  YellowCardSendLimit(countryCode: 'MW', currency: 'MWK', paymentMethod: 'bank_transfer', min: 5000, max: 20000000),
  YellowCardSendLimit(countryCode: 'MW', currency: 'MWK', paymentMethod: 'mobile_money', min: 5000, max: 750000),
  YellowCardSendLimit(countryCode: 'ML', currency: 'XOF', paymentMethod: 'mobile_money', min: 500, max: 1500000),
  YellowCardSendLimit(countryCode: 'NG', currency: 'NGN', paymentMethod: 'bank_transfer', min: 1800, max: 30000000),
  YellowCardSendLimit(countryCode: 'NG', currency: 'NGN', paymentMethod: 'mobile_money', min: 1800, max: 30000000),
  YellowCardSendLimit(countryCode: 'RW', currency: 'RWF', paymentMethod: 'bank_transfer', min: 1500, max: 10000000),
  YellowCardSendLimit(countryCode: 'RW', currency: 'RWF', paymentMethod: 'mobile_money', min: 1500, max: 10000000),
  YellowCardSendLimit(countryCode: 'SN', currency: 'XOF', paymentMethod: 'mobile_money', min: 1000, max: 200000),
  YellowCardSendLimit(countryCode: 'ZA', currency: 'ZAR', paymentMethod: 'bank_transfer', min: 200, max: 500000),
  YellowCardSendLimit(countryCode: 'TZ', currency: 'TZS', paymentMethod: 'bank_transfer', min: 2500, max: 150000000),
  YellowCardSendLimit(countryCode: 'TZ', currency: 'TZS', paymentMethod: 'mobile_money', min: 2500, max: 10000000),
  YellowCardSendLimit(countryCode: 'TG', currency: 'XOF', paymentMethod: 'mobile_money', min: 500, max: 1500000),
  YellowCardSendLimit(countryCode: 'UG', currency: 'UGX', paymentMethod: 'bank_transfer', min: 15000, max: 36000000),
  YellowCardSendLimit(countryCode: 'UG', currency: 'UGX', paymentMethod: 'mobile_money', min: 15000, max: 3000000),
  YellowCardSendLimit(countryCode: 'ZM', currency: 'ZMW', paymentMethod: 'bank_transfer', min: 100, max: 15000000),
  YellowCardSendLimit(countryCode: 'ZM', currency: 'ZMW', paymentMethod: 'mobile_money', min: 100, max: 20000),
];

class YellowCardSendLimits {
  YellowCardSendLimits._();

  static bool isExemptDeliveryMethod(String deliveryMethod) {
    final method = deliveryMethod.toLowerCase();
    return method == 'dayfi_tag' ||
        method == 'crypto' ||
        method == 'cryptocurrency';
  }

  static bool usesYellowCard({
    required String deliveryMethod,
    required String receiveCountry,
    required String receiveCurrency,
  }) {
    if (isExemptDeliveryMethod(deliveryMethod)) return false;
    return isYellowCardSendCorridor(
      countryCode: receiveCountry,
      currency: receiveCurrency,
    );
  }

  static String normalizePaymentMethod(String deliveryMethod) {
    final method = deliveryMethod.toLowerCase();
    if (method.contains('mobile') || method == 'momo') return 'mobile_money';
    if (method.contains('eft')) return 'instant_eft';
    if (method.contains('bank') || method == 'bank_transfer') {
      return 'bank_transfer';
    }
    return 'bank_transfer';
  }

  static YellowCardSendLimit? forCorridor({
    required String countryCode,
    required String currency,
    required String deliveryMethod,
  }) {
    final country = countryCode.toUpperCase();
    final cur = currency.toUpperCase();
    final paymentMethod = normalizePaymentMethod(deliveryMethod);

    for (final limit in kYellowCardSendLimits) {
      if (limit.countryCode == country &&
          limit.currency == cur &&
          limit.paymentMethod == paymentMethod) {
        return limit;
      }
    }

    if (country == 'NG' && cur == 'NGN') {
      return kYellowCardSendLimits.firstWhere(
        (l) =>
            l.countryCode == 'NG' &&
            l.paymentMethod == paymentMethod,
        orElse: () => kYellowCardSendLimits.firstWhere(
          (l) => l.countryCode == 'NG' && l.paymentMethod == 'bank_transfer',
        ),
      );
    }

    return null;
  }
}
