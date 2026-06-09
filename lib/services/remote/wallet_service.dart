import 'dart:convert';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/models/wallet_hub.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/models/wallet.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/common/utils/app_logger.dart';
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
      final firstPage = await getWalletTransactions(
        search: search,
        limit: 100,
      );
      final totalPages = firstPage.data.totalPages;
      final allTransactions = <WalletTransaction>[...firstPage.data.transactions];

      if (totalPages > 1) {
        final pageFutures = <Future<WalletTransactionResponse>>[];
        for (var page = 2; page <= totalPages; page++) {
          pageFutures.add(
            getWalletTransactions(search: search, page: page, limit: 100),
          );
        }
        final pages = await Future.wait(pageFutures);
        for (final page in pages) {
          allTransactions.addAll(page.data.transactions);
        }
      }

      // Extract unique beneficiaries with source data based on name + account details
      final Map<String, BeneficiaryWithSource> uniqueBeneficiaries = {};
      
      for (final transaction in allTransactions) {
        final parsed = RecipientHistoryHelper.fromTransaction(transaction);
        if (parsed == null) continue;

        final uniqueKey = RecipientHistoryHelper.uniqueKey(parsed);
        final existing = uniqueBeneficiaries[uniqueKey];
        if (existing == null ||
            RecipientHistoryHelper.shouldReplaceRecipient(parsed, existing)) {
          uniqueBeneficiaries[uniqueKey] = parsed;
        }
      }

      return RecipientHistoryHelper.excludeInternalRecipients(
        uniqueBeneficiaries.values.toList(),
      );
    } catch (e) {
      throw Exception('Failed to fetch beneficiaries with source: $e');
    }
  }

  /// Saved recipients from backend (`GET /payments/beneficiaries`).
  Future<List<BeneficiaryWithSource>> fetchSavedBeneficiaries({
    int page = 1,
    int limit = 200,
  }) async {
    try {
      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.beneficiaries}',
        RequestMethod.get,
        queryParams: {'page': page, 'limit': limit},
      );
      final envelope = await _parseEnvelope(response.data);
      final data = envelope['data'];
      if (data is! Map<String, dynamic>) return const [];

      final raw = data['recipients'];
      if (raw is! List) return const [];

      return raw
          .whereType<Map<String, dynamic>>()
          .map(BeneficiaryWithSource.fromJson)
          .where(RecipientHistoryHelper.isSendRecipient)
          .toList();
    } catch (e) {
      AppLogger.error('Failed to fetch saved beneficiaries: $e');
      return const [];
    }
  }

  /// Persist a manually saved recipient (`POST /payments/beneficiaries`).
  Future<BeneficiaryWithSource> saveBeneficiary(
    BeneficiaryWithSource entry,
  ) async {
    final body = {
      'name': entry.beneficiary.name,
      'country': entry.beneficiary.country,
      'phone': entry.beneficiary.phone,
      'ledgerCurrency':
          entry.ledgerCurrency ??
          RecipientHistoryHelper.resolveLedgerCurrency(entry),
      'source': {
        'accountType': entry.source.accountType,
        'accountNumber': entry.source.accountNumber,
        'networkId': entry.source.networkId ?? '',
      },
    };

    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.beneficiaries}',
      RequestMethod.post,
      data: body,
    );
    final envelope = await _parseEnvelope(response.data);
    final data = envelope['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid save beneficiary response');
    }
    return BeneficiaryWithSource.fromJson(data);
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
  /// [syncCrypto] — only true for explicit refresh (crypto receive); wallet-details
  /// already syncs Stellar inflows on the backend.
  Future<WalletHubSnapshot> fetchWalletHub({bool syncCrypto = false}) async {
    if (syncCrypto) {
      try {
        final syncPayload = await syncCryptoInflows();
        final sync = syncPayload['sync'];
        if (sync is Map) {
          final errors = sync['errors'];
          if (errors is List && errors.isNotEmpty) {
            AppLogger.warning('Stellar sync: ${errors.join('; ')}');
          }
        }
      } catch (e) {
        AppLogger.warning('syncCryptoInflows skipped: $e');
      }
    }

    final envelope = await _fetchWalletDetailsData();
    final rawData = envelope['data'];
    final data = rawData is Map<String, dynamic> ? rawData : null;
    final hub = WalletHubSnapshot.fromApiData(data);
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

  /// POST /payments/crypto/sync-inflows
  /// Forces immediate ingestion of inbound on-chain deposits into ledger wallets.
  Future<Map<String, dynamic>> syncCryptoInflows() async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.cryptoSyncInflows}',
      RequestMethod.post,
      data: const <String, dynamic>{},
    );
    final envelope = await _parseEnvelope(response.data);
    final data = envelope['data'];
    if (data is Map<String, dynamic>) return data;
    return envelope;
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

  /// GET /payments/exchange-rates/wallet — all USD/NGN/GBP/EUR pairs.
  Future<Map<String, dynamic>> fetchWalletExchangeRates() async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.walletExchangeRates}',
      RequestMethod.get,
    );
    final envelope = await _parseEnvelope(response.data);
    final data = envelope['data'];
    if (data is Map<String, dynamic>) return data;
    return envelope;
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
    try {
      await _networkService.call(
        '${F.baseUrl}${UrlConfig.createWallet}',
        RequestMethod.post,
        data: {'currency': c},
      );
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('already have a wallet')) return;
      rethrow;
    }
  }
}
