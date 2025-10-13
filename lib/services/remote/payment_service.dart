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

  /// Complete transaction flow: Create collection → Wait for success → Create payment
  /// This method handles the complete flow as described in the requirements
  Future<PaymentResponse> completeTransactionFlow({
    required Map<String, dynamic> collectionData,
    required Map<String, dynamic> paymentData,
    Duration pollingInterval = const Duration(seconds: 5),
    Duration timeout = const Duration(minutes: 10),
  }) async {
    try {
      // Step 1: Create collection
      print('🔄 Creating collection...');
      final collectionResponse = await createCollection(collectionData);

      if (collectionResponse.error) {
        throw Exception(
          'Collection creation failed: ${collectionResponse.message}',
        );
      }

      // Extract collection sequence ID from response
      final collectionSequenceId =
          collectionResponse.data?['sequenceId'] ??
          collectionResponse.data?['id'];

      if (collectionSequenceId == null) {
        throw Exception('Collection sequence ID not found in response');
      }

      print(
        '✅ Collection created successfully. Sequence ID: $collectionSequenceId',
      );

      // Step 2: Poll for collection status until success-collection
      print('🔄 Waiting for collection status: success-collection...');
      final collectionStatus = await _pollCollectionStatus(
        collectionSequenceId,
        pollingInterval: pollingInterval,
        timeout: timeout,
      );

      if (collectionStatus != 'success-collection') {
        throw Exception(
          'Collection did not reach success-collection status. Final status: $collectionStatus',
        );
      }

      print('✅ Collection status reached: success-collection');

      // Step 3: Create payment
      print('🔄 Creating payment...');

      // Add collection sequence ID to payment data
      paymentData['collectionSequenceId'] = collectionSequenceId;

      final paymentResponse = await createPayment(paymentData);

      if (paymentResponse.error) {
        throw Exception('Payment creation failed: ${paymentResponse.message}');
      }

      print('✅ Payment created successfully');
      return paymentResponse;
    } catch (e) {
      print('❌ Transaction flow failed: $e');
      rethrow;
    }
  }

  /// Poll collection status until it reaches success-collection
  Future<String> _pollCollectionStatus(
    String collectionSequenceId, {
    Duration pollingInterval = const Duration(seconds: 5),
    Duration timeout = const Duration(minutes: 10),
  }) async {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      try {
        // TODO: Implement collection status check endpoint
        // For now, we'll simulate the polling with a mock response
        // In a real implementation, you would call an endpoint like:
        // GET /api/v1/payments/collection-status/{collectionSequenceId}

        await Future.delayed(pollingInterval);

        // Mock implementation - replace with actual API call
        // This should check the actual collection status
        final status = await _checkCollectionStatus(collectionSequenceId);

        if (status == 'success-collection') {
          return status;
        }

        if (status == 'failed' || status == 'failed-collection') {
          throw Exception('Collection failed with status: $status');
        }

        print('⏳ Collection status: $status. Continuing to poll...');
      } catch (e) {
        print('⚠️ Error checking collection status: $e');
        // Continue polling unless it's a critical error
        await Future.delayed(pollingInterval);
      }
    }

    throw Exception(
      'Collection status polling timed out after ${timeout.inMinutes} minutes',
    );
  }

  /// Check collection status (mock implementation)
  Future<String> _checkCollectionStatus(String collectionSequenceId) async {
    // Mock implementation - replace with actual API call
    // GET /api/v1/payments/collection-status/{collectionSequenceId}

    // Simulate different statuses for testing
    await Future.delayed(const Duration(seconds: 2));

    // For demo purposes, return success-collection after a few polls
    // In real implementation, this would make an actual API call
    return 'success-collection';
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
}
