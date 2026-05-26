import 'dart:convert';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/services/remote/network/url_config.dart';

class InvestmentSummary {
  final double balance;
  final double totalDeposited;
  final bool riskAccepted;
  final double apyDisplayPercent;
  final String currency;

  InvestmentSummary({
    required this.balance,
    required this.totalDeposited,
    required this.riskAccepted,
    required this.apyDisplayPercent,
    required this.currency,
  });

  factory InvestmentSummary.fromJson(Map<String, dynamic> json) {
    return InvestmentSummary(
      balance: _num(json['balance']),
      totalDeposited: _num(json['totalDeposited']),
      riskAccepted: json['riskAccepted'] == true,
      apyDisplayPercent: _num(json['apyDisplayPercent']),
      currency: json['currency']?.toString() ?? 'USD',
    );
  }

  static double _num(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
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

  Future<InvestmentSummary> fetchSummary() async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.investment}',
      RequestMethod.get,
    );
    final env = await _envelope(response.data);
    final data = env['data'];
    if (data is Map<String, dynamic>) {
      return InvestmentSummary.fromJson(data);
    }
    return InvestmentSummary.fromJson(env);
  }

  Future<void> acceptRisk() async {
    await _networkService.call(
      '${F.baseUrl}${UrlConfig.investmentAcceptRisk}',
      RequestMethod.post,
      data: {},
    );
  }

  Future<void> deposit({required double amount, required String pin}) async {
    await _networkService.call(
      '${F.baseUrl}${UrlConfig.investmentDeposit}',
      RequestMethod.post,
      data: {'amount': amount, 'pin': pin},
    );
  }

  Future<void> withdraw({required double amount, required String pin}) async {
    await _networkService.call(
      '${F.baseUrl}${UrlConfig.investmentWithdraw}',
      RequestMethod.post,
      data: {'amount': amount, 'pin': pin},
    );
  }
}
