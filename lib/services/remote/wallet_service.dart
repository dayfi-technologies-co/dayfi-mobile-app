import 'dart:convert';
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

      // Convert response.data to Map<String, dynamic>
      Map<String, dynamic> responseData;
      
      if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        try {
          responseData = json.decode(response.data as String) as Map<String, dynamic>;
        } catch (jsonError) {
          throw Exception('Failed to parse JSON response: $jsonError');
        }
      } else {
        throw Exception('Unexpected response type: ${response.data.runtimeType}');
      }
      
      try {
        return WalletTransactionResponse.fromJson(responseData);
      } catch (parseError) {
        throw Exception('Failed to parse wallet transaction response: $parseError');
      }
    } catch (e) {
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
