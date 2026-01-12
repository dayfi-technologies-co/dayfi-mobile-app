import 'dart:convert';
import 'dart:developer';

class PaymentResponse {
  dynamic data;
  bool error;
  String message;
  int? statusCode;

  PaymentResponse({this.data, this.error = false, this.message = "", this.statusCode});

  factory PaymentResponse.fromJson(Map<String, dynamic> data) {
    log("PaymentResponse============> ${json.encode(data)}");
    
    // Handle status code - prioritize 'code' field, then 'status'
    int? statusCode;
    if (data['code'] != null) {
      statusCode = data['code'] is int ? data['code'] : int.tryParse(data['code'].toString());
    } else if (data['status'] != null) {
      statusCode = data['status'] is int ? data['status'] : int.tryParse(data['status'].toString());
    }
    
    // Handle error determination - check both status string and status code
    bool isError = true;
    if (data['status'] != null) {
      // If status is a string like "success" or "error"
      if (data['status'] is String) {
        isError = data['status'].toString().toLowerCase() != 'success';
      } else if (data['status'] is int) {
        isError = data['status'] != 200;
      }
    } else if (statusCode != null) {
      // Fallback to status code
      isError = statusCode != 200;
    }
    
    return PaymentResponse(
        error: isError,
        message: data['message'] ?? "",
        statusCode: statusCode,
        data: data['data'] != null ? PaymentData.fromJson(data['data']) : null);
  }
}

class PaymentData {
  // For bank resolution response
  String? accountNumber;
  String? accountName;
  String? accountBank;
  
  // For collection creation response
  String? currency;
  String? status;
  double? serviceFeeAmountUSD;
  double? partnerFeeAmountLocal;
  String? country;
  String? fiatWallet;
  String? reference;
  Recipient? recipient;
  String? expiresAt;
  String? requestSource;
  bool? directSettlement;
  int? refundRetry;
  String? id;
  String? partnerId;
  double? rate;
  BankInfo? bankInfo;
  bool? tier0Active;
  String? createdAt;
  bool? forceAccept;
  Source? source;
  String? sequenceId;
  String? reason;
  double? convertedAmount;
  String? channelId;
  double? serviceFeeAmountLocal;
  String? updatedAt;
  double? partnerFeeAmountUSD;
  double? amount;
  String? depositId;
  
  // For channels response
  List<Channel>? channels;
  
  // For raw channels data (e.g., crypto channels)
  dynamic rawChannels;
  
  // For networks response
  List<Network>? networks;
  
  // For rates response
  List<Rate>? rates;

  PaymentData({
    this.accountNumber,
    this.accountName,
    this.accountBank,
    this.currency,
    this.status,
    this.serviceFeeAmountUSD,
    this.partnerFeeAmountLocal,
    this.country,
    this.fiatWallet,
    this.reference,
    this.recipient,
    this.expiresAt,
    this.requestSource,
    this.directSettlement,
    this.refundRetry,
    this.id,
    this.partnerId,
    this.rate,
    this.bankInfo,
    this.tier0Active,
    this.createdAt,
    this.forceAccept,
    this.source,
    this.sequenceId,
    this.reason,
    this.convertedAmount,
    this.channelId,
    this.serviceFeeAmountLocal,
    this.updatedAt,
    this.partnerFeeAmountUSD,
    this.amount,
    this.depositId,
    this.channels,
    this.rawChannels,
    this.networks,
    this.rates,
  });

  /// Helper method to parse rates from API response
  /// Handles both old format (rates as List) and new format (single rate object with buyRate/sellRate)
  static List<Rate>? _parseRates(Map<String, dynamic> data) {
    // Old format: rates is a List
    if (data['rates'] != null && data['rates'] is List) {
      return (data['rates'] as List).map((e) => Rate.fromJson(e)).toList();
    }
    
    // New format: data itself contains buyRate/sellRate (single rate object)
    if (data['buyRate'] != null || data['sellRate'] != null) {
      return [Rate.fromJson(data)];
    }
    
    return null;
  }

  factory PaymentData.fromJson(Map<String, dynamic> data) {
    return PaymentData(
      accountNumber: data['accountNumber'],
      accountName: data['accountName'],
      accountBank: data['accountBank'],
      currency: data['currency'],
      status: data['status'],
      serviceFeeAmountUSD: data['serviceFeeAmountUSD']?.toDouble(),
      partnerFeeAmountLocal: data['partnerFeeAmountLocal']?.toDouble(),
      country: data['country'],
      fiatWallet: data['fiatWallet'],
      reference: data['reference'],
      recipient: data['recipient'] != null ? Recipient.fromJson(data['recipient']) : null,
      expiresAt: data['expiresAt'],
      requestSource: data['requestSource'],
      directSettlement: data['directSettlement'],
      refundRetry: data['refundRetry'],
      id: data['id'],
      partnerId: data['partnerId'],
      rate: data['rate']?.toDouble(),
      bankInfo: data['bankInfo'] != null ? BankInfo.fromJson(data['bankInfo']) : null,
      tier0Active: data['tier0Active'],
      createdAt: data['createdAt'],
      forceAccept: data['forceAccept'],
      source: data['source'] != null ? Source.fromJson(data['source']) : null,
      sequenceId: data['sequenceId'],
      reason: data['reason'],
      convertedAmount: data['convertedAmount']?.toDouble(),
      channelId: data['channelId'],
      serviceFeeAmountLocal: data['serviceFeeAmountLocal']?.toDouble(),
      updatedAt: data['updatedAt'],
      partnerFeeAmountUSD: data['partnerFeeAmountUSD']?.toDouble(),
      amount: data['amount']?.toDouble(),
      depositId: data['depositId'],
      channels: data['channels'] != null && data['channels'] is List
          ? (data['channels'] as List).map((e) {
              // Check if the channel data is a simple channel (has channelType, country, etc.)
              if (e is Map<String, dynamic> && e.containsKey('channelType')) {
                return Channel.fromJson(e);
              } else {
                return null;
              }
            }).where((e) => e != null).toList().cast<Channel>()
          : null,
      rawChannels: data['channels'],
      networks: data['networks'] != null 
          ? (data['networks'] as List).map((e) => Network.fromJson(e)).toList()
          : null,
      // Handle both old format (rates as List) and new format (single rate object with buyRate/sellRate)
      rates: _parseRates(data),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'accountName': accountName,
      'accountBank': accountBank,
      'currency': currency,
      'status': status,
      'serviceFeeAmountUSD': serviceFeeAmountUSD,
      'partnerFeeAmountLocal': partnerFeeAmountLocal,
      'country': country,
      'fiatWallet': fiatWallet,
      'reference': reference,
      'recipient': recipient?.toJson(),
      'expiresAt': expiresAt,
      'requestSource': requestSource,
      'directSettlement': directSettlement,
      'refundRetry': refundRetry,
      'id': id,
      'partnerId': partnerId,
      'rate': rate,
      'bankInfo': bankInfo?.toJson(),
      'tier0Active': tier0Active,
      'createdAt': createdAt,
      'forceAccept': forceAccept,
      'source': source?.toJson(),
      'sequenceId': sequenceId,
      'reason': reason,
      'convertedAmount': convertedAmount,
      'channelId': channelId,
      'serviceFeeAmountLocal': serviceFeeAmountLocal,
      'updatedAt': updatedAt,
      'partnerFeeAmountUSD': partnerFeeAmountUSD,
      'amount': amount,
      'depositId': depositId,
      'channels': channels?.map((e) => e.toJson()).toList(),
      'rawChannels': rawChannels,
      'networks': networks?.map((e) => e.toJson()).toList(),
      'rates': rates?.map((e) => e.toJson()).toList(),
    };
  }
}

class Recipient {
  String? country;
  String? address;
  String? idType;
  String? phone;
  String? dob;
  String? name;
  String? idNumber;
  String? email;

  Recipient({
    this.country,
    this.address,
    this.idType,
    this.phone,
    this.dob,
    this.name,
    this.idNumber,
    this.email,
  });

  factory Recipient.fromJson(Map<String, dynamic> data) {
    return Recipient(
      country: data['country'],
      address: data['address'],
      idType: data['idType'],
      phone: data['phone'],
      dob: data['dob'],
      name: data['name'],
      idNumber: data['idNumber'],
      email: data['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'address': address,
      'idType': idType,
      'phone': phone,
      'dob': dob,
      'name': name,
      'idNumber': idNumber,
      'email': email,
    };
  }
}

class BankInfo {
  String? name;
  String? accountNumber;
  String? accountName;

  BankInfo({
    this.name,
    this.accountNumber,
    this.accountName,
  });

  factory BankInfo.fromJson(Map<String, dynamic> data) {
    return BankInfo(
      name: data['name'],
      accountNumber: data['accountNumber'],
      accountName: data['accountName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'accountNumber': accountNumber,
      'accountName': accountName,
    };
  }
}

class Source {
  String? accountType;
  String? accountNumber;
  String? networkId;

  Source({
    this.accountType,
    this.accountNumber,
    this.networkId,
  });

  factory Source.fromJson(Map<String, dynamic> data) {
    return Source(
      accountType: data['accountType'],
      accountNumber: data['accountNumber'],
      networkId: data['networkId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountType': accountType,
      'accountNumber': accountNumber,
      'networkId': networkId,
    };
  }
}

class Channel {
  double? max;
  String? currency;
  String? countryCurrency;
  String? status;
  double? feeLocal;
  String? createdAt;
  String? vendorId;
  String? country;
  String? widgetStatus;
  double? feeUSD;
  double? min;
  String? channelType;
  String? rampType;
  String? updatedAt;
  String? apiStatus;
  String? settlementType;
  int? estimatedSettlementTime;
  String? id;
  double? successThreshold;
  double? widgetMin;
  String? commercialStatus;
  double? widgetMax;

  Channel({
    this.max,
    this.currency,
    this.countryCurrency,
    this.status,
    this.feeLocal,
    this.createdAt,
    this.vendorId,
    this.country,
    this.widgetStatus,
    this.feeUSD,
    this.min,
    this.channelType,
    this.rampType,
    this.updatedAt,
    this.apiStatus,
    this.settlementType,
    this.estimatedSettlementTime,
    this.id,
    this.successThreshold,
    this.widgetMin,
    this.commercialStatus,
    this.widgetMax,
  });

  factory Channel.fromJson(Map<String, dynamic> data) {
    return Channel(
      max: data['max']?.toDouble(),
      currency: data['currency'],
      countryCurrency: data['countryCurrency'],
      status: data['status'],
      feeLocal: data['feeLocal']?.toDouble(),
      createdAt: data['createdAt'],
      vendorId: data['vendorId'],
      country: data['country'],
      widgetStatus: data['widgetStatus'],
      feeUSD: data['feeUSD']?.toDouble(),
      min: data['min']?.toDouble(),
      channelType: data['channelType'],
      rampType: data['rampType'],
      updatedAt: data['updatedAt'],
      apiStatus: data['apiStatus'],
      settlementType: data['settlementType'],
      estimatedSettlementTime: data['estimatedSettlementTime'],
      id: data['id'],
      successThreshold: data['successThreshold']?.toDouble(),
      widgetMin: data['widgetMin']?.toDouble(),
      commercialStatus: data['commercialStatus'],
      widgetMax: data['widgetMax']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max': max,
      'currency': currency,
      'countryCurrency': countryCurrency,
      'status': status,
      'feeLocal': feeLocal,
      'createdAt': createdAt,
      'vendorId': vendorId,
      'country': country,
      'widgetStatus': widgetStatus,
      'feeUSD': feeUSD,
      'min': min,
      'channelType': channelType,
      'rampType': rampType,
      'updatedAt': updatedAt,
      'apiStatus': apiStatus,
      'settlementType': settlementType,
      'estimatedSettlementTime': estimatedSettlementTime,
      'id': id,
      'successThreshold': successThreshold,
      'widgetMin': widgetMin,
      'commercialStatus': commercialStatus,
      'widgetMax': widgetMax,
    };
  }
}

class Network {
  dynamic code; // Can be String or Map<String, String>
  String? updatedAt;
  String? status;
  List<String>? channelIds;
  String? createdAt;
  String? accountNumberType;
  String? id;
  String? country;
  String? name;
  String? countryAccountNumberType;
  List<String>? tempDisabledFor;
  List<String>? featureFlagEnabled;

  Network({
    this.code,
    this.updatedAt,
    this.status,
    this.channelIds,
    this.createdAt,
    this.accountNumberType,
    this.id,
    this.country,
    this.name,
    this.countryAccountNumberType,
    this.tempDisabledFor,
    this.featureFlagEnabled,
  });

  factory Network.fromJson(Map<String, dynamic> data) {
    return Network(
      code: data['code'],
      updatedAt: data['updatedAt'],
      status: data['status'],
      channelIds: data['channelIds'] != null 
          ? List<String>.from(data['channelIds'])
          : null,
      createdAt: data['createdAt'],
      accountNumberType: data['accountNumberType'],
      id: data['id'],
      country: data['country'],
      name: data['name'],
      countryAccountNumberType: data['countryAccountNumberType'],
      tempDisabledFor: data['tempDisabledFor'] != null 
          ? List<String>.from(data['tempDisabledFor'])
          : null,
      featureFlagEnabled: data['featureFlagEnabled'] != null 
          ? List<String>.from(data['featureFlagEnabled'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'updatedAt': updatedAt,
      'status': status,
      'channelIds': channelIds,
      'createdAt': createdAt,
      'accountNumberType': accountNumberType,
      'id': id,
      'country': country,
      'name': name,
      'countryAccountNumberType': countryAccountNumberType,
      'tempDisabledFor': tempDisabledFor,
      'featureFlagEnabled': featureFlagEnabled,
    };
  }
}

class Rate {
  double? buy;
  double? sell;
  String? locale;
  String? rateId;
  String? code;
  String? updatedAt;

  Rate({
    this.buy,
    this.sell,
    this.locale,
    this.rateId,
    this.code,
    this.updatedAt,
  });

  factory Rate.fromJson(Map<String, dynamic> data) {
    // Handle both old format (buy/sell) and new format (buyRate/sellRate)
    double? buyRate = data['buy']?.toDouble();
    double? sellRate = data['sell']?.toDouble();
    
    // If old format fields are null, try new format
    if (buyRate == null && data['buyRate'] != null) {
      buyRate = double.tryParse(data['buyRate'].toString());
    }
    if (sellRate == null && data['sellRate'] != null) {
      sellRate = double.tryParse(data['sellRate'].toString());
    }
    
    return Rate(
      buy: buyRate,
      sell: sellRate,
      locale: data['locale'],
      rateId: data['rateId'],
      code: data['code'] ?? data['currency'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buy': buy,
      'sell': sell,
      'locale': locale,
      'rateId': rateId,
      'code': code,
      'updatedAt': updatedAt,
    };
  }
}
