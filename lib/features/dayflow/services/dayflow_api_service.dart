import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_analytics.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_draft_schedules.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_wallet_balance.dart'
    show dayFlowOverlayGlobalWallet, kDayFlowWalletCurrency;
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/services/dayflow_cache_sync.dart';
import 'package:dayfi/features/dayflow/services/dayflow_dashboard_cache.dart';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/models/wallet_hub.dart';
import 'package:dayfi/services/remote/network/network_service.dart';

class DayFlowApiService {
  DayFlowApiService({NetworkService? network})
      : _network = network ?? locator<NetworkService>();

  final NetworkService _network;

  Future<Map<String, dynamic>> _dataMap(dynamic raw) async {
    if (raw is Map<String, dynamic>) {
      final inner = raw['data'];
      if (inner is Map<String, dynamic>) return inner;
      return raw;
    }
    return {};
  }

  Future<List<DayFlowIncomeEvent>> fetchPendingIncome() async {
    try {
      final response = await _network.call(
        '${F.baseUrl}/dayflow/income/pending',
        RequestMethod.get,
      );
      final data = await _dataMap(response.data);
      final raw = data['pendingIncome'] as List<dynamic>? ?? [];
      return raw
          .whereType<Map>()
          .map((m) => DayFlowIncomeEvent.fromJson(Map<String, dynamic>.from(m)))
          .where((e) => e.transactionId.isNotEmpty && e.amount > 0)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> acknowledgeIncome(List<String> transactionIds) async {
    if (transactionIds.isEmpty) return;
    await _network.call(
      '${F.baseUrl}/dayflow/income/ack',
      RequestMethod.post,
      data: {'transactionIds': transactionIds},
    );
  }

  Future<DayFlowPlan?> fetchPlan() async {
    final result = await fetchPlanResult();
    return result.plan;
  }

  Future<({DayFlowPlan? plan, bool fromServer})> fetchPlanResult() async {
    try {
      final response = await _network.call(
        '${F.baseUrl}/dayflow/plan',
        RequestMethod.get,
      );
      final data = await _dataMap(response.data);
      final raw = data['plan'];
      if (raw is! Map<String, dynamic>) {
        return (plan: null, fromServer: true);
      }
      return (plan: _planFromApi(raw), fromServer: true);
    } catch (_) {
      return (plan: null, fromServer: false);
    }
  }

  Future<DayFlowDashboardSnapshot?> fetchDashboard({
    DayFlowPlan? localPlan,
    WalletHubSnapshot? localHub,
  }) async {
    try {
      final response = await _network.call(
        '${F.baseUrl}/dayflow/dashboard',
        RequestMethod.get,
      );
      final data = await _dataMap(response.data);
      var snap = DayFlowDashboardSnapshot.fromApi(data);
      if (localHub != null) {
        snap = dayFlowOverlayGlobalWallet(snap, localHub);
      }
      DayflowDashboardCache.instance.put(snap);
      return snap;
    } catch (_) {
      if (localPlan == null) return null;
      final snap = DayFlowAnalytics.buildLocalDashboard(
        plan: localPlan,
        hub: localHub,
      );
      DayflowDashboardCache.instance.put(snap);
      return snap;
    }
  }

  Future<bool> hasActiveBudgetOnServer() async {
    final cached = DayflowDashboardCache.instance.hasActivePlan;
    if (cached != null) return cached;
    try {
      final dash = await fetchDashboard();
      if (dash == null) return false;
      if (dash.hasActivePlan) return true;
      return dash.flows.any((f) => f.isActive);
    } catch (_) {
      return false;
    }
  }

  Future<List<DayFlowEnvelope>> fetchFlows() async {
    final response = await _network.call(
      '${F.baseUrl}/dayflow/flows',
      RequestMethod.get,
    );
    final data = await _dataMap(response.data);
    final raw = data['flows'] as List<dynamic>? ?? [];
    return raw
        .whereType<Map>()
        .map((m) => DayFlowEnvelope.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  /// Single automated send or bill — creates an active DayFlow with autopay on.
  Future<DayFlowEnvelope> createAutomation({
    required String title,
    required String paymentType,
    required double amount,
    required String frequency,
    required DateTime startAt,
    DateTime? endAt,
    String? recipientId,
    String? recipientHint,
    double? sourceAmount,
    Map<String, dynamic>? execution,
  }) async {
    final nextRunAt = startAt.toUtc().toIso8601String();
    final schedule = <String, dynamic>{
      'title': title,
      'amount': amount,
      if (sourceAmount != null && sourceAmount > 0) 'sourceAmount': sourceAmount,
      'frequency': frequency,
      'autoPay': true,
      'paymentType': paymentType,
      'nextRunAt': nextRunAt,
      if (recipientId != null && recipientId.isNotEmpty)
        'recipientId': recipientId,
      if (recipientHint != null && recipientHint.trim().isNotEmpty)
        'recipientHint': recipientHint.trim(),
      if (execution != null && execution.isNotEmpty) 'execution': execution,
    };

    final response = await _network.call(
      '${F.baseUrl}/dayflow/flows',
      RequestMethod.post,
      data: {
        'title': title,
        'budgetType': _flowBudgetType(frequency),
        'periodLabel': _automationPeriodLabel(frequency),
        'summaryLine': DayFlowCopy.flowActivated,
        'currency': kDayFlowWalletCurrency,
        'schedules': [schedule],
        if (endAt != null)
          'metadata': {'endsAt': endAt.toUtc().toIso8601String()},
      },
    );
    final data = await _dataMap(response.data);
    final raw = data['flow'];
    if (raw is! Map) {
      throw Exception('Invalid flow response');
    }
    DayFlowCacheSync.invalidateAll();
    return DayFlowEnvelope.fromJson(Map<String, dynamic>.from(raw));
  }

  static String _automationPeriodLabel(String frequency) {
    return switch (frequency) {
      'weekly' => 'Every week',
      'biweekly' => 'Every two weeks',
      'once' => 'One-time',
      _ => 'Every month',
    };
  }

  /// Flow-level budgetType must match api.dayfi.co validator (not schedule frequency).
  static String _flowBudgetType(String frequency) {
    switch (frequency) {
      case 'weekly':
      case 'monthly':
      case 'annual':
      case 'custom':
        return frequency;
      case 'once':
      case 'biweekly':
        // Stored on each schedule via `frequency`; flow envelope uses custom.
        return 'custom';
      default:
        return 'monthly';
    }
  }

  Future<DayFlowEnvelope> createFlowFromDraft(DayFlowPlanDraft draft) async {
    final schedules = dayflowSchedulesPayloadFromDraft(draft);
    final budgetType = _flowBudgetType(dayflowScheduleFrequency(draft));

    final response = await _network.call(
      '${F.baseUrl}/dayflow/flows',
      RequestMethod.post,
      data: {
        if (draft.title.trim().isNotEmpty) 'title': draft.title,
        'budgetType': budgetType,
        'periodLabel': draft.periodLabel,
        'summaryLine': DayFlowCopy.onTrackSummary,
        'currency': draft.currency,
        'categories': draft.categories
            .map(
              (c) => {
                'name': c.name,
                'allocated': c.allocated,
                'locked': true,
              },
            )
            .toList(),
        if (schedules.isNotEmpty) 'schedules': schedules,
      },
    );
    final data = await _dataMap(response.data);
    final raw = data['flow'];
    if (raw is! Map) {
      throw Exception('Invalid flow response');
    }
    return DayFlowEnvelope.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<double> cancelFlow(String flowId) async {
    final response = await _network.call(
      '${F.baseUrl}/dayflow/flows/$flowId/cancel',
      RequestMethod.post,
    );
    final data = await _dataMap(response.data);
    DayFlowCacheSync.invalidateAll();
    return (data['refundedAmount'] as num?)?.toDouble() ?? 0;
  }

  Future<void> updateFlowSchedule({
    required String flowId,
    required String scheduleId,
    String? recipientHint,
    String? recipientId,
    String? paymentType,
    double? sourceAmount,
    Map<String, dynamic>? execution,
  }) async {
    await _network.call(
      '${F.baseUrl}/dayflow/flows/$flowId/schedules/$scheduleId',
      RequestMethod.patch,
      data: {
        if (recipientHint != null) 'recipientHint': recipientHint,
        if (recipientId != null) 'recipientId': recipientId,
        if (paymentType != null) 'paymentType': paymentType,
        if (sourceAmount != null && sourceAmount > 0) 'sourceAmount': sourceAmount,
        if (execution != null) 'execution': execution,
      },
    );
  }

  Future<DayFlowPlan?> syncPlan(DayFlowPlan plan) async {
    final response = await _network.call(
      '${F.baseUrl}/dayflow/plan',
      RequestMethod.put,
      data: _planPayload(plan),
    );
    final data = await _dataMap(response.data);
    final raw = data['plan'];
    if (raw is Map<String, dynamic>) {
      return _planFromApi(raw);
    }
    return plan;
  }

  Future<DayFlowPlan> syncPlanFromDraft(DayFlowPlanDraft draft) async {
    final plan = DayFlowPlan.fromDraft(draft);
    final synced = await syncPlan(plan);
    return synced ?? plan;
  }

  Future<DayFlowPlanDraft?> fetchTemplate() async {
    try {
      final response = await _network.call(
        '${F.baseUrl}/dayflow/template',
        RequestMethod.get,
      );
      final data = await _dataMap(response.data);
      final raw = data['template'];
      if (raw is! Map<String, dynamic>) return null;
      if (raw.isEmpty) return null;
      return DayFlowPlanDraft.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  Future<DayFlowPlanDraft> saveTemplate(DayFlowPlanDraft draft) async {
    final response = await _network.call(
      '${F.baseUrl}/dayflow/template',
      RequestMethod.put,
      data: draft.toJson(),
    );
    final data = await _dataMap(response.data);
    final raw = data['template'];
    if (raw is Map<String, dynamic>) {
      return DayFlowPlanDraft.fromJson(raw);
    }
    return draft;
  }

  Map<String, dynamic> _planPayload(DayFlowPlan plan) => {
    'title': plan.title,
    'budgetType': plan.budgetType,
    'periodLabel': plan.periodLabel,
    'totalBudget': plan.totalBudget,
    'spent': plan.spent,
    'currency': plan.currency,
    'summaryLine': plan.summaryLine,
    'categories': plan.categories.map((c) => c.toJson()).toList(),
    'upcoming': plan.upcoming.map((u) => u.toJson()).toList(),
    'goals': plan.goals.map((g) => g.toJson()).toList(),
    'lockedCategories': plan.lockedCategories,
    'sweepToDayEarn': plan.sweepToDayEarn,
    'leftover': plan.leftover,
  };

  DayFlowPlan _planFromApi(Map<String, dynamic> raw) {
    return DayFlowPlan.fromJson({
      'id': raw['id'],
      'title': raw['title'],
      'periodLabel': raw['periodLabel'],
      'budgetType': raw['budgetType'],
      'totalBudget': raw['totalBudget'],
      'spent': raw['spent'],
      'currency': raw['currency'] ?? 'NGN',
      'summaryLine': raw['summaryLine'],
      'categories': raw['categories'],
      'upcoming': raw['upcoming'],
      'goals': raw['goals'],
      'lockedCategories': raw['lockedCategories'],
      'leftover': raw['leftover'],
      'sweepToDayEarn': raw['sweepToDayEarn'],
    });
  }
}

final dayFlowApiService = DayFlowApiService();
