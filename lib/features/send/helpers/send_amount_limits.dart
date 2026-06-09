import 'package:dayfi/features/send/constants/yellow_card_send_limits.dart';

/// Currency-aware send amount chips, minimums, and Yellow Card corridor validation.
class SendAmountLimits {
  SendAmountLimits._();

  static List<double> quickAmountsFor(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
      case 'EUR':
      case 'GBP':
        return [2, 5, 10];
      default:
        return [2000, 5000, 10000];
    }
  }

  /// Minimum **send** amount for exempt rails (Dayfi tag, crypto).
  static double minimumFor({
    required String deliveryMethod,
    required String currency,
  }) {
    final cur = currency.toUpperCase();
    final method = deliveryMethod.toLowerCase();

    if (YellowCardSendLimits.isExemptDeliveryMethod(method)) {
      switch (cur) {
        case 'USD':
        case 'EUR':
        case 'GBP':
          return 1.0;
        default:
          return 1000.0;
      }
    }

    if (cur == 'USD' || cur == 'EUR' || cur == 'GBP') {
      return kYellowCardMinSendUsd;
    }
    return 2000.0;
  }

  static bool usesYellowCard({
    required String deliveryMethod,
    required String receiveCountry,
    required String receiveCurrency,
  }) {
    return YellowCardSendLimits.usesYellowCard(
      deliveryMethod: deliveryMethod,
      receiveCountry: receiveCountry,
      receiveCurrency: receiveCurrency,
    );
  }

  /// Validates send + receive against product and Yellow Card per-transaction limits.
  static SendAmountValidation validate({
    required String deliveryMethod,
    required String sendCurrency,
    required String receiveCountry,
    required String receiveCurrency,
    required double sendAmount,
    required double? receiveAmount,
  }) {
    const hardMaximumUsd = 5000000.0;
    final method = deliveryMethod.toLowerCase();

    if (sendAmount <= 0) {
      return SendAmountValidation.invalid('Enter valid amount');
    }

    if (YellowCardSendLimits.isExemptDeliveryMethod(method)) {
      final min = minimumFor(deliveryMethod: method, currency: sendCurrency);
      if (sendAmount < min) {
        return SendAmountValidation.invalid(
          'Minimum amount is ${_formatAmount(min, sendCurrency)}',
        );
      }
      if (sendAmount > hardMaximumUsd) {
        return SendAmountValidation.invalid(
          'Maximum amount is ${_formatAmount(hardMaximumUsd, sendCurrency)}',
        );
      }
      return SendAmountValidation.valid;
    }

    if (usesYellowCard(
      deliveryMethod: method,
      receiveCountry: receiveCountry,
      receiveCurrency: receiveCurrency,
    )) {
      if (sendCurrency.toUpperCase() == 'USD' &&
          sendAmount < kYellowCardMinSendUsd) {
        return SendAmountValidation.invalid(
          'Minimum send amount is \$${kYellowCardMinSendUsd.toStringAsFixed(2)}',
        );
      }

      final corridor = YellowCardSendLimits.forCorridor(
        countryCode: receiveCountry,
        currency: receiveCurrency,
        deliveryMethod: method,
      );

      if (corridor != null && receiveAmount != null && receiveAmount > 0) {
        if (receiveAmount < corridor.min) {
          return SendAmountValidation.invalid(
            'Minimum payout is ${_formatAmount(corridor.min, receiveCurrency)}',
          );
        }
        if (receiveAmount > corridor.max) {
          return SendAmountValidation.invalid(
            'Maximum payout is ${_formatAmount(corridor.max, receiveCurrency)}',
          );
        }
      } else if (corridor != null &&
          (receiveAmount == null || receiveAmount <= 0)) {
        return SendAmountValidation.invalid('Enter valid amount');
      }

      if (sendAmount > hardMaximumUsd) {
        return SendAmountValidation.invalid(
          'Maximum amount is ${_formatAmount(hardMaximumUsd, sendCurrency)}',
        );
      }

      return SendAmountValidation.valid;
    }

    final min = minimumFor(deliveryMethod: method, currency: sendCurrency);
    if (sendAmount < min) {
      return SendAmountValidation.invalid(
        'Minimum amount is ${_formatAmount(min, sendCurrency)}',
      );
    }
    if (sendAmount > hardMaximumUsd) {
      return SendAmountValidation.invalid(
        'Maximum amount is ${_formatAmount(hardMaximumUsd, sendCurrency)}',
      );
    }
    return SendAmountValidation.valid;
  }

  static String _formatAmount(double amount, String currency) {
    final cur = currency.toUpperCase();
    final symbol = switch (cur) {
      'USD' => r'$',
      'EUR' => '€',
      'GBP' => '£',
      'NGN' => '₦',
      'KES' => 'KSh ',
      'GHS' => 'GH₵',
      'ZAR' => 'R',
      _ => '',
    };
    final formatted = amount >= 1000
        ? amount
            .toStringAsFixed(0)
            .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},',
            )
        : amount.toStringAsFixed(2);
    return '$symbol$formatted';
  }
}

class SendAmountValidation {
  final bool isValid;
  final String? message;

  const SendAmountValidation._(this.isValid, this.message);

  static const valid = SendAmountValidation._(true, null);

  factory SendAmountValidation.invalid(String message) =>
      SendAmountValidation._(false, message);
}
