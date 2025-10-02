import 'dart:convert';
import 'dart:developer';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/models/payment_response.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/services/remote/network/url_config.dart';

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

      log('ResolveBank request data: $map');
      log('ResolveBank URL: ${F.baseUrl}${UrlConfig.resolveBank}');

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.resolveBank,
        RequestMethod.post,
        data: map,
      );

      log('ResolveBank raw response: ${response.data}');

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
        log('Response data is Map: $responseData');
      } else if (response.data is String) {
        // Try to parse JSON string
        responseData = json.decode(response.data);
        log('Response data parsed from String: $responseData');
      } else {
        log('Invalid response format: ${response.data.runtimeType}');
        throw Exception('Invalid response format');
      }

      final paymentResponse = PaymentResponse.fromJson(responseData);

      log(
        'ResolveBank response - Status: ${paymentResponse.statusCode}, Error: ${paymentResponse.error}, Message: ${paymentResponse.message}',
      );

      return paymentResponse;
    } catch (e) {
      log('Error in resolveBank: $e');
      rethrow;
    }
  }

  /// Create collection request
  /// POST /api/v1/payments/create-collections
  Future<PaymentResponse> createCollection({
    required double amount,
    required String currency,
    required String channelId,
    required String country,
    required double localAmount,
    required String reason,
    required Recipient recipient,
    required Source source,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      Map<String, dynamic> map = {};
      map['amount'] = amount;
      map['currency'] = currency;
      map['channelId'] = channelId;
      map['country'] = country;
      map['localAmount'] = localAmount;
      map['reason'] = reason;
      map['recipient'] = recipient.toJson();
      map['source'] = source.toJson();

      if (metadata != null) {
        map['metadata'] = metadata;
      }

      log('CreateCollection request data: $map');
      log('CreateCollection URL: ${F.baseUrl}${UrlConfig.createCollection}');

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.createCollection,
        RequestMethod.post,
        data: map,
      );

      log('CreateCollection raw response: ${response.data}');

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
        log('Response data is Map: $responseData');
      } else if (response.data is String) {
        // Try to parse JSON string
        responseData = json.decode(response.data);
        log('Response data parsed from String: $responseData');
      } else {
        log('Invalid response format: ${response.data.runtimeType}');
        throw Exception('Invalid response format');
      }

      final paymentResponse = PaymentResponse.fromJson(responseData);

      log(
        'CreateCollection response - Status: ${paymentResponse.statusCode}, Error: ${paymentResponse.error}, Message: ${paymentResponse.message}',
      );

      return paymentResponse;
    } catch (e) {
      log('Error in createCollection: $e');
      rethrow;
    }
  }

  /// Fetch available payment channels
  /// GET /api/v1/payments/channels
  Future<PaymentResponse> fetchChannels() async {
    try {
      log('FetchChannels URL: ${F.baseUrl}${UrlConfig.fetchChannels}');

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.fetchChannels,
        RequestMethod.get,
      );

      log('FetchChannels raw response: ${response.data}');
      log('Response data type: ${response.data.runtimeType}');

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
        log('Response data is Map: $responseData');
      } else if (response.data is String) {
        // Try to parse JSON string
        try {
          responseData = json.decode(response.data);
          log('Response data parsed from String: $responseData');
        } catch (jsonError) {
          log('JSON decode error: $jsonError');
          throw Exception('Failed to parse JSON response: $jsonError');
        }
      } else {
        log('Invalid response format: ${response.data.runtimeType}');
        throw Exception(
          'Invalid response format: ${response.data.runtimeType}',
        );
      }

      final paymentResponse = PaymentResponse.fromJson(responseData);

      log(
        'FetchChannels response - Status: ${paymentResponse.statusCode}, Error: ${paymentResponse.error}, Message: ${paymentResponse.message}',
      );

      return paymentResponse;
    } catch (e) {
      log('Error in fetchChannels: $e');
      rethrow;
    }
  }

  /// Fetch available payment networks
  /// GET /api/v1/payments/networks
  Future<PaymentResponse> fetchNetworks() async {
    try {
      log('FetchNetworks URL: ${F.baseUrl}${UrlConfig.fetchNetworks}');

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.fetchNetworks,
        RequestMethod.get,
      );

      log('FetchNetworks raw response: ${response.data}');

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
        log('Response data is Map: $responseData');
      } else if (response.data is String) {
        // Try to parse JSON string
        responseData = json.decode(response.data);
        log('Response data parsed from String: $responseData');
      } else {
        log('Invalid response format: ${response.data.runtimeType}');
        throw Exception('Invalid response format');
      }

      final paymentResponse = PaymentResponse.fromJson(responseData);

      log(
        'FetchNetworks response - Status: ${paymentResponse.statusCode}, Error: ${paymentResponse.error}, Message: ${paymentResponse.message}',
      );

      return paymentResponse;
    } catch (e) {
      log('Error in fetchNetworks: $e');
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

      log('FetchRates URL: $url');

      final response = await _networkService.call(url, RequestMethod.get);

      log('FetchRates raw response: ${response.data}');

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
        log('Response data is Map: $responseData');
      } else if (response.data is String) {
        // Try to parse JSON string
        responseData = json.decode(response.data);
        log('Response data parsed from String: $responseData');
      } else {
        log('Invalid response format: ${response.data.runtimeType}');
        throw Exception('Invalid response format');
      }

      final paymentResponse = PaymentResponse.fromJson(responseData);

      log(
        'FetchRates response - Status: ${paymentResponse.statusCode}, Error: ${paymentResponse.error}, Message: ${paymentResponse.message}',
      );

      return paymentResponse;
    } catch (e) {
      log('Error in fetchRates: $e');
      rethrow;
    }
  }
}
