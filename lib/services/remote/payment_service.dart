import 'dart:convert';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/models/payment_capabilities.dart';
import 'package:dayfi/models/payment_response.dart';
import 'package:dayfi/models/fees_response.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/services/remote/network/api_error.dart';
import 'package:dayfi/services/remote/network/url_config.dart';
import 'package:dayfi/common/utils/app_logger.dart';

class PaymentService {
  NetworkService _networkService;
  PaymentService({required NetworkService networkService})
    : _networkService = networkService;

  void updateNetworkService() =>
      _networkService = NetworkService(baseUrl: F.baseUrl);

  /// Resolve bank account details
  /// POST /api/v1/payments/resolve-bank
  Future<PaymentResponse> resolveBank({
    required String accountNumber,
    required String networkId,
  }) async {
    try {
      Map<String, dynamic> map = {};
      map['accountNumber'] = accountNumber;
      map['networkId'] = networkId;

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.resolveBank,
        RequestMethod.post,
        data: map,
      );

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        // Try to parse JSON string
        responseData = json.decode(response.data);
      } else {
        throw Exception('Invalid response format');
      }

      final paymentResponse = PaymentResponse.fromJson(responseData);

      return paymentResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<PaymentResponse> fetchChannels() async {
    try {
      final response = await _networkService.call(
        F.baseUrl + UrlConfig.fetchChannels,
        RequestMethod.get,
      );

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        // Try to parse JSON string
        try {
          responseData = json.decode(response.data);
        } catch (jsonError) {
          throw Exception('Failed to parse JSON response: $jsonError');
        }
      } else {
        throw Exception(
          'Invalid response format: ${response.data.runtimeType}',
        );
      }

      final paymentResponse = PaymentResponse.fromJson(responseData);

      return paymentResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// GET /payments/capabilities — stablecoin / Yellow Card feature flags.
  ///
  /// Production uses the server value only. On **dev** and **pilot** flavors, if
  /// the API says `stablecoinTopup: false` (YC keys / env not ready yet), we
  /// still expose the Digital Dollar top-up path so QA can reach the intro +
  /// channels flow (channels may be empty until the backend is configured).
  /// Opt out: `--dart-define=DAYFI_FORCE_STABLECOIN_TOPUP=false`
  Future<PaymentCapabilities> fetchPaymentCapabilities() async {
    final fromApi = await _fetchPaymentCapabilitiesFromNetwork();
    if (fromApi.stablecoinTopup) return fromApi;
    if (F.appFlavor == Flavor.prod) return fromApi;

    const String forceDefine = String.fromEnvironment(
      'DAYFI_FORCE_STABLECOIN_TOPUP',
    );
    if (forceDefine == 'false') return fromApi;

    return PaymentCapabilities(
      stablecoinTopup: true,
      yellowCardReady: fromApi.yellowCardReady,
    );
  }

  Future<PaymentCapabilities> _fetchPaymentCapabilitiesFromNetwork() async {
    try {
      final response = await _networkService.call(
        F.baseUrl + UrlConfig.paymentCapabilities,
        RequestMethod.get,
      );

      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        responseData = json.decode(response.data) as Map<String, dynamic>;
      } else {
        return PaymentCapabilities.empty;
      }

      final data = responseData['data'];
      if (data is Map<String, dynamic>) {
        return PaymentCapabilities.fromJson(data);
      }
      return PaymentCapabilities.empty;
    } catch (_) {
      return PaymentCapabilities.empty;
    }
  }

  /// Fetch available payment networks
  /// GET /api/v1/payments/networks
  Future<PaymentResponse> fetchNetworks() async {
    try {
      final response = await _networkService.call(
        F.baseUrl + UrlConfig.fetchNetworks,
        RequestMethod.get,
      );

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        // Try to parse JSON string
        responseData = json.decode(response.data);
      } else {
        throw Exception('Invalid response format');
      }

      final paymentResponse = PaymentResponse.fromJson(responseData);

      return paymentResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch exchange rates
  /// GET /api/v1/payments/rates?currency={currency}
  Future<PaymentResponse> fetchRates({String? currency}) async {
    try {
      String url = F.baseUrl + UrlConfig.fetchRates;
      if (currency != null && currency.isNotEmpty) {
        url += '?currency=$currency';
      }

      final response = await _networkService.call(url, RequestMethod.get);

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        // Try to parse JSON string
        responseData = json.decode(response.data);
      } else {
        throw Exception('Invalid response format');
      }

      final paymentResponse = PaymentResponse.fromJson(responseData);

      return paymentResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Create collection request
  /// POST /api/v1/payments/create-collections
  Future<PaymentResponse> createCollection(
    Map<String, dynamic> requestData,
  ) async {
    try {
      final response = await _networkService.call(
        '${F.baseUrl}/payments/create-collections',
        RequestMethod.post,
        data: requestData,
      );

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        // Try to parse JSON string
        responseData = json.decode(response.data);
      } else {
        throw Exception('Invalid response format');
      }

      final paymentResponse = PaymentResponse.fromJson(responseData);

      return paymentResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Create payment request
  /// POST /api/v1/payments/create-payment-request
  Future<PaymentResponse> createPayment(
    Map<String, dynamic> requestData,
  ) async {
    try {
      final response = await _networkService.call(
        '${F.baseUrl}/payments/create-payment-request',
        RequestMethod.post,
        data: requestData,
      );

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        // Try to parse JSON string
        responseData = json.decode(response.data);
      } else {
        throw Exception('Invalid response format');
      }

      final paymentResponse = PaymentResponse.fromJson(responseData);

      return paymentResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Create settlement request
  /// POST /api/v1/payments/settlement
  Future<PaymentResponse> createSettlement(
    Map<String, dynamic> requestData,
  ) async {
    try {
      final response = await _networkService.call(
        '${F.baseUrl}/payments/settlement',
        RequestMethod.post,
        data: requestData,
      );

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        // Try to parse JSON string
        responseData = json.decode(response.data);
      } else {
        throw Exception('Invalid response format');
      }

      final paymentResponse = PaymentResponse.fromJson(responseData);

      return paymentResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Check collection status (returns just the status string)
  Future<String> checkCollectionStatus(String collectionSequenceId) async {
    try {
      final response = await _networkService.call(
        '${F.baseUrl}/payments/collection-status/$collectionSequenceId',
        RequestMethod.get,
      );

      // Handle response data
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        responseData = json.decode(response.data);
      } else {
        throw Exception('Invalid response format');
      }

      // Extract status from response
      final status = responseData['status']?.toString() ?? 'unknown';
      // print('🔍 Collection status for $collectionSequenceId: $status');

      return status;
    } catch (e) {
      // print('❌ Error checking collection status: $e');
      return 'unknown';
    }
  }

  /// Get collection status
  /// GET /api/v1/payments/collection-status/{collectionSequenceId}
  Future<PaymentResponse> getCollectionStatus(
    String collectionSequenceId,
  ) async {
    try {
      final response = await _networkService.call(
        '${F.baseUrl}/payments/collection-status/$collectionSequenceId',
        RequestMethod.get,
      );

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        responseData = json.decode(response.data);
      } else {
        throw Exception('Invalid response format');
      }

      final paymentResponse = PaymentResponse.fromJson(responseData);

      return paymentResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<PaymentResponse> fetchCryptoChannels() async {
    try {
      final response = await _networkService.call(
        F.baseUrl + UrlConfig.cryptoChannels,
        RequestMethod.get,
      );

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        // Try to parse JSON string
        try {
          responseData = json.decode(response.data);
        } catch (jsonError) {
          throw Exception('Failed to parse JSON response: $jsonError');
        }
      } else {
        throw Exception(
          'Invalid response format: ${response.data.runtimeType}',
        );
      }

      final paymentResponse = PaymentResponse.fromJson(responseData);

      return paymentResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// GET /payments/crypto/send-config
  Future<Map<String, dynamic>> fetchCryptoSendConfig() async {
    final response = await _networkService.call(
      F.baseUrl + UrlConfig.cryptoSendConfig,
      RequestMethod.get,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return (data['data'] as Map<String, dynamic>?) ?? data;
    }
    return {};
  }

  /// POST /payments/crypto/send
  Future<CryptoSendResult> sendCrypto({
    required String to,
    required String amount,
    required String asset,
    required String network,
    required String pin,
    String memo = '',
  }) async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.cryptoSend}',
      RequestMethod.post,
      data: {
        'to': to,
        'amount': amount,
        'asset': asset.toUpperCase(),
        'network': network.toLowerCase(),
        'pin': pin,
        if (memo.isNotEmpty) 'memo': memo,
      },
    );
    Map<String, dynamic> envelope;
    if (response.data is Map<String, dynamic>) {
      envelope = response.data;
    } else if (response.data is String) {
      envelope = json.decode(response.data) as Map<String, dynamic>;
    } else {
      throw Exception('Invalid response format');
    }
    final status = envelope['status']?.toString().toLowerCase();
    final code = envelope['code'];
    final ok = status == 'success' || code == 200;
    final data = envelope['data'];
    final hash = data is Map ? data['hash']?.toString() : null;
    return CryptoSendResult(
      success: ok,
      message: envelope['message']?.toString() ?? '',
      hash: hash,
      raw: data is Map<String, dynamic> ? data : null,
    );
  }

  /// POST /payments/bank-transfer — NGN bank payout via Flutterwave (debits NGN wallet).
  Future<PaymentResponse> bankTransfer({
    required num amount,
    required String accountNumber,
    required String bankCode,
    required String bankName,
    required String accountName,
    required num fee,
    required String pin,
    String spendCurrency = 'NGN',
  }) async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.bankTransfer}',
      RequestMethod.post,
      data: {
        'amount': amount,
        'accountNumber': accountNumber,
        'bankCode': bankCode,
        'bankName': bankName,
        'accountName': accountName,
        'fee': fee,
        'pin': pin,
        'spendCurrency': spendCurrency,
        'debitCurrency': spendCurrency,
      },
    );
    return _parsePaymentResponse(response.data);
  }

  PaymentResponse _parsePaymentResponse(dynamic data) {
    Map<String, dynamic> responseData;
    if (data is Map<String, dynamic>) {
      responseData = data;
    } else if (data is String) {
      responseData = json.decode(data) as Map<String, dynamic>;
    } else {
      throw Exception('Invalid response format');
    }
    return PaymentResponse.fromJson(responseData);
  }

  /// Initiate wallet to wallet transfer
  /// POST /api/v1/payments/initiate-wallet-transfer
  Future<PaymentResponse> initiateWalletTransfer({
    required String dayfiId,
    required int amount,
    required String encryptedPin,
    String debitCurrency = 'USD',
  }) async {
    try {
      final map = <String, dynamic>{
        'dayfiId': dayfiId.replaceAll('@', ''),
        'amount': amount,
        'pin': encryptedPin,
        'debitCurrency': debitCurrency.toUpperCase(),
        'spendCurrency': debitCurrency.toUpperCase(),
      };

      final response = await _networkService.call(
        '${F.baseUrl}/payments/initiate-wallet-transfer',
        RequestMethod.post,
        data: map,
      );

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        try {
          responseData = json.decode(response.data);
        } catch (jsonError) {
          throw Exception('Failed to parse JSON response: $jsonError');
        }
      } else {
        throw Exception(
          'Invalid response format: ${response.data.runtimeType}',
        );
      }

      final paymentResponse = PaymentResponse.fromJson(responseData);

      return paymentResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch payment fees
  /// GET /api/v1/payments/fees
  Future<FeesResponse> fetchFees() async {
    try {
      AppLogger.debug('🔄 PaymentService: Calling fees API');
      final response = await _networkService.call(
        F.baseUrl + UrlConfig.fetchFees,
        RequestMethod.get,
      );
      AppLogger.debug('🔄 PaymentService: Fees API response received');

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        // Try to parse JSON string
        responseData = json.decode(response.data);
      } else {
        throw Exception('Invalid response format');
      }

      final feesResponse = FeesResponse.fromJson(responseData);
      AppLogger.debug('🔄 PaymentService: Fees response parsed successfully');

      return feesResponse;
    } catch (e) {
      if (e is ApiError && (e.errorType == 404 || e.errorType == 501)) {
        AppLogger.debug(
          'PaymentService: fees endpoint not deployed (${e.errorType}), using defaults',
        );
        return FeesResponse(
          success: false,
          message: e.errorDescription ?? 'Fees not available',
          code: e.errorType ?? 404,
          data: FeesData(
            transfer: TransferFees(dayfiToDayfi: 0, dayfiToBank: 0),
            withdrawal: WithdrawalFees(local: 0, international: 0),
          ),
        );
      }
      AppLogger.error('❌ PaymentService: Error in fetchFees: $e');
      rethrow;
    }
  }
}

class CryptoSendResult {
  final bool success;
  final String message;
  final String? hash;
  final Map<String, dynamic>? raw;

  const CryptoSendResult({
    required this.success,
    required this.message,
    this.hash,
    this.raw,
  });
}
