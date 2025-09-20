class WalletTransaction {
  final String id;
  final String walletTransactionsId;
  final String userId;
  final String? senderWalletId;
  final String? recipientWalletId;
  final String? externalAccountNumber;
  final String? externalBankCode;
  final String? externalBankName;
  final String amount;
  final String balance;
  final String fees;
  final String type;
  final String status;
  final String reference;
  final String narration;
  final Map<String, dynamic>? metadata;
  final String initiatedBy;
  final String createdAt;
  final String updatedAt;
  final String? cardLast4;
  final String? cardType;
  final String? cardBrand;
  final String? cardCountry;
  final String? cardToken;
  final String? cardTransactionRef;

  WalletTransaction({
    required this.id,
    required this.walletTransactionsId,
    required this.userId,
    this.senderWalletId,
    this.recipientWalletId,
    this.externalAccountNumber,
    this.externalBankCode,
    this.externalBankName,
    required this.amount,
    required this.balance,
    required this.fees,
    required this.type,
    required this.status,
    required this.reference,
    required this.narration,
    this.metadata,
    required this.initiatedBy,
    required this.createdAt,
    required this.updatedAt,
    this.cardLast4,
    this.cardType,
    this.cardBrand,
    this.cardCountry,
    this.cardToken,
    this.cardTransactionRef,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] ?? '',
      walletTransactionsId: json['wallet_transactions_id'] ?? '',
      userId: json['user_id'] ?? '',
      senderWalletId: json['sender_wallet_id'],
      recipientWalletId: json['recipient_wallet_id'],
      externalAccountNumber: json['external_account_number'],
      externalBankCode: json['external_bank_code'],
      externalBankName: json['external_bank_name'],
      amount: json['amount'] ?? '0.00',
      balance: json['balance'] ?? '0.00',
      fees: json['fees'] ?? '0.00',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      reference: json['reference'] ?? '',
      narration: json['narration'] ?? '',
      metadata: json['metadata'] ?? {},
      initiatedBy: json['initiated_by'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      cardLast4: json['card_last4'],
      cardType: json['card_type'],
      cardBrand: json['card_brand'],
      cardCountry: json['card_country'],
      cardToken: json['card_token'],
      cardTransactionRef: json['card_transaction_ref'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_transactions_id': walletTransactionsId,
      'user_id': userId,
      'sender_wallet_id': senderWalletId,
      'recipient_wallet_id': recipientWalletId,
      'external_account_number': externalAccountNumber,
      'external_bank_code': externalBankCode,
      'external_bank_name': externalBankName,
      'amount': amount,
      'balance': balance,
      'fees': fees,
      'type': type,
      'status': status,
      'reference': reference,
      'narration': narration,
      'metadata': metadata,
      'initiated_by': initiatedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'card_last4': cardLast4,
      'card_type': cardType,
      'card_brand': cardBrand,
      'card_country': cardCountry,
      'card_token': cardToken,
      'card_transaction_ref': cardTransactionRef,
    };
  }
}

class WalletTransactionHistoryResponse {
  final List<WalletTransaction> transactions;
  final int totalCount;
  final int totalPages;
  final int page;
  final int limit;

  WalletTransactionHistoryResponse({
    required this.transactions,
    required this.totalCount,
    required this.totalPages,
    required this.page,
    required this.limit,
  });

  factory WalletTransactionHistoryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return WalletTransactionHistoryResponse(
      transactions: (data['transactions'] as List<dynamic>)
          .map((e) => WalletTransaction.fromJson(e))
          .toList(),
      totalCount: data['totalCount'],
      totalPages: data['totalPages'],
      page: data['page'],
      limit: data['limit'],
    );
  }
}
