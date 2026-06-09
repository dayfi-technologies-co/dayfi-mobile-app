import 'dart:convert';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/models/payment_response.dart' as payment;

List<dynamic> beneficiariesFromJson(String str) => List<dynamic>.from(json.decode(str));

class BeneficiaryWithSource {
  final Beneficiary beneficiary;
  final payment.Source source;
  final String? ledgerCurrency;

  BeneficiaryWithSource({
    required this.beneficiary,
    required this.source,
    this.ledgerCurrency,
  });

  factory BeneficiaryWithSource.fromJson(Map<String, dynamic> json) {
    return BeneficiaryWithSource(
      beneficiary: Beneficiary.fromJson(json['beneficiary']),
      source: payment.Source.fromJson(json['source']),
      ledgerCurrency: json['ledgerCurrency']?.toString(),
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
        'accountNumber': beneficiary.accountNumber,
        'accountType': beneficiary.accountType,
        if (beneficiary.bankName != null) 'bankName': beneficiary.bankName,
      },
      'source': source.toJson(),
      if (ledgerCurrency != null) 'ledgerCurrency': ledgerCurrency,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BeneficiaryWithSource &&
        other.beneficiary.name == beneficiary.name &&
        other.source.accountNumber == source.accountNumber &&
        other.source.networkId == source.networkId &&
        other.source.accountType == source.accountType &&
        other.ledgerCurrency == ledgerCurrency;
  }

  @override
  int get hashCode {
    return Object.hash(
      beneficiary.name,
      source.accountNumber,
      source.networkId,
      source.accountType,
      ledgerCurrency,
    );
  }
}
