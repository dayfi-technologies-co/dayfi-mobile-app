import 'dart:convert';
import 'dart:developer';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/services/remote/network/network_service.dart';

class WalletService {
  final NetworkService _networkService;

  WalletService({required NetworkService networkService}) : _networkService = networkService;

  Future<WalletTransactionResponse> getWalletTransactions({
    String? status,
    String? search,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sortOrder': sortOrder,
      };

      if (status != null) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _networkService.call(
        '${F.baseUrl}/payments/wallet-transactions',
        RequestMethod.get,
        queryParams: queryParams,
      );

      log('WalletTransactions raw response: ${response.data}');
      log('Response data type: ${response.data.runtimeType}');

      // Convert response.data to Map<String, dynamic>
      Map<String, dynamic> responseData;
      
      if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
        log('Response data is already Map: $responseData');
      } else if (response.data is String) {
        log('Response data is String, parsing JSON...');
        try {
          responseData = json.decode(response.data as String) as Map<String, dynamic>;
          log('Successfully parsed JSON: $responseData');
        } catch (jsonError) {
          log('JSON decode error: $jsonError');
          log('Raw string data: ${response.data}');
          throw Exception('Failed to parse JSON response: $jsonError');
        }
      } else {
        log('Unexpected response type: ${response.data.runtimeType}');
        log('Response data: ${response.data}');
        throw Exception('Unexpected response type: ${response.data.runtimeType}');
      }

      log('Final response data: $responseData');
      
      try {
        final result = WalletTransactionResponse.fromJson(responseData);
        log('Successfully created WalletTransactionResponse');
        return result;
      } catch (parseError) {
        log('Failed to parse WalletTransactionResponse: $parseError');
        log('Response data structure: $responseData');
        throw Exception('Failed to parse wallet transaction response: $parseError');
      }
    } catch (e) {
      log('Error in getWalletTransactions: $e');
      throw Exception('Failed to fetch wallet transactions: $e');
    }
  }

  Future<List<Beneficiary>> getUniqueBeneficiaries({
    String? search,
  }) async {
    try {
      final response = await getWalletTransactions(
        search: search,
        limit: 100, // Get more records to ensure we have unique beneficiaries
      );

      // Extract unique beneficiaries based on beneficiary ID
      final Map<String, Beneficiary> uniqueBeneficiaries = {};
      
      for (final transaction in response.data.transactions) {
        final beneficiary = transaction.beneficiary;
        if (!uniqueBeneficiaries.containsKey(beneficiary.id)) {
          uniqueBeneficiaries[beneficiary.id] = beneficiary;
        }
      }

      return uniqueBeneficiaries.values.toList();
    } catch (e) {
      throw Exception('Failed to fetch beneficiaries: $e');
    }
  }
}
