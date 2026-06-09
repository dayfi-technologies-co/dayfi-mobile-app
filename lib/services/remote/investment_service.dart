import 'dart:convert';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/services/remote/network/url_config.dart';

class InvestmentPlan {
  final int lockDays;
  final String label;
  final double apyPercent;
  final double maxApyPercent;
  final double periodReturnPercent;

  const InvestmentPlan({
    required this.lockDays,
    required this.label,
    required this.apyPercent,
    required this.maxApyPercent,
    this.periodReturnPercent = 0,
  });

  factory InvestmentPlan.fromJson(Map<String, dynamic> json) {
    final apy = _num(json['apyPercent']);
    final lockDays = json['lockDays'] as int? ?? 0;
    final periodFromApi = json['periodReturnPercent'];
    return InvestmentPlan(
      lockDays: lockDays,
      label: json['label']?.toString() ?? '',
      apyPercent: apy,
      maxApyPercent: _num(json['maxApyPercent']),
      periodReturnPercent: periodFromApi != null
          ? _num(periodFromApi)
          : InvestmentPlan.computePeriodReturn(apy, lockDays),
    );
  }

  /// Total return % for this lock (APY × days ÷ 365), not the annual rate alone.
  static double computePeriodReturn(double apyPercent, int lockDays) {
    if (lockDays <= 0) return 0;
    return apyPercent * lockDays / 365;
  }
}

class InvestmentPosition {
  final String id;
  final String name;
  final double principal;
  final double apyPercent;
  final int lockDays;
  final double interestEarned;
  final double accruedInterest;
  final double totalPayout;
  final String status;
  final DateTime? startedAt;
  final DateTime? maturesAt;
  final DateTime? claimedAt;
  final bool canClaim;
  final int daysRemaining;

  InvestmentPosition({
    required this.id,
    required this.name,
    required this.principal,
    required this.apyPercent,
    required this.lockDays,
    required this.interestEarned,
    this.accruedInterest = 0,
    required this.totalPayout,
    required this.status,
    this.startedAt,
    this.maturesAt,
    this.claimedAt,
    required this.canClaim,
    required this.daysRemaining,
  });

  double get periodReturnPercent =>
      lockDays > 0 ? apyPercent * lockDays / 365 : 0;

  factory InvestmentPosition.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      final s = v?.toString();
      if (s == null || s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    return InvestmentPosition(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString().trim().isNotEmpty == true
          ? json['name'].toString().trim()
          : 'My lock',
      principal: _num(json['principal']),
      apyPercent: _num(json['apyPercent']),
      lockDays: json['lockDays'] as int? ?? 0,
      interestEarned: _num(json['interestEarned']),
      accruedInterest: _num(json['accruedInterest']),
      totalPayout: _num(json['totalPayout']),
      status: json['status']?.toString() ?? 'active',
      startedAt: parseDate(json['startedAt']),
      maturesAt: parseDate(json['maturesAt']),
      claimedAt: parseDate(json['claimedAt']),
      canClaim: json['canClaim'] == true,
      daysRemaining: json['daysRemaining'] as int? ?? 0,
    );
  }
}

class InvestmentSummary {
  final double balance;
  final double lockedPrincipal;
  final double estimatedInterest;
  final double totalDeposited;
  final bool riskAccepted;
  final double apyDisplayPercent;
  final String currency;
  final int activePositions;
  final int maturedReadyToClaim;
  final List<InvestmentPosition> positions;

  InvestmentSummary({
    required this.balance,
    required this.lockedPrincipal,
    required this.estimatedInterest,
    required this.totalDeposited,
    required this.riskAccepted,
    required this.apyDisplayPercent,
    required this.currency,
    required this.activePositions,
    required this.maturedReadyToClaim,
    required this.positions,
  });

  factory InvestmentSummary.fromJson(Map<String, dynamic> json) {
    final posList = json['positions'];
    final positions = <InvestmentPosition>[];
    if (posList is List) {
      for (final p in posList) {
        if (p is Map) {
          positions.add(
            InvestmentPosition.fromJson(Map<String, dynamic>.from(p)),
          );
        }
      }
    }
    return InvestmentSummary(
      balance: _num(json['balance']),
      lockedPrincipal: _num(json['lockedPrincipal']),
      estimatedInterest: _num(json['estimatedInterest']),
      totalDeposited: _num(json['totalDeposited']),
      riskAccepted: json['riskAccepted'] == true,
      apyDisplayPercent: _num(json['apyDisplayPercent']),
      currency: json['currency']?.toString() ?? 'USD',
      activePositions: json['activePositions'] as int? ?? 0,
      maturedReadyToClaim: json['maturedReadyToClaim'] as int? ?? 0,
      positions: positions,
    );
  }

  static double _num(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class InvestmentQuote {
  final double amount;
  final int lockDays;
  final double apyPercent;
  final double estimatedInterest;
  final double estimatedPayout;
  final DateTime? maturesAt;

  InvestmentQuote({
    required this.amount,
    required this.lockDays,
    required this.apyPercent,
    required this.estimatedInterest,
    required this.estimatedPayout,
    this.maturesAt,
  });

  factory InvestmentQuote.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      final s = v?.toString();
      if (s == null || s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    return InvestmentQuote(
      amount: InvestmentSummary._num(json['amount']),
      lockDays: json['lockDays'] as int? ?? 0,
      apyPercent: InvestmentSummary._num(json['apyPercent']),
      estimatedInterest: InvestmentSummary._num(json['estimatedInterest']),
      estimatedPayout: InvestmentSummary._num(json['estimatedPayout']),
      maturesAt: parseDate(json['maturesAt']),
    );
  }
}

class InvestmentService {
  final NetworkService _networkService;

  InvestmentService({required NetworkService networkService})
      : _networkService = networkService;

  Future<Map<String, dynamic>> _envelope(dynamic raw) async {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String) return json.decode(raw) as Map<String, dynamic>;
    throw Exception('Invalid response');
  }

  Future<Map<String, dynamic>> _dataMap(dynamic raw) async {
    final env = await _envelope(raw);
    final data = env['data'];
    if (data is Map<String, dynamic>) return data;
    return env;
  }

  Future<InvestmentSummary> fetchSummary() async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.investment}',
      RequestMethod.get,
    );
    final data = await _dataMap(response.data);
    var summary = InvestmentSummary.fromJson(data);
    if (summary.positions.isEmpty &&
        (summary.activePositions > 0 || summary.lockedPrincipal > 0)) {
      final positions = await fetchPositions();
      summary = InvestmentSummary(
        balance: summary.balance,
        lockedPrincipal: summary.lockedPrincipal,
        estimatedInterest: summary.estimatedInterest,
        totalDeposited: summary.totalDeposited,
        riskAccepted: summary.riskAccepted,
        apyDisplayPercent: summary.apyDisplayPercent,
        currency: summary.currency,
        activePositions: summary.activePositions,
        maturedReadyToClaim: summary.maturedReadyToClaim,
        positions: positions,
      );
    }
    return summary;
  }

  Future<List<InvestmentPosition>> fetchPositions() async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.investmentPositions}',
      RequestMethod.get,
    );
    final data = await _dataMap(response.data);
    final list = data['positions'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((p) => InvestmentPosition.fromJson(Map<String, dynamic>.from(p)))
        .toList();
  }

  Future<List<InvestmentPlan>> fetchPlans() async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.investmentPlans}',
      RequestMethod.get,
    );
    final data = await _dataMap(response.data);
    final plans = data['plans'];
    if (plans is! List) return [];
    return plans
        .whereType<Map<String, dynamic>>()
        .map(InvestmentPlan.fromJson)
        .toList();
  }

  Future<InvestmentQuote> fetchQuote({
    required double amount,
    required int lockDays,
  }) async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.investmentQuote}?amount=$amount&lockDays=$lockDays',
      RequestMethod.get,
    );
    final data = await _dataMap(response.data);
    return InvestmentQuote.fromJson(data);
  }

  Future<void> acceptRisk() async {
    await _networkService.call(
      '${F.baseUrl}${UrlConfig.investmentAcceptRisk}',
      RequestMethod.post,
      data: {},
    );
  }

  Future<Map<String, dynamic>> deposit({
    required double amount,
    required int lockDays,
    required String name,
    required String pin,
  }) async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.investmentDeposit}',
      RequestMethod.post,
      data: {
        'amount': amount,
        'lockDays': lockDays,
        'name': name.trim(),
        'pin': pin,
      },
    );
    return _dataMap(response.data);
  }

  Future<Map<String, dynamic>> claimPosition({
    required String positionId,
    required String pin,
  }) async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.investmentClaim(positionId)}',
      RequestMethod.post,
      data: {'pin': pin},
    );
    return _dataMap(response.data);
  }
}

double _num(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0;
}
