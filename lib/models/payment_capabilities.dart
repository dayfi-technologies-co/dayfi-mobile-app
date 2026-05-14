/// Server-driven flags from `GET /payments/capabilities`.
class PaymentCapabilities {
  final bool stablecoinTopup;
  final bool yellowCardReady;

  const PaymentCapabilities({
    required this.stablecoinTopup,
    required this.yellowCardReady,
  });

  factory PaymentCapabilities.fromJson(Map<String, dynamic> json) {
    return PaymentCapabilities(
      stablecoinTopup: json['stablecoinTopup'] == true,
      yellowCardReady: json['yellowCardReady'] == true,
    );
  }

  static const PaymentCapabilities empty = PaymentCapabilities(
    stablecoinTopup: false,
    yellowCardReady: false,
  );
}
