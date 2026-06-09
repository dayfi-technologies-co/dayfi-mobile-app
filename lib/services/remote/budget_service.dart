import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/budget/models/budget_models.dart';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/services/remote/network/url_config.dart';

class BudgetService {
  final NetworkService _networkService;

  BudgetService(this._networkService);

  Future<Map<String, dynamic>> _dataMap(dynamic raw) async {
    if (raw is Map<String, dynamic>) {
      final inner = raw['data'];
      if (inner is Map<String, dynamic>) return inner;
      return raw;
    }
    return {};
  }

  Future<List<Budget>> fetchBudgets({String? status}) async {
    final path =
        status != null ? '${UrlConfig.budgets}?status=$status' : UrlConfig.budgets;
    final response = await _networkService.call(
      '${F.baseUrl}$path',
      RequestMethod.get,
    );
    final root = response.data;
    if (root is Map && root['data'] is Map) {
      final budgets = root['data']['budgets'];
      if (budgets is List) {
        return budgets
            .map((e) => Budget.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    }
    return [];
  }

  Future<Budget> fetchBudget(String id) async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.budgetDetail(id)}',
      RequestMethod.get,
    );
    final data = await _dataMap(response.data);
    final raw = data['budget'] ?? data;
    if (raw is! Map) {
      throw Exception('Invalid budget response');
    }
    return Budget.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<Budget> createBudget({
    required String name,
    required String type,
    required double amount,
    String currency = 'USD',
    String frequency = 'monthly',
    List<Map<String, dynamic>>? categories,
    String? recipientId,
    String? nextRunAt,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.budgets}',
      RequestMethod.post,
      data: {
        'name': name,
        'type': type,
        'amount': amount,
        'currency': currency,
        'frequency': frequency,
        if (categories != null) 'categories': categories,
        if (recipientId != null) 'recipientId': recipientId,
        if (nextRunAt != null && nextRunAt.isNotEmpty) 'nextRunAt': nextRunAt,
        if (metadata != null && metadata.isNotEmpty) 'metadata': metadata,
      },
    );
    final data = await _dataMap(response.data);
    return Budget.fromJson(data);
  }

  Future<Budget> pause(String id) async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.budgetPause(id)}',
      RequestMethod.post,
      data: {},
    );
    final data = await _dataMap(response.data);
    return Budget.fromJson(data);
  }

  Future<Budget> resume(String id) async {
    final response = await _networkService.call(
      '${F.baseUrl}${UrlConfig.budgetResume(id)}',
      RequestMethod.post,
      data: {},
    );
    final data = await _dataMap(response.data);
    return Budget.fromJson(data);
  }

  Future<void> cancel(String id) async {
    await _networkService.call(
      '${F.baseUrl}${UrlConfig.budgetDetail(id)}',
      RequestMethod.delete,
    );
  }
}

final budgetService = BudgetService(locator<NetworkService>());
