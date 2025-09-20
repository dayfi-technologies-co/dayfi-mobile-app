class Wallet {
  final String walletId;
  final String userId;
  final String walletReference;
  final String accountName;
  final String? dayfiId;
  final String accountNumber;
  final String? bankCode;
  final String bankName;
  final String balance;
  final String currency;
  final String provider;
  final String createdAt;
  final String updatedAt;

  static var empty;

  Wallet({
    required this.walletId,
    required this.userId,
    required this.walletReference,
    required this.accountName,
    this.dayfiId,
    required this.accountNumber,
    this.bankCode,
    required this.bankName,
    required this.balance,
    required this.currency,
    required this.provider,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      walletId: json['wallet_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      walletReference: json['wallet_reference'] as String? ?? '',
      accountName: json['account_name'] as String? ?? '',
      dayfiId: json['dayfi_id'] as String?,
      accountNumber: json['account_number'] as String? ?? '',
      bankCode: json['bank_code'] as String?,
      bankName: json['bank_name'] as String? ?? '',
      balance: json['balance'] as String? ?? '',
      currency: json['currency'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_id': walletId,
      'user_id': userId,
      'wallet_reference': walletReference,
      'account_name': accountName,
      'dayfi_id': dayfiId,
      'account_number': accountNumber,
      'bank_code': bankCode,
      'bank_name': bankName,
      'balance': balance,
      'currency': currency,
      'provider': provider,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class WalletResponse {
  final String status;
  final String message;
  final int code;
  final List<Wallet> data;

  WalletResponse({
    required this.status,
    required this.message,
    required this.code,
    required this.data,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Wallet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'code': code,
      'data': data.map((wallet) => wallet.toJson()).toList(),
    };
  }
}

class WalletResponse2 {
  final String status;
  final String message;
  final int code;
  final Wallet data;

  WalletResponse2({
    required this.status,
    required this.message,
    required this.code,
    required this.data,
  });

  // Deserialize JSON to WalletResponse
  factory WalletResponse2.fromJson(Map<String, dynamic> json) {
    return WalletResponse2(
      status: json['status'] as String? ?? 'unknown',
      message: json['message'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      data: Wallet.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }

  // Serialize WalletResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'code': code,
      'data': data.toJson(),
    };
  }
}
