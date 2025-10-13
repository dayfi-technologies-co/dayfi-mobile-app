import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/models/payment_response.dart' as payment;

class BeneficiaryWithSource {
  final Beneficiary beneficiary;
  final payment.Source source;

  BeneficiaryWithSource({
    required this.beneficiary,
    required this.source,
  });

  factory BeneficiaryWithSource.fromJson(Map<String, dynamic> json) {
    return BeneficiaryWithSource(
      beneficiary: Beneficiary.fromJson(json['beneficiary']),
      source: payment.Source.fromJson(json['source']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'beneficiary': {
        'id': beneficiary.id,
        'name': beneficiary.name,
        'country': beneficiary.country,
        'phone': beneficiary.phone,
        'address': beneficiary.address,
        'dob': beneficiary.dob,
        'email': beneficiary.email,
        'idNumber': beneficiary.idNumber,
        'idType': beneficiary.idType,
      },
      'source': source.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BeneficiaryWithSource &&
        other.beneficiary.name == beneficiary.name &&
        other.source.accountNumber == source.accountNumber &&
        other.source.networkId == source.networkId;
  }

  @override
  int get hashCode {
    return Object.hash(
      beneficiary.name,
      source.accountNumber,
      source.networkId,
    );
  }
}
