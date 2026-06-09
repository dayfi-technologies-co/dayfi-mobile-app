import 'dart:convert';

import 'package:dayfi/features/dayearn/helpers/dayearn_format.dart';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/features/dayearn/services/dayearn_summary_cache.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/services/remote/network/url_config.dart';

class DayEarnPot {
  final String id;
  final String name;
  final String currency;
  final double principal;
  final double interestEarned;
  final double balance;
  final double apyPercent;
  final double dailyInterest;
  final double todaysInterest;
  final DateTime? accrualStartsAt;
  final DateTime? firstCreditAt;
  final DateTime? nextInterestAt;
  final bool accrualActive;
  final bool awaitingFirstCredit;
  final String status;

  DayEarnPot({
    required this.id,
    required this.name,
    required this.currency,
    required this.principal,
    required this.interestEarned,
    required this.balance,
    required this.apyPercent,
    required this.dailyInterest,
    required this.todaysInterest,
    this.accrualStartsAt,
    this.firstCreditAt,
    this.nextInterestAt,
    this.accrualActive = false,
    this.awaitingFirstCredit = true,
    this.status = 'active',
  });

  factory DayEarnPot.fromJson(Map<String, dynamic> json) {
    DateTime? parse(dynamic v) {
      final s = v?.toString();
      if (s == null || s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    double n(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0;
    }

    return DayEarnPot(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'DayEarn',
      currency: json['currency']?.toString().toUpperCase() ?? kDayEarnCurrency,
      principal: n(json['principal']),
      interestEarned: n(json['interestEarned']),
      balance: n(json['balance']),
      apyPercent: n(json['apyPercent']),
      dailyInterest: n(json['dailyInterest']),
      todaysInterest: n(json['todaysInterest']),
      accrualStartsAt: parse(json['accrualStartsAt']),
      firstCreditAt: parse(json['firstCreditAt']),
      nextInterestAt: parse(json['nextInterestAt']),
      accrualActive: json['accrualActive'] == true,
      awaitingFirstCredit: json['awaitingFirstCredit'] == true,
      status: json['status']?.toString() ?? 'active',
    );
  }
}

class DayEarnActivity {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final DateTime? createdAt;

  DayEarnActivity({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    this.createdAt,
  });

  factory DayEarnActivity.fromJson(Map<String, dynamic> json) {
    DateTime? parse(dynamic v) {
      final s = v?.toString();
      if (s == null || s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    double n(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0;
    }

    return DayEarnActivity(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      amount: n(json['amount']),
      currency: json['currency']?.toString().toUpperCase() ?? kDayEarnCurrency,
      createdAt: parse(json['createdAt']),
    );
  }

  String get label {
    switch (type) {
      case 'deposit':
        return 'Deposit';
      case 'withdraw':
        return 'Withdrawal';
      case 'interest':
        return 'Interest credit';
      default:
        return type;
    }
  }
}

class DayEarnSummary {
  final double totalBalance;
  final double todaysInterest;
  final List<DayEarnPot> pots;

  DayEarnSummary({
    required this.totalBalance,
    required this.todaysInterest,
    required this.pots,
  });

  factory DayEarnSummary.fromJson(Map<String, dynamic> json) {
    double n(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0;
    }

    final potsRaw = json['pots'];
    final pots = <DayEarnPot>[];
    if (potsRaw is List) {
      for (final p in potsRaw) {
        if (p is Map) {
          pots.add(DayEarnPot.fromJson(Map<String, dynamic>.from(p)));
        }
      }
    }

    return DayEarnSummary(
      totalBalance: n(json['totalBalance']),
      todaysInterest: n(json['todaysInterest']),
      pots: pots,
    );
  }
}

class DayEarnPotDetail {
  final DayEarnPot pot;
  final List<DayEarnActivity> activity;

  DayEarnPotDetail({required this.pot, required this.activity});

  factory DayEarnPotDetail.fromJson(Map<String, dynamic> json) {
    final activityRaw = json['activity'];
    final activity = <DayEarnActivity>[];
    if (activityRaw is List) {
      for (final a in activityRaw) {
        if (a is Map) {
          activity.add(DayEarnActivity.fromJson(Map<String, dynamic>.from(a)));
        }
      }
    }

    return DayEarnPotDetail(
      pot: DayEarnPot.fromJson(
        Map<String, dynamic>.from(json['pot'] as Map? ?? json),
      ),
      activity: activity,
    );
  }
}

class DayEarnService {
  final NetworkService _networkService;

  DayEarnService({required NetworkService networkService})
    : _networkService = networkService;

  Future<Map<String, dynamic>> _dataMap(dynamic raw) async {
    Map<String, dynamic> env;
    if (raw is Map<String, dynamic>) {
      env = raw;
    } else if (raw is String) {
      env = json.decode(raw) as Map<String, dynamic>;
    } else {
      throw Exception('Invalid response');
    }
    final data = env['data'];
    if (data is Map<String, dynamic>) return data;
    return env;
  }

  Future<DayEarnSummary> fetchSummary({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = DayEarnSummaryCache.instance.peek();
      if (cached != null) return cached;
    }

    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.dayEarn}',
      RequestMethod.get,
    );
    final data = await _dataMap(response.data);
    final summary = DayEarnSummary.fromJson(data);
    DayEarnSummaryCache.instance.put(summary);
    return summary;
  }

  Future<DayEarnInterestPreview> fetchPreview({
    required double amount,
    required String currency,
  }) async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.dayEarnPreview}?amount=$amount&currency=$currency',
      RequestMethod.get,
    );
    final data = await _dataMap(response.data);
    return DayEarnInterestPreview.fromJson(data);
  }

  Future<DayEarnPotDetail> fetchPot(String potId) async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.dayEarnPot(potId)}',
      RequestMethod.get,
    );
    final data = await _dataMap(response.data);
    return DayEarnPotDetail.fromJson(data);
  }

  Future<Map<String, dynamic>> createPot({
    required String name,
    required double amount,
    required String currency,
    required String pin,
  }) async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.dayEarnPots}',
      RequestMethod.post,
      data: {
        'name': name,
        'amount': amount,
        'currency': currency.toUpperCase(),
        'pin': pin,
      },
    );
    return _dataMap(response.data);
  }

  Future<DayEarnPot> deposit({
    required String potId,
    required double amount,
    required String pin,
  }) async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.dayEarnPotDeposit(potId)}',
      RequestMethod.post,
      data: {'amount': amount, 'pin': pin},
    );
    final data = await _dataMap(response.data);
    return DayEarnPot.fromJson(
      Map<String, dynamic>.from(data['pot'] as Map? ?? data),
    );
  }

  Future<Map<String, dynamic>> withdraw({
    required String potId,
    required String pin,
    double? amount,
    bool withdrawAll = false,
  }) async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.dayEarnPotWithdraw(potId)}',
      RequestMethod.post,
      data: {
        if (amount != null) 'amount': amount,
        if (withdrawAll) 'withdrawAll': true,
        'pin': pin,
      },
    );
    return _dataMap(response.data);
  }
}
