class Wallet {
  final String walletId;
  final String userId;
  final String walletReference;
  final String? accountName;
  final String dayfiId;
  final String? accountNumber;
  final String? bankCode;
  final String? bankName;
  final String balance;
  final String currency;
  final String provider;
  final String createdAt;
  final String updatedAt;

  Wallet({
    required this.walletId,
    required this.userId,
    required this.walletReference,
    this.accountName,
    required this.dayfiId,
    this.accountNumber,
    this.bankCode,
    this.bankName,
    required this.balance,
    required this.currency,
    required this.provider,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      walletId: json['wallet_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      walletReference: json['wallet_reference']?.toString() ?? '',
      accountName: json['account_name']?.toString(),
      dayfiId: json['dayfi_id']?.toString() ?? '',
      accountNumber: json['account_number']?.toString(),
      bankCode: json['bank_code']?.toString(),
      bankName: json['bank_name']?.toString(),
      balance: json['balance']?.toString() ?? '0.00',
      currency: json['currency']?.toString() ?? 'NGN',
      provider: json['provider']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
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

  /// Get balance as double for calculations
  double get balanceAsDouble {
    return double.tryParse(balance) ?? 0.0;
  }

  /// Get formatted balance with currency symbol
  String get formattedBalance {
    final symbol = _getCurrencySymbol(currency);
    return '$symbol$balance';
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'NGN':
        return '₦';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      default:
        return currency;
    }
  }
}

class WalletDetailsResponse {
  final String status;
  final String message;
  final int code;
  final List<Wallet> wallets;

  WalletDetailsResponse({
    required this.status,
    required this.message,
    required this.code,
    required this.wallets,
  });

  factory WalletDetailsResponse.fromJson(Map<String, dynamic> json) {
    final walletsList = json['data'];
    List<Wallet> wallets = [];

    if (walletsList is List) {
      for (var walletData in walletsList) {
        if (walletData is Map<String, dynamic>) {
          wallets.add(Wallet.fromJson(walletData));
        }
      }
    }

    return WalletDetailsResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      code: json['code'] is int 
          ? json['code'] 
          : int.tryParse(json['code']?.toString() ?? '200') ?? 200,
      wallets: wallets,
    );
  }
}

