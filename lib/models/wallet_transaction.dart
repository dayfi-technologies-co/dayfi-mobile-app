class WalletTransactionResponse {
  final String status;
  final String message;
  final int code;
  final WalletTransactionData data;

  WalletTransactionResponse({
    required this.status,
    required this.message,
    required this.code,
    required this.data,
  });

  factory WalletTransactionResponse.fromJson(Map<String, dynamic> json) {
    try {
      // print('Parsing WalletTransactionResponse from: $json');
      return WalletTransactionResponse(
        status: json['status']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        code: json['code'] is int ? json['code'] : int.tryParse(json['code']?.toString() ?? '0') ?? 0,
        data: WalletTransactionData.fromJson(json['data'] is Map<String, dynamic> 
            ? json['data'] as Map<String, dynamic>
            : {}),
      );
    } catch (e) {
      // print('Error parsing WalletTransactionResponse: $e');
      // print('JSON data: $json');
      rethrow;
    }
  }
}

class WalletTransactionData {
  final List<WalletTransaction> transactions;
  final int totalCount;
  final int totalPages;
  final int page;
  final int limit;

  WalletTransactionData({
    required this.transactions,
    required this.totalCount,
    required this.totalPages,
    required this.page,
    required this.limit,
  });

  factory WalletTransactionData.fromJson(Map<String, dynamic> json) {
    try {
      // print('Parsing WalletTransactionData from: $json');
      final transactionsList = json['transactions'];
      List<WalletTransaction> transactions = [];
      
      if (transactionsList is List) {
        for (int i = 0; i < transactionsList.length; i++) {
          try {
            final transactionData = transactionsList[i];
            if (transactionData is Map<String, dynamic>) {
              transactions.add(WalletTransaction.fromJson(transactionData));
            } else {
              // print('Transaction $i is not a Map: $transactionData');
            }
          } catch (e) {
            // print('Error parsing transaction $i: $e');
            // print('Transaction data: ${transactionsList[i]}');
          }
        }
      }
      
      return WalletTransactionData(
        transactions: transactions,
        totalCount: json['totalCount'] is int ? json['totalCount'] : int.tryParse(json['totalCount']?.toString() ?? '0') ?? 0,
        totalPages: json['totalPages'] is int ? json['totalPages'] : int.tryParse(json['totalPages']?.toString() ?? '0') ?? 0,
        page: json['page'] is int ? json['page'] : int.tryParse(json['page']?.toString() ?? '1') ?? 1,
        limit: json['limit'] is int ? json['limit'] : int.tryParse(json['limit']?.toString() ?? '10') ?? 10,
      );
    } catch (e) {
      // print('Error parsing WalletTransactionData: $e');
      // print('JSON data: $json');
      rethrow;
    }
  }
}

class WalletTransaction {
  final String id;
  final String? sendChannel;
  final String? sendNetwork;
  final double? sendAmount;
  final String? receiveChannel;
  final String? receiveNetwork;
  final double? receiveAmount;
  final double? fee;
  final String status;
  final String? reason;
  final String timestamp;
  final Beneficiary beneficiary;
  final Source source;

  WalletTransaction({
    required this.id,
    this.sendChannel,
    this.sendNetwork,
    this.sendAmount,
    this.receiveChannel,
    this.receiveNetwork,
    this.receiveAmount,
    this.fee,
    required this.status,
    this.reason,
    required this.timestamp,
    required this.beneficiary,
    required this.source,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    try {
      // print('🔍 Parsing transaction: ${json['id']} | send_amount: ${json['send_amount']} | receive_amount: ${json['receive_amount']}');
      return WalletTransaction(
        id: json['id']?.toString() ?? '',
        sendChannel: json['send_channel']?.toString(),
        sendNetwork: json['send_network']?.toString(),
        sendAmount: json['send_amount'] != null ? double.tryParse(json['send_amount'].toString()) : null,
        receiveChannel: json['receive_channel']?.toString(),
        receiveNetwork: json['receive_network']?.toString(),
        receiveAmount: json['receive_amount'] != null ? double.tryParse(json['receive_amount'].toString()) : null,
        fee: json['fee'] != null ? double.tryParse(json['fee'].toString()) : null,
        status: json['status']?.toString() ?? '',
        reason: json['reason']?.toString(),
        timestamp: json['timestamp']?.toString() ?? '',
        beneficiary: Beneficiary.fromJson(json['beneficiary'] is Map<String, dynamic> 
            ? json['beneficiary'] as Map<String, dynamic>
            : {}),
        source: Source.fromJson(json['source'] is Map<String, dynamic>
            ? json['source'] as Map<String, dynamic>
            : {}),
      );
    } catch (e) {
      // print('Error parsing WalletTransaction: $e');
      // print('Transaction JSON: $json');
      rethrow;
    }
  }
}

class Beneficiary {
  final String id;
  final String name;
  final String country;
  final String phone;
  final String address;
  final String dob;
  final String email;
  final String idNumber;
  final String idType;
  final String? accountNumber;
  final String? accountType;

  Beneficiary({
    required this.id,
    required this.name,
    required this.country,
    required this.phone,
    required this.address,
    required this.dob,
    required this.email,
    required this.idNumber,
    required this.idType,
    this.accountNumber,
    this.accountType,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    try {
      return Beneficiary(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        country: json['network_country']?.toString() ?? json['country']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        dob: json['dob']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        idNumber: json['idNumber']?.toString() ?? '',
        idType: json['idType']?.toString() ?? '',
        accountNumber: json['account_number']?.toString(),
        accountType: json['account_type']?.toString(),
      );
    } catch (e) {
      // print('Error parsing Beneficiary: $e');
      // print('Beneficiary JSON: $json');
      rethrow;
    }
  }
}

class Source {
  final String? id;
  final String? accountType;
  final String? accountNumber;
  final String? networkId;
  final String? beneficiaryId;
  final String? dayfiId;

  Source({
    this.id,
    this.accountType,
    this.accountNumber,
    this.networkId,
    this.beneficiaryId,
    this.dayfiId,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    try {
      return Source(
        id: json['id']?.toString(),
        accountType: json['accountType']?.toString() ?? json['account_type']?.toString(),
        accountNumber: json['accountNumber']?.toString() ?? json['account_number']?.toString(),
        networkId: json['networkId']?.toString() ?? json['network_id']?.toString(),
        beneficiaryId: json['beneficiaryId']?.toString() ?? json['beneficiary_id']?.toString(),
        dayfiId: json['dayfi_id']?.toString() ?? json['dayfiId']?.toString(),
      );
    } catch (e) {
      // print('Error parsing Source: $e');
      // print('Source JSON: $json');
      rethrow;
    }
  }
}
