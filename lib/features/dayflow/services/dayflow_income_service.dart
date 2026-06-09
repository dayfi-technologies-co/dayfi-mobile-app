import 'dart:convert';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/services/dayflow_api_service.dart';
import 'package:dayfi/features/dayflow/services/dayflow_user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Detects wallet top-ups and tracks dismissed income prompts.
class DayFlowIncomeService {
  DayFlowIncomeService._();

  static final DayFlowIncomeService instance = DayFlowIncomeService._();

  static const _localDismissKey = DayFlowUserStorage.dismissedIncomeKeyBase;

  Future<String?> _dismissKey() async {
    await DayFlowUserStorage.ensureUserScope();
    return DayFlowUserStorage.scopedKeyForCurrentUser(_localDismissKey);
  }

  Future<List<DayFlowIncomeEvent>> fetchPending() async {
    final remote = await dayFlowApiService.fetchPendingIncome();
    final dismissed = await _loadLocalDismissed();
    final pending =
        remote
            .where((e) => !dismissed.contains(e.transactionId))
            .where((e) => e.amount > 0 && e.transactionId.isNotEmpty)
            .toList();
    pending.sort((a, b) {
      final aTs = a.timestamp?.millisecondsSinceEpoch ?? 0;
      final bTs = b.timestamp?.millisecondsSinceEpoch ?? 0;
      return bTs.compareTo(aTs);
    });
    return pending;
  }

  Future<DayFlowIncomeEvent?> latestPending({String? preferCurrency}) async {
    final items = await fetchPending();
    if (items.isEmpty) return null;
    if (preferCurrency != null) {
      final match = items.where(
        (e) => e.currency.toUpperCase() == preferCurrency.toUpperCase(),
      );
      if (match.isNotEmpty) return match.first;
      return null;
    }
    final ngn = items.where((e) => e.isNgn);
    if (ngn.isNotEmpty) return ngn.first;
    return null;
  }

  Future<void> dismiss(
    DayFlowIncomeEvent event, {
    bool syncRemote = true,
  }) async {
    await _addLocalDismissed(event.transactionId);
    if (syncRemote) {
      await dayFlowApiService.acknowledgeIncome([event.transactionId]);
    }
  }

  Future<void> dismissAll(Iterable<DayFlowIncomeEvent> events) async {
    final ids = events.map((e) => e.transactionId).where((id) => id.isNotEmpty);
    for (final id in ids) {
      await _addLocalDismissed(id);
    }
    await dayFlowApiService.acknowledgeIncome(ids.toList());
  }

  Future<Set<String>> _loadLocalDismissed() async {
    final key = await _dismissKey();
    if (key == null) return {};
    final raw = locator<SharedPreferences>().getString(key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> _addLocalDismissed(String transactionId) async {
    if (transactionId.isEmpty) return;
    final key = await _dismissKey();
    if (key == null) return;
    final set = await _loadLocalDismissed();
    set.add(transactionId);
    await locator<SharedPreferences>().setString(
      key,
      json.encode(set.toList()),
    );
  }
}
