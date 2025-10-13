import 'dart:convert';
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

  /// Fetch available payment channels
  /// GET /api/v1/payments/channels
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
        '${F.baseUrl}/api/v1/payments/create-payment-request',
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
        '${F.baseUrl}/api/v1/payments/collection-status/$collectionSequenceId',
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
      print('🔍 Collection status for $collectionSequenceId: $status');
      
      return status;
    } catch (e) {
      print('❌ Error checking collection status: $e');
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
        '${F.baseUrl}/api/v1/payments/collection-status/$collectionSequenceId',
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
}
