import 'dart:convert';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/models/wallet_hub.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/models/wallet.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:dayfi/models/payment_response.dart' as payment;
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/services/remote/network/url_config.dart';

class WalletService {
  final NetworkService _networkService;

  WalletService({required NetworkService networkService}) : _networkService = networkService;

  /// Fetch wallet details
  /// GET /api/v1/payments/wallet-details
  Future<Map<String, dynamic>> _fetchWalletDetailsData() async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.walletDetails}',
      RequestMethod.get,
    );
    return _parseEnvelope(response.data);
  }

  Future<WalletDetailsResponse> fetchWalletDetails() async {
    try {
      final envelope = await _fetchWalletDetailsData();
      return WalletDetailsResponse.fromJson(envelope);
    } catch (e) {
      throw Exception('Failed to fetch wallet details: $e');
    }
  }

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

  Future<List<BeneficiaryWithSource>> getUniqueBeneficiariesWithSource({
    String? search,
  }) async {
    try {
      final response = await getWalletTransactions(
        search: search,
        limit: 100, // Get more records to ensure we have unique beneficiaries
      );

      // Extract unique beneficiaries with source data based on name + account details
      final Map<String, BeneficiaryWithSource> uniqueBeneficiaries = {};
      
      for (final transaction in response.data.transactions) {
        final beneficiary = transaction.beneficiary;
        final source = transaction.source;
        
        // Skip transactions where beneficiary data is null/empty (collection/wallet funding transactions)
        // These transactions have null beneficiary data in the API response which gets converted to empty strings
        if (beneficiary.id.trim().isEmpty || 
            beneficiary.name.trim().isEmpty ||
            source.accountNumber == null || 
            source.accountNumber!.trim().isEmpty) {
          continue;
        }
        
        // Create a unique key combining beneficiary name, account number, and network ID
        // This ensures no duplicates based on the display string and name
        final uniqueKey = '${beneficiary.name}_${source.accountNumber}_${source.networkId}';
        
        if (!uniqueBeneficiaries.containsKey(uniqueKey)) {
          // Convert wallet_transaction Source to payment_response Source
          final paymentSource = payment.Source(
            accountType: source.accountType,
            accountNumber: source.accountNumber,
            networkId: source.networkId,
          );
          
          // Debug log to verify accountType is being passed
          // print('🔍 Creating beneficiary with source:');
          // print('   Account Type: ${source.accountType}');
          // print('   Account Number: ${source.accountNumber}');
          // print('   Network ID: ${source.networkId}');
          
          uniqueBeneficiaries[uniqueKey] = BeneficiaryWithSource(
            beneficiary: beneficiary,
            source: paymentSource,
          );
        }
      }

      return uniqueBeneficiaries.values.toList();
    } catch (e) {
      throw Exception('Failed to fetch beneficiaries with source: $e');
    }
  }

  /// Get unique Dayfi Tags from transaction history
  Future<List<String>> getUniqueDayfiIds() async {
    try {
      final response = await getWalletTransactions(
        limit: 100,
      );

      final Set<String> uniqueDayfiIds = {};
      
      for (final transaction in response.data.transactions) {
        final beneficiary = transaction.beneficiary;
        final source = transaction.source;
        
        // For dayfi-transfer transactions, use beneficiary.accountNumber
        if (transaction.id.startsWith('dayfi-transfer') &&
            beneficiary.accountType?.toLowerCase() == 'dayfi' &&
            beneficiary.accountNumber != null &&
            beneficiary.accountNumber!.trim().isNotEmpty) {
          uniqueDayfiIds.add(beneficiary.accountNumber!.trim());
        }
        // Fallback to source.dayfiId for other cases
        else if (source.dayfiId != null && source.dayfiId!.trim().isNotEmpty) {
          uniqueDayfiIds.add(source.dayfiId!.trim());
        }
      }

      return uniqueDayfiIds.toList();
    } catch (e) {
      throw Exception('Failed to fetch Dayfi Tags: $e');
    }
  }

  Future<Map<String, dynamic>> _parseEnvelope(dynamic raw) async {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String) {
      return json.decode(raw) as Map<String, dynamic>;
    }
    throw Exception('Unexpected response type: ${raw.runtimeType}');
  }

  /// Full hub: ledger + Grey operating accounts for home / add / convert.
  Future<WalletHubSnapshot> fetchWalletHub() async {
    final envelope = await _fetchWalletDetailsData();
    final data = envelope['data'];
    final hub = WalletHubSnapshot.fromApiData(
      data is Map<String, dynamic> ? data : null,
    );
    try {
      final grey = await fetchGreyAccounts();
      return WalletHubSnapshot(
        totalAvailableBalance: hub.totalAvailableBalance,
        ledgerWallets: hub.ledgerWallets,
        greyAccounts: grey,
        displayRows: hub.displayRows,
      );
    } catch (_) {
      return hub;
    }
  }

  /// GET /payments/grey/accounts
  Future<List<GreyOperatingAccount>> fetchGreyAccounts() async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.greyAccounts}',
      RequestMethod.get,
    );
    final envelope = await _parseEnvelope(response.data);
    final data = envelope['data'];
    if (data is! Map<String, dynamic>) return [];

    final list = data['operatingAccounts'] ?? data['accounts'];
    if (list is! List) return [];

    return list
        .whereType<Map<String, dynamic>>()
        .map(GreyOperatingAccount.fromJson)
        .toList();
  }

  /// GET /payments/crypto/balances — on-chain USDC/EURC/XLM/ETH balances.
  Future<Map<String, dynamic>> fetchCryptoBalances() async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.cryptoBalances}',
      RequestMethod.get,
    );
    final envelope = await _parseEnvelope(response.data);
    final data = envelope['data'];
    if (data is Map<String, dynamic>) return data;
    return {};
  }

  /// GET /payments/receive/crypto
  Future<Map<String, dynamic>> fetchReceiveCrypto() async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.receiveCrypto}',
      RequestMethod.get,
    );
    final envelope = await _parseEnvelope(response.data);
    final data = envelope['data'];
    if (data is Map<String, dynamic>) return data;
    return {};
  }

  /// GET /payments/exchange-rate?baseCurrency=&targetCurrency=
  Future<double> fetchExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.exchangeRate}',
      RequestMethod.get,
      queryParams: {
        'baseCurrency': fromCurrency.toUpperCase(),
        'targetCurrency': toCurrency.toUpperCase(),
      },
    );
    final envelope = await _parseEnvelope(response.data);
    final data = envelope['data'];
    if (data is Map<String, dynamic> && data['rate'] != null) {
      return double.tryParse(data['rate'].toString()) ?? 0;
    }
    if (data is num) return data.toDouble();
    return double.tryParse(data?.toString() ?? '') ?? 0;
  }

  /// POST /payments/wallets/swap
  Future<Map<String, dynamic>> provisionNgnFiatAccount() async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.provisionNgnFiat}',
      RequestMethod.post,
      data: {},
    );
    final envelope = await _parseEnvelope(response.data);
    final data = envelope['data'];
    if (data is Map<String, dynamic>) return data;
    return envelope;
  }

  Future<Map<String, dynamic>> swapWallets({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
    required String pin,
  }) async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.walletSwap}',
      RequestMethod.post,
      data: {
        'fromCurrency': fromCurrency.toUpperCase(),
        'toCurrency': toCurrency.toUpperCase(),
        'amount': amount,
        'pin': pin,
        'spendCurrency': fromCurrency.toUpperCase(),
      },
    );
    final envelope = await _parseEnvelope(response.data);
    final data = envelope['data'];
    if (data is Map<String, dynamic>) return data;
    return envelope;
  }

  /// POST /payments/wallets — create EUR/GBP ledger wallet when needed for swap.
  Future<void> ensureLedgerWallet(String currency) async {
    final c = currency.toUpperCase();
    if (c == 'USD' || c == 'NGN') return;
    await _networkService.call(
      '${F.baseUrl}${UrlConfig.createWallet}',
      RequestMethod.post,
      data: {'currency': c},
    );
  }
}
