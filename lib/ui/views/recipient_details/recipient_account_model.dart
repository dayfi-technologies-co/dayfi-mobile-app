class RecipientAccount {
  final int? id;
  final String? userId;
  final String accountNumber;
  final String accountName;
  final String bankName;
  final String bankCode;
  final String beneficiaryName;

  RecipientAccount({
    this.id,
    this.userId,
    required this.accountNumber,
    required this.accountName,
    required this.bankName,
    required this.bankCode,
    required this.beneficiaryName,
  });

  factory RecipientAccount.fromJson(Map<String, dynamic> json) {
    return RecipientAccount(
      id: json['id'],
      userId: json['user_id'],
      accountNumber: json['account_number'],
      accountName: json['account_name'],
      bankName: json['bank_name'],
      bankCode: json['bank_code'],
      beneficiaryName: json['beneficiary_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_number': accountNumber,
      'account_name': accountName,
      'bank_name': bankName,
      'bank_code': bankCode,
      'beneficiary_name': beneficiaryName,
    };
  }
}
