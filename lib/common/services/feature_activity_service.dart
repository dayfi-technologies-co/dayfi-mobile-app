import 'dart:convert';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/feature_intro_keys.dart';
import 'package:dayfi/common/helpers/wallet_transaction_display.dart';
import 'package:dayfi/common/helpers/wallet_transaction_labels.dart';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/services/local/local_cache.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/services/remote/network/url_config.dart';

/// Tracks whether the user has completed a money-moving action per home feature.
class FeatureActivityService {
  FeatureActivityService._();

  static final FeatureActivityService instance = FeatureActivityService._();

  final NetworkService _network = locator<NetworkService>();
  final LocalCache _cache = locator<LocalCache>();

  Map<String, bool>? _flags;

  void invalidate() {
    _flags = null;
  }

  /// Merges activity detected from loaded wallet history (keeps intros in sync after a new tx).
  void updateFromTransactions(List<WalletTransaction> txs) {
    final detected = detectFromTransactions(txs);
    if (_flags == null) {
      _flags = detected;
      return;
    }
    _flags = {
      for (final key in detected.keys)
        key: (_flags![key] ?? false) || (detected[key] ?? false),
    };
  }

  Future<bool> hasActivity(DayfiHomeFeature feature) async {
    final flags = await _loadFlags();
    return flags[_apiKey(feature)] ?? false;
  }

  Future<Map<String, bool>> _loadFlags() async {
    if (_flags != null) return _flags!;

    try {
      final response = await _network.call(
        '${F.baseUrl}${UrlConfig.featureActivity}',
        RequestMethod.get,
      );
      final data = response.data;
      Map<String, dynamic> map;
      if (data is Map<String, dynamic>) {
        map = data['data'] is Map
            ? Map<String, dynamic>.from(data['data'] as Map)
            : data;
      } else if (data is String) {
        final decoded = json.decode(data) as Map<String, dynamic>;
        map = decoded['data'] is Map
            ? Map<String, dynamic>.from(decoded['data'] as Map)
            : decoded;
      } else {
        throw Exception('Invalid feature activity response');
      }
      _flags = {
        'send': map['send'] == true,
        'add': map['add'] == true,
        'swap': map['swap'] == true,
        'pay': map['pay'] == true,
        'invest': map['invest'] == true,
        'budget': map['budget'] == true,
      };
      return _flags!;
    } catch (_) {
      final txs = _readCachedTransactions();
      _flags = detectFromTransactions(txs);
      return _flags!;
    }
  }

  List<WalletTransaction> _readCachedTransactions() {
    try {
      final cached = _cache.getFromLocalCache('transactions');
      if (cached == null) return [];
      final List<dynamic> txJson = cached is String
          ? walletTransactionsFromJson(cached)
          : (cached as List<dynamic>);
      return txJson
          .whereType<Map<String, dynamic>>()
          .map(WalletTransaction.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Map<String, bool> detectFromTransactions(List<WalletTransaction> txs) {
    var send = false;
    var add = false;
    var swap = false;
    var pay = false;
    var invest = false;
    var budget = false;

    for (final tx in txs) {
      if (WalletTransactionDisplay.isCurrencyConversion(tx)) {
        swap = true;
      }
      if (WalletTransactionLabels.isBillPayment(tx)) {
        pay = true;
      }
      if (WalletTransactionLabels.isInvestment(tx)) {
        invest = true;
      }
      if (WalletTransactionLabels.isBudget(tx)) {
        budget = true;
      }
      if (_isAddMoney(tx)) {
        add = true;
      }
      if (_isSendMoney(tx)) {
        send = true;
      }
    }

    return {
      'send': send,
      'add': add,
      'swap': swap,
      'pay': pay,
      'invest': invest,
      'budget': budget,
    };
  }

  static bool _isAddMoney(WalletTransaction tx) {
    if (WalletTransactionDisplay.isCurrencyConversion(tx)) return false;
    final status = WalletTransactionDisplay.effectiveStatus(tx).toLowerCase();
    if (!status.contains('collection')) return false;
    final name = tx.beneficiary.name.toLowerCase();
    final reason = (tx.reason ?? '').toLowerCase();
    final channel = (tx.receiveChannel ?? '').toLowerCase();
    return name.contains('wallet top up') ||
        channel == 'crypto' ||
        channel == 'bank' ||
        reason.contains('deposit');
  }

  static bool _isSendMoney(WalletTransaction tx) {
    if (WalletTransactionDisplay.isCurrencyConversion(tx)) return false;
    if (WalletTransactionLabels.isBillPayment(tx)) return false;
    if (WalletTransactionLabels.isInvestment(tx)) return false;
    final status = WalletTransactionDisplay.effectiveStatus(tx).toLowerCase();
    if (!status.contains('payment')) return false;
    final amount = tx.sendAmount ?? 0;
    return amount > 0;
  }

  static String _apiKey(DayfiHomeFeature feature) {
    switch (feature) {
      case DayfiHomeFeature.send:
        return 'send';
      case DayfiHomeFeature.add:
        return 'add';
      case DayfiHomeFeature.swap:
        return 'swap';
      case DayfiHomeFeature.pay:
        return 'pay';
      case DayfiHomeFeature.invest:
        return 'invest';
      case DayfiHomeFeature.budget:
        return 'budget';
    }
  }
}
